import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:joy_controle/class/interface_control.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlWireless implements InterfaceControl {
	static String? ipServidor;
  	static bool tentandoDetectar = true;
	static final int port = int.tryParse(dotenv.env['API_PORT'] ?? '') ?? 8080;
	static final String key = dotenv.env['API_KEY'] ?? 'chave-secreta';
	
	static Future<void> mostrarDialogo(BuildContext context,String metodo, String endereco) async {
		await showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Conectado com sucesso!'),
				content: Text('Pareado automaticamente por: $metodo\nEndereço: $endereco'),
				actions: [
				TextButton(
					onPressed: () => Navigator.of(context).pop(),
					child: const Text('OK'),
				)
				],
			),
		);
	}

	static Future<void> salvarIP(BuildContext context,String ip, String metodo) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('ip_servidor', ip);
		ControlWireless.ipServidor = ip;
		if (context.mounted) {
			await mostrarDialogo(context,metodo, ip);
		}
	}

	Future<void> detectarIPAutomaticamente(BuildContext context) async {
		try {
			final info = NetworkInfo();
			final localIp = await info.getWifiIP();
			if (localIp == null) return;
			
			print('IP local: $localIp');

			final subnet = localIp.substring(0, localIp.lastIndexOf('.') + 1);
			for (var i = 1; i < 255; i++) {
				final testIp = '$subnet$i';
				if (testIp == localIp) continue;
				final url = Uri.parse('http://$testIp:$port/controle/teste?key=$key');
				try {
					final resposta = await http.get(url).timeout(const Duration(milliseconds: 500));
					if (resposta.statusCode == 200) {
						if (context.mounted) {
							await ControlWireless.salvarIP(context,'http://$testIp:$port', 'Detecção Automática');
						}
						return;
					}
				} catch (_) {}
			}
		} catch (e) {
			debugPrint('Erro ao detectar IP: $e');
		}
		tentandoDetectar = false;
	}

	@override
	void enviarComando(String comando) async {
		debugPrint('Enviando comando: $comando');
		try {
			final url = Uri.parse('$ipServidor/controle/$comando');
			final resposta = await http.get(url);
			debugPrint('Comando enviado: $comando | Status: ${resposta.statusCode}');
		} catch (e) {
			debugPrint('Erro ao enviar comando: $e');
		}
  	}

	@override
	void enviarTexto(String texto) async {
		try {
			final url = Uri.parse('$ipServidor/teclado/${Uri.encodeComponent(texto)}');
			final resposta = await http.get(url);
			debugPrint('Texto enviado: "$texto" | Status: ${resposta.statusCode}');
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

		await enviarMovimento(dx, dy);
	}

	@override
	Future<void> enviarMovimento(double dx, double dy) async {
		try {
			final url = Uri.parse('$ipServidor/mouse/move?dx=$dx&dy=$dy');
			await http.get(url);
		} catch (e) {
			debugPrint('Erro ao mover mouse: $e');
		}
	}

	@override
	void moverMouseDelta(Offset delta) {
		const sensibilidade = 1.5; // ajuste fino da movimentação
		final dx = delta.dx * sensibilidade;
		final dy = delta.dy * sensibilidade;
		enviarMovimento(dx, dy);
	}

	@override
	void clicar(String tipo) async {
		String comando = 'click';

		// switch (tipo) {
		//   case 'esquerdo':
		//     comando = 'click';
		//     break;
		//   case 'direito':
		//     comando = 'right_click';
		//     break;
		//   case 'duplo':
		//     comando = 'double_click';
		//     break;
		// }

		try {
			final url = Uri.parse('$ipServidor/controle/$comando');
			await http.get(url);
			debugPrint('Clique $tipo enviado');
		} catch (e) {
			debugPrint('Erro ao clicar ($tipo): $e');
		}
	}

}