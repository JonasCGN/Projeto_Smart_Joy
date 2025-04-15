import 'package:flutter/services.dart';

class BluetoothSerial {
	static const MethodChannel _channel = MethodChannel('bluetooth_serial');

	static Future<List<Map<String, String>>> escanear() async {
		final List<dynamic> dispositivos = await _channel.invokeMethod('escanear');
		return dispositivos.cast<Map>().map((e) => Map<String, String>.from(e)).toList();
	}

	static Future<void> conectar(String mac) async {
		await _channel.invokeMethod('conectar', {'mac': mac});
	}

	static Future<void> enviar(String mensagem) async {
		await _channel.invokeMethod('enviar', {'mensagem': mensagem});
	}

	static Future<String> receber() async {
		final String recebido = await _channel.invokeMethod('receber');
		return recebido;
	}
}