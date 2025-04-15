import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:joy_controle/telas/tela_inicial.dart';

void main() async {
	await dotenv.load();
	WidgetsFlutterBinding.ensureInitialized();
	runApp(const ControleJoyApp());
}

class ControleJoyApp extends StatelessWidget {
	const ControleJoyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'Controle Joy',
			theme: ThemeData.dark(),
			home: const TelaInicial(),
		);
	}
}