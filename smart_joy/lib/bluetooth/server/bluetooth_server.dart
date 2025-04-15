import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final libPath = '${Platform.resolvedExecutable}/../bluetooth_server.dll';

// Loga o caminho pra garantir onde ele está procurando
void log(String message) {
  final file = File('log.txt');
  file.writeAsStringSync('[LOG] $message\n', mode: FileMode.append);
}

final DynamicLibrary bluetoothLib = Platform.isWindows
    ? (() {
        log('Tentando carregar DLL de: $libPath');
        final fileExists = File(libPath).existsSync();
        log('DLL existe? ${fileExists ? "SIM" : "NÃO"}');

        if (!fileExists) throw Exception('DLL não encontrada em $libPath');

        final lib = DynamicLibrary.open(libPath);
        log('DLL carregada com sucesso!');
        return lib;
      })()
    : throw UnsupportedError('Somente suportado no Windows');

// FFI: Start Bluetooth Server
final void Function() startBluetoothServerNative = bluetoothLib
    .lookup<NativeFunction<Void Function()>>('start_bluetooth_server')
    .asFunction();

final void Function() startBluetoothServerNativeThreaded = bluetoothLib
    .lookup<NativeFunction<Void Function()>>('start_bluetooth_server_threaded')
    .asFunction();

// FFI: Get next command from queue
typedef GetNextCommandNative = Pointer<Utf8> Function();
typedef GetNextCommandDart = Pointer<Utf8> Function();
final GetNextCommandDart _getNextCommand = bluetoothLib
    .lookup<NativeFunction<GetNextCommandNative>>('get_next_command')
    .asFunction();

typedef GetBluetoothMacAddressNative = Pointer<Utf8> Function();
typedef GetBluetoothMacAddressDart = Pointer<Utf8> Function();
final GetBluetoothMacAddressDart _getBluetoothMacAddress = bluetoothLib
	.lookup<NativeFunction<GetBluetoothMacAddressNative>>(
		'get_bluetooth_mac_address')
	.asFunction();

// FFI: Get Bluetooth MAC Address
String getBluetoothMacAddress() {
  final ptr = _getBluetoothMacAddress();
  if (ptr.address == 0) return 'N/A';
  return ptr.toDartString();
}

String? getNextCommand() {
  final ptr = _getNextCommand();
  if (ptr.address == 0) return null;
  return ptr.toDartString();
}

void bluetoothServerIsolate(_) {
  startBluetoothServerNative(); // Executa o servidor na isolate
}

