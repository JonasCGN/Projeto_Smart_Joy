import 'package:flutter/material.dart';
import 'package:bluetooth_serial/bluetooth_serial.dart';
import 'package:joy_controle/class/control_bluetooth.dart';
import 'package:joy_controle/controle/tela_controle.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
	List<Map<String, String>> dispositivos = [];
	String recebido = '';
	final ControlBluetooth controleBluetooth = ControlBluetooth();

	void escanear() async {
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Escaneando...')));

		final lista = await BluetoothSerial.escanear();
		if(lista.isEmpty){
			if(mounted){
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nenhum dispositivo encontrado, verifica a sua conexão bluetooth')));
			}
			return;
		}	

		debugPrint('Dispositivos encontrados: $lista');
		setState(() => dispositivos = lista);
	}

	void conectar(String mac) async {
		await controleBluetooth.conectar(mac);
		if(controleBluetooth.conectado){
			if(mounted){
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conectado a $mac')));
			}
			if(mounted){
				Navigator.pushReplacement(
					context, 
					MaterialPageRoute(builder: (_) => ControlePage(ipServidor: mac, interfaceControl: controleBluetooth)), 
				);
			}
		}else{
			if(mounted){
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao conectar')));
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
		appBar: AppBar(title: const Text('Bluetooth Serial')),
		body: SingleChildScrollView(
			child: Column(
				children: [
					ElevatedButton(
						onPressed: escanear, 
						child: const Text('Escanear')
					),
					...dispositivos.map((d) => ListTile(
						title: Text(d['nome'] ?? 'Sem nome'),
						subtitle: Text(d['mac']!),
						onTap: () => conectar(d['mac']!),
					)),
				],
			),
		),
		);
	}	
}
