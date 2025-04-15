import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:joy_controle/class/control_wireless.dart';
import 'package:joy_controle/controle/tela_controle.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TelaEscanear extends StatefulWidget {
	final ControlWireless controlWireless;
  const TelaEscanear({super.key,required this.controlWireless});

  @override
  State<TelaEscanear> createState() => _TelaEscanearState();
}

class _TelaEscanearState extends State<TelaEscanear> {
  @override
  Widget build(BuildContext context) {
	final double tamanho = MediaQuery.sizeOf(context).height;
	if (ControlWireless.ipServidor != null) {
			return ControlePage(ipServidor: ControlWireless.ipServidor!, interfaceControl: widget.controlWireless);
		}

		if (ControlWireless.tentandoDetectar) {
		return const Scaffold(
			body: Center(child: CircularProgressIndicator()),
		);
	}
    return Container(
		color: Colors.grey,
		child: Column(
			children: [
				SizedBox(
					height: 30,
				),
				if (Platform.isAndroid || Platform.isIOS)
					Column(children: [
						Text(
							"Aponte para o QR CODE",
							style: TextStyle(
								fontSize: 20,
								inherit: false,
								color: Colors.black,
								fontWeight: FontWeight.bold
							),	
						),
						SizedBox(
							height: tamanho - 53,
							child: MobileScanner(
								onDetect: (capture) async {
									final code = capture.barcodes.first.rawValue;
									if (code != null) {
									String? ipFormatado;
									if (code.startsWith('joy://')) {
										ipFormatado = code.replaceFirst('joy://', '')
											.split('?')[0]
											.split(':')[0];
									} else if (code.startsWith('http')) {
										ipFormatado = code;
									}
									final url = Uri.parse('http://$ipFormatado:${ControlWireless.port}/controle/teste?key=${ControlWireless.key}');
									try {
										final resposta = await http.get(url).timeout(const Duration(milliseconds: 500));
										if (resposta.statusCode == 200) {
											if (context.mounted) {
												await ControlWireless.salvarIP(context,'http://$ipFormatado:${ControlWireless.port}', 'QR Code');
												setState(() {
													ControlWireless.tentandoDetectar = false;
												});
											}
										}
									} catch (_) {}
									}
								},
							),
						)
					],)
				else
					const Text('Escaneamento por QR Code disponível apenas em dispositivos móveis.')
				
			],
		),
	);
  }
}