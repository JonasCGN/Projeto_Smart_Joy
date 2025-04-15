import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smart_joy/bluetooth/server/bluetooth_server.dart';
import 'package:win32/win32.dart';
import 'dart:ffi';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerJoy {
    bool isBluetooth = false;
	
	final info = NetworkInfo();
	
	late String localIp = '';	
	int port = int.tryParse(dotenv.env['API_PORT'] ?? '') ?? 8080;

	List<String> allowedIps = [];
	Set<String> connectedIps = {};

	String get ip => localIp;
	set ip(final String ip) => localIp = ip;

	final user32 = DynamicLibrary.open('user32.dll');
	late final void Function(int bVk, int bScan, int dwFlags, int dwExtraInfo) keybdEvent = user32.lookupFunction<
		Void Function(Uint8, Uint8, Uint32, UintPtr),
		void Function(int, int, int, int)
	>('keybd_event');

	final String secretKey = dotenv.env['API_KEY'] ?? 'chave-secreta';

	ServerJoy._(this.localIp);

	static Future<ServerJoy> create() async {
		final instance = ServerJoy._(await getDeviceIP() ?? '');
		return instance;
	}

	static Future<String?> getDeviceIP() async {
		final info = NetworkInfo();

		String? localIp = await info.getWifiIP();

		if (localIp != null) {
			return localIp;
		}

		List<NetworkInterface> interfaces = await NetworkInterface.list(
			includeLoopback: false,
			type: InternetAddressType.IPv4,
		);
		
		NetworkInterface ethernet = interfaces.where((x) => x.name == "Ethernet").first;
		localIp = ethernet.addresses.first.address;

		return localIp;
	}

	bool executarAcaoWindows(String acao) {
		bool executar = true;

		void enviarTecla(int tecla) {
			keybdEvent(tecla, 0, 0, 0);
			keybdEvent(tecla, 0, KEYEVENTF_KEYUP, 0);
		}
		switch (acao) {
			case 'voldown': enviarTecla(VK_VOLUME_DOWN); break;
			case 'volup': enviarTecla(VK_VOLUME_UP); break;
			case 'mute': enviarTecla(VK_VOLUME_MUTE); break;
			case 'playpause': enviarTecla(0xB3); break;
			case 'next': enviarTecla(0xB0); break;
			case 'prev': enviarTecla(0xB1); break;
			case 'enter': enviarTecla(VK_RETURN); break;
			case 'tab': enviarTecla(VK_TAB); break;
			case 'up': enviarTecla(VK_UP); break;
			case 'down': enviarTecla(VK_DOWN); break;
			case 'left': enviarTecla(VK_LEFT); break;
			case 'right': enviarTecla(VK_RIGHT); break;
			case 'back': enviarTecla(VK_BROWSER_BACK); break;
			case 'forward': enviarTecla(VK_BROWSER_FORWARD); break;
			case 'tela_cheia': enviarTecla(VK_F11); break;
			case 'click':
				const mouseeventfLeftdown = 0x0002;
				const mouseeventfLeftup = 0x0004;
				final mouseEvent = user32.lookupFunction<
				Void Function(Uint32, Uint32, Int32, Int32, UintPtr),
				void Function(int, int, int, int, int)
				>('mouse_event');
				mouseEvent(mouseeventfLeftdown, 0, 0, 0, 0);
				mouseEvent(mouseeventfLeftup, 0, 0, 0, 0);
				break;
			//   case 'shutdown': Process.run('shutdown', ['/s', '/t', '0']); break;
			//   case 'restart': Process.run('shutdown', ['/r', '/t', '0']); break;
			//   case 'sleep': Process.run('rundll32.exe', ['powrprof.dll,SetSuspendState', '0,1,0']); break;
			case 'open_youtube': Process.run('cmd', ['/c', 'start https://www.youtube.com/tv']); break;
			case 'open_ytmusic': Process.run('cmd', ['/c', 'start https://music.youtube.com']); break;
			case 'open_steam': Process.run('cmd', ['/c', 'start steam://open/main']); break;
			default: {
				executar = false;
			}
		}
		return executar;
	}

	void digitarTexto(String texto) {
		const shiftKey = 0x10;
		for (var i = 0; i < texto.length; i++) {
			final char = texto[i];
			final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
			final codeUnit = char.toUpperCase().codeUnitAt(0);

			if (isUpper) {
				keybdEvent(shiftKey, 0, 0, 0);
			}

			keybdEvent(codeUnit, 0, 0, 0);
			keybdEvent(codeUnit, 0, KEYEVENTF_KEYUP, 0);

			if (isUpper) {
				keybdEvent(shiftKey, 0, KEYEVENTF_KEYUP, 0);
			}
		}
	}

	void moverMouse(int dx, int dy) {
		const mouseEventfMove = 0x0001;
		final mouseEvent = user32.lookupFunction<
			Void Function(Uint32, Uint32, Int32, Int32, UintPtr),
			void Function(int, int, int, int, int)
		>('mouse_event');

		mouseEvent(mouseEventfMove, dx, dy, 0, 0);
	}

	bool ipPermitido(Request req) {
		final info = req.context['shelf.io.connection_info'];
		if (info is HttpConnectionInfo) {
			final ipRemoto = info.remoteAddress.address;
			connectedIps.add(ipRemoto);
			if (!allowedIps.contains(ipRemoto)) {
				allowedIps.add(ipRemoto);
			}
			return true;
		}
		return false;
	}

	bool chaveValida(Request req) {
		final info = req.context['shelf.io.connection_info'];
		if (info is HttpConnectionInfo) {
			final ipRemoto = info.remoteAddress.address;
			if (allowedIps.contains(ipRemoto)) return true;
		}
		final queryParams = req.url.queryParameters;
		return queryParams['key'] == secretKey;
	}

	Future<void> startServerWireless() async {
		final router = shelf_router.Router()
		..get('/ping', (Request req) => Response.ok('pong'))
		..get('/status', (Request req) {
			final statusInfo = {
				'ip': ip,
				'allowedIps': allowedIps,
				'port': port,
				'status': 'online',
			};
			return Response.ok(
				jsonEncode(statusInfo),
				headers: {'Content-Type': 'application/json'},
			);
		})
		..get('/json/status', (Request req) {
			final statusData = {
				'ip': ip,
				'port': port,
				'status': 'ok',
			};
			return Response.ok(
			jsonEncode(statusData),
			headers: {'Content-Type': 'application/json'},
			);
		})
		..get('/controle/<acao>', (Request req, String acao) {
			if (!ipPermitido(req) || !chaveValida(req)) {
				final info = req.context['shelf.io.connection_info'];
				if (info is HttpConnectionInfo) {
					debugPrint('Acesso negado de ${info.remoteAddress.address}');
				}
				return Response.forbidden('Acesso negado');
			}
			debugPrint('Comando recebido: $acao');
			executarAcaoWindows(acao);
			return Response.ok('Executado: $acao');
		})
		..get('/teclado/<mensagem>', (Request req, String mensagem) {
			if (!ipPermitido(req) || !chaveValida(req)) {
			final info = req.context['shelf.io.connection_info'];
			if (info is HttpConnectionInfo) {
				debugPrint('Acesso negado de ${info.remoteAddress.address}');
			}
			return Response.forbidden('Acesso negado');
			}
			final texto = Uri.decodeComponent(mensagem);
			debugPrint('Texto recebido: $texto');
			digitarTexto(texto);
			return Response.ok('Texto recebido: $texto');
		})
		..get('/mouse/move', (Request req) {
			if (!ipPermitido(req) || !chaveValida(req)) {
				final info = req.context['shelf.io.connection_info'];
				if (info is HttpConnectionInfo) {
					debugPrint('Acesso negado de ${info.remoteAddress.address}');
				}
				return Response.forbidden('Acesso negado');
			}

			final params = req.url.queryParameters;

			final dx = (double.tryParse(params['dx'] ?? '0') ?? 0).round();
			final dy = (double.tryParse(params['dy'] ?? '0') ?? 0).round();

			moverMouse(dx, dy);
			return Response.ok('Mouse movido: dx=$dx, dy=$dy');
			})
		..get('/ips', (Request req) {
			if (!chaveValida(req)) {
				return Response.forbidden('Chave inválida');
			}
			return Response.ok(connectedIps.join('\n'));
		});

		await io.serve(
			logRequests().addHandler(router.call),
			InternetAddress.anyIPv4,
			port,
		);
	}

	Future<void> startServerBLuetooth() async {
		void comandosBluetooth(String comando) {
			if(comando.startsWith('/controle/')) {
				final acao = comando.substring('/controle/'.length);
				debugPrint('Comando recebido: $acao');
				executarAcaoWindows(acao);
			}else if(comando.startsWith('/teclado/')) { // Ok
				final mensagem = comando.substring('/teclado/'.length);
				final texto = Uri.decodeComponent(mensagem);
				debugPrint('Texto recebido: $texto');
				digitarTexto(texto);
			}else if(comando.startsWith('/mouse/move')) {
				final params = comando.split('/')[3].split(' ');
				
				final dx = (double.tryParse(params[0]) ?? 0).round();
				final dy = (double.tryParse(params[1]) ?? 0).round();

				moverMouse(dx, dy);
			}
		}

		Timer.periodic(const Duration(microseconds: 100), (_) {
			final cmd = getNextCommand();
			if (cmd != null && cmd.isNotEmpty) {
				String comando = cmd.toString();
				if(!executarAcaoWindows(comando)){
					comandosBluetooth(comando);
				}
			}
		});
	}

	Future<void> startServer() async {
		await startServerWireless();
		await startServerBLuetooth();
	}
}