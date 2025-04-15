import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joy_controle/bluetooth/tela_bluetooth.dart';
import 'package:joy_controle/class/control_wireless.dart';
import 'package:joy_controle/controle/tela_controle.dart';
import 'package:joy_controle/telas/tela_escanear.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
	final TextEditingController manualController = TextEditingController();
	final ControlWireless controlWireless = ControlWireless();
		
	void detetarIPAutomaticamente() async {
		await controlWireless.detectarIPAutomaticamente(context);
		setState(() {
			ControlWireless.tentandoDetectar = false;
		});
	}

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			Timer(const Duration(seconds: 5), () {
				if (ControlWireless.ipServidor == null) {
					setState(() => ControlWireless.tentandoDetectar = false);
				}
			});
		});
		// detetarIPAutomaticamente();
	}


	@override
	Widget build(BuildContext context) {
		if (ControlWireless.ipServidor != null) {
			return ControlePage(ipServidor: ControlWireless.ipServidor!, interfaceControl: controlWireless);
		}

		if (ControlWireless.tentandoDetectar) {
			return const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			);
		}
		return Scaffold(
		appBar: AppBar(title: const Text('Parear com o Joy Server')),
		body: Center(
			child: Column(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				const Text('1. Escaneie o QR Code', style: TextStyle(fontSize: 18)),
				ElevatedButton.icon(
					icon: const Icon(Icons.bluetooth),
					label: const Text('Escanear QR Code'),
					onPressed: () {
						Navigator.push(context, MaterialPageRoute(
						builder: (_) => TelaEscanear(controlWireless: controlWireless,),
						));
					},
				),
				
				const SizedBox(height: 20),

				const Text('2. Ou conecte por Bluetooth:'),
				ElevatedButton.icon(
					icon: const Icon(Icons.bluetooth),
					label: const Text('Buscar Dispositivos Bluetooth'),
					onPressed: () {
						Navigator.push(context, MaterialPageRoute(
						builder: (_) => BluetoothPage(),
						));
					},
				),
				const SizedBox(height: 20),
				// const Text('3. Ou digite o IP manualmente:'),
				// Row(
				// children: [
				// 	Expanded(
				// 	child: TextField(
				// 		controller: manualController,
				// 		decoration: const InputDecoration(
				// 		hintText: 'http://192.168.X.X:5000'
				// 		),
				// 	),
				// 	),
				// 	IconButton(
				// 	icon: const Icon(Icons.check),
				// 	onPressed: () {
				// 		final ip = manualController.text.trim();
				// 		if (ip.isNotEmpty) ControlWireless.salvarIP(context,ip, 'Manual');
				// 	},
				// 	)
				// ],
				// )
			],
			),
		)
		);
	}
}
