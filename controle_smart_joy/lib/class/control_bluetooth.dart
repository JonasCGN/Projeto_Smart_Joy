import 'package:bluetooth_serial/bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:joy_controle/class/interface_control.dart';

class ControlBluetooth implements InterfaceControl {
	bool conectado = false;
	String? ipServidor;

	Future<void> conectar(String mac) async {
		if(!conectado){
			try {
				await BluetoothSerial.conectar(mac);
				conectado = true;
			} catch (e) {
				debugPrint('Erro ao conectar: $e');
			}
		}
	}

	@override 
	void enviarComando(String comando) async {
		debugPrint('Enviando comando: $comando');
		try {
			BluetoothSerial.enviar(comando);
		} catch (e) {
			debugPrint('Erro ao enviar comando: $e');
		}
  	}

	@override 
  	void enviarTexto(String texto) async {
		try {
			BluetoothSerial.enviar('/teclado/$texto');
		} catch (e) {
			debugPrint('Erro ao enviar texto: $e');
		}
	}

	@override 
  	void moverMouse(String direcao) async {
		double dx = 0;
		double dy = 0;
		const passo = 30.0;

		switch (direcao) {
		case 'up':
			dy = -passo;
			break;
		case 'down':
			dy = passo;
			break;
		case 'left':
			dx = -passo;
			break;
		case 'right':
			dx = passo;
			break;
		}

		try {
			enviarMovimento(dx,dy);
		} catch (e) {
			debugPrint('Erro ao mover mouse: $e');
		}
	}

	@override 
  	void enviarMovimento(double dx, double dy) async {
		try {
			BluetoothSerial.enviar('/mouse/move/$dx $dy');
		} catch (e) {
			debugPrint('Erro ao mover: $e');
		}
	}

	@override
  	void moverMouseDelta(Offset delta) async {
		const sensibilidade = 1.5;
		final dx = delta.dx * sensibilidade;
		final dy = delta.dy * sensibilidade;
		try {
			enviarMovimento(dx, dy);
		} catch (e) {
			debugPrint('Erro ao mover mouse delta: $e');
		}
	}

	@override 
  	void clicar(String botao) async {
		String comando = 'click';

		try {
			BluetoothSerial.enviar(comando);
		} catch (e) {
			debugPrint('Erro ao clicar: $e');
		}
	}
}