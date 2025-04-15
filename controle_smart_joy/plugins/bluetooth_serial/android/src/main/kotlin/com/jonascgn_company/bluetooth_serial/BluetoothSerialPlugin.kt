package com.jonascgn_company.bluetooth_serial

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class BluetoothSerialPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    private var socket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var inputStream: InputStream? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "bluetooth_serial")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "escanear" -> {
                val bondedDevices = bluetoothAdapter.bondedDevices
                val lista = bondedDevices.map {
                    mapOf("nome" to it.name, "mac" to it.address)
                }
                result.success(lista)
            }
            
            "conectar" -> {
                try {
                    val mac = call.argument<String>("mac")!!
                    val device = bluetoothAdapter.getRemoteDevice(mac)

                    // Cancelar discovery (IMPORTANTE!)
                    bluetoothAdapter.cancelDiscovery()

                    // UUID padrão RFCOMM (SPP)
                    val uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

                    // Tenta abrir o socket
                    socket = device.createRfcommSocketToServiceRecord(uuid)

                    println("Tentando conectar ao dispositivo $mac")
                    socket?.connect()
                    println("Conectado com sucesso!")

                    // Inicializa streams
                    outputStream = socket?.outputStream
                    inputStream = socket?.inputStream

                    result.success(null)
                } catch (e: Exception) {
                    println("Erro ao conectar: ${e.message}")
                    result.error("CONNECTION_ERROR", e.message, null)
                }
            }

            "enviar" -> {
                try {
                    val mensagem = call.argument<String>("mensagem")!!
                    outputStream?.write(mensagem.toByteArray())
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SEND_ERROR", e.message, null)
                }
            }
            "receber" -> {
                try {
                    val buffer = ByteArray(1024)
                    val bytes = inputStream?.read(buffer) ?: 0
                    val recebido = String(buffer, 0, bytes)
                    result.success(recebido)
                } catch (e: Exception) {
                    result.error("READ_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
