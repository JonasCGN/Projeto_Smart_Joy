import 'dart:async';
import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_joy/class/server_joy.dart';

class ServerHomePage extends StatefulWidget {
  final String macAddress;
  const ServerHomePage({super.key, required this.macAddress});

  @override
  State<ServerHomePage> createState() => _ServerHomePageState();
}

class _ServerHomePageState extends State<ServerHomePage> {
  String connectionInfo = 'Aguardando conexão...';
  ServerJoy? serverJoy;

  @override
  void initState() {
    super.initState();
    _initializeServer();
  }

  Future<void> _initializeServer() async {
    serverJoy = await ServerJoy.create();
    print("Ip da rede: ${serverJoy!.ip}");

    await serverJoy!.startServer();
    setState(() {
      connectionInfo = "Servidor iniciado em: ${serverJoy!.ip}:${serverJoy!.port}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joy Server'),
        centerTitle: true,
      ),
      body: Center(
        child: serverJoy == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
					const Text(
						'Servidor Joy Ativo! Escaneie o QR Code:',
						style: TextStyle(fontSize: 18),
					),
					const SizedBox(height: 20),
					QrImageView(
						data: 'joy://${serverJoy!.ip}:${serverJoy!.port}?key=${serverJoy!.secretKey}',
						version: QrVersions.auto,
						size: 200.0,
					),
					const SizedBox(height: 10),
					Text(
						'Chave: ${serverJoy!.secretKey}',
						style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
					),
					const SizedBox(height: 20),
					Text('IP: ${serverJoy!.ip}:${serverJoy!.port}'),
					const SizedBox(height: 10),
					Text(connectionInfo, style: const TextStyle(fontSize: 12)),
					Text('Bluetooth MAC: ${widget.macAddress}', style: const TextStyle(fontSize: 12)),
                ],
              ),
      ),
    );
  }
}