#define _WINSOCKAPI_
#include <winsock2.h>
#include <ws2bth.h>
#include <windows.h>
#include <iostream>
#include <thread>
#include <bluetoothapis.h>
#include <bthsdpdef.h>
#include <string>
#include <sstream>
#include <iomanip>
#include <mutex>
#include <queue>

#pragma comment(lib, "Bthprops.lib")
#pragma comment(lib, "Ws2_32.lib")

// UUID do Joy Server Bluetooth (SPP)
const GUID JOY_SERVER_UUID = {
    0x00001101, 0x0000, 0x1000,
    { 0x80, 0x00, 0x00, 0x80, 0x5f, 0x9b, 0x34, 0xfb }
};

std::mutex commandMutex;
std::queue<std::string> commandQueue;

extern "C" {
__declspec(dllexport) void start_bluetooth_server() {
    WSAData wsaData;
    SOCKET serverSocket = INVALID_SOCKET;
    SOCKADDR_BTH sa = { 0 };
    int iResult;

    iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (iResult != 0) {
        std::cerr << "WSAStartup failed: " << iResult << std::endl;
        return;
    }

    serverSocket = socket(AF_BTH, SOCK_STREAM, BTHPROTO_RFCOMM);
    if (serverSocket == INVALID_SOCKET) {
        std::cerr << "Erro ao criar socket: " << WSAGetLastError() << std::endl;
        WSACleanup();
        return;
    }

    sa.addressFamily = AF_BTH;
    sa.btAddr = 0;
    sa.serviceClassId = JOY_SERVER_UUID;
    sa.port = BT_PORT_ANY;

    if (bind(serverSocket, (SOCKADDR*)&sa, sizeof(sa)) == SOCKET_ERROR) {
        std::cerr << "Bind falhou: " << WSAGetLastError() << std::endl;
        closesocket(serverSocket);
        WSACleanup();
        return;
    }

    int sa_len = sizeof(sa);
    getsockname(serverSocket, (SOCKADDR*)&sa, &sa_len);
    std::cout << "Canal RFCOMM atribuído: " << (int)sa.port << std::endl;

    WSAQUERYSET service = { 0 };
    service.dwSize = sizeof(service);
    service.lpServiceClassId = (GUID*)&JOY_SERVER_UUID;
    service.lpszServiceInstanceName = (LPSTR)"Joy Bluetooth Server";
    service.dwNameSpace = NS_BTH;

    CSADDR_INFO csAddr = { 0 };
    csAddr.iSocketType = SOCK_STREAM;
    csAddr.iProtocol = BTHPROTO_RFCOMM;
    csAddr.LocalAddr.iSockaddrLength = sizeof(sa);
    csAddr.LocalAddr.lpSockaddr = (SOCKADDR*)&sa;
    csAddr.RemoteAddr.iSockaddrLength = sizeof(sa);
    csAddr.RemoteAddr.lpSockaddr = (SOCKADDR*)&sa;

    service.dwNumberOfCsAddrs = 1;
    service.lpcsaBuffer = &csAddr;

    if (WSASetService(&service, RNRSERVICE_REGISTER, 0) == SOCKET_ERROR) {
        std::cerr << "Falha no registro SDP: " << WSAGetLastError() << std::endl;
    } else {
        std::cout << "Serviço Bluetooth registrado com sucesso." << std::endl;
    }

    if (listen(serverSocket, 1) == SOCKET_ERROR) {
        std::cerr << "Listen falhou: " << WSAGetLastError() << std::endl;
        closesocket(serverSocket);
        WSACleanup();
        return;
    }

    std::cout << "Servidor pronto para conexões Bluetooth..." << std::endl;

    while (true) {
        std::cout << "Aguardando conexão Bluetooth..." << std::endl;

        SOCKET clientSocket = INVALID_SOCKET;
        SOCKADDR_BTH clientAddr;
        int clientAddrLen = sizeof(clientAddr);

        clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddr, &clientAddrLen);
        if (clientSocket == INVALID_SOCKET) {
            std::cerr << "Erro no accept: " << WSAGetLastError() << std::endl;
            continue;
        }

        std::wcout << L"Cliente conectado com sucesso via Bluetooth!" << std::endl;

        char buffer[1024];
        int bytesReceived;

        while ((bytesReceived = recv(clientSocket, buffer, sizeof(buffer) - 1, 0)) > 0) {
            buffer[bytesReceived] = '\0';
            std::string rawCommand(buffer, bytesReceived);

            rawCommand.erase(0, rawCommand.find_first_not_of(" \r\n\t"));
            rawCommand.erase(rawCommand.find_last_not_of(" \r\n\t") + 1);

            {
                std::lock_guard<std::mutex> lock(commandMutex);
                commandQueue.push(rawCommand);
            }

            std::cout << "Recebido: " << rawCommand << std::endl;
        }

        if (bytesReceived == 0) {
            std::cout << "Cliente desconectou." << std::endl;
        } else if (bytesReceived == SOCKET_ERROR) {
            std::cerr << "Erro ao receber dados: " << WSAGetLastError() << std::endl;
        }

        closesocket(clientSocket);
    }

    // Nunca alcançado no loop infinito, mas para completude:
    closesocket(serverSocket);
    WSACleanup();
}

extern "C" __declspec(dllexport) void start_bluetooth_server_threaded() {
    std::thread([](){
        start_bluetooth_server(); // roda indefinidamente em segundo plano
    }).detach();
}

__declspec(dllexport) const char* get_next_command() {
    static std::string current;
    std::lock_guard<std::mutex> lock(commandMutex);
    if (commandQueue.empty()) return nullptr;
    current = commandQueue.front();
    commandQueue.pop();
    return current.c_str();
}

}

extern "C" __declspec(dllexport) const char* get_bluetooth_mac_address() {
    static std::string macStr = "";

    BLUETOOTH_FIND_RADIO_PARAMS params = { sizeof(BLUETOOTH_FIND_RADIO_PARAMS) };
    HANDLE hRadio = nullptr;
    HBLUETOOTH_RADIO_FIND hFind = BluetoothFindFirstRadio(&params, &hRadio);

    if (hFind == nullptr || hRadio == nullptr) {
        macStr = "N/A";
        return macStr.c_str();
    }

    BLUETOOTH_RADIO_INFO radioInfo = { sizeof(BLUETOOTH_RADIO_INFO) };
    DWORD result = BluetoothGetRadioInfo(hRadio, &radioInfo);

    if (result != ERROR_SUCCESS) {
        macStr = "ERROR";
        CloseHandle(hRadio);
        BluetoothFindRadioClose(hFind);
        return macStr.c_str();
    }

    std::ostringstream oss;
    for (int i = 5; i >= 0; --i) {
        oss << std::hex << std::setw(2) << std::setfill('0')
            << static_cast<int>(radioInfo.address.rgBytes[i]);
        if (i > 0) oss << ":";
    }

    macStr = oss.str();

    CloseHandle(hRadio);
    BluetoothFindRadioClose(hFind);
    return macStr.c_str();
}
