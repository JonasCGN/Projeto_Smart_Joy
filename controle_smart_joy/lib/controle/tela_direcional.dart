import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joy_controle/class/interface_control.dart';

class TelaDirecional extends StatefulWidget {
  final String ipServidor;
  final InterfaceControl interfaceControl;
  const TelaDirecional({super.key, required this.ipServidor, required this.interfaceControl});

  @override
  TelaDirecionalState createState() => TelaDirecionalState();
}

class TelaDirecionalState extends State<TelaDirecional> {
	Offset? _lastPanPosition;
	DateTime? _lastTapTime;
	Timer? _doubleTapTimer;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Controle Direcional')),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						ElevatedButton(
							onPressed: () => widget.interfaceControl.moverMouse('up'),
							child: const Icon(Icons.keyboard_arrow_up, size: 48),
						),
						const SizedBox(height: 20),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								ElevatedButton(
									onPressed: () => widget.interfaceControl.moverMouse('left'),
									child: const Icon(Icons.keyboard_arrow_left, size: 48),
								),
								const SizedBox(width: 20),
								ElevatedButton(
									onPressed: () => widget.interfaceControl.clicar('esquerdo'),
									child: const Text('🖱️', style: TextStyle(fontSize: 24)),
								),
								const SizedBox(width: 20),
								ElevatedButton(
									onPressed: () => widget.interfaceControl.moverMouse('right'),
									child: const Icon(Icons.keyboard_arrow_right, size: 48),
								),
							],
						),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: () => widget.interfaceControl.moverMouse('down'),
							child: const Icon(Icons.keyboard_arrow_down, size: 48),
						),
						const SizedBox(height: 30),
						Expanded(
							child: GestureDetector(
								onPanStart: (details) {
									_lastPanPosition = details.localPosition;
								},
								onPanUpdate: (details) {
								if (_lastPanPosition != null) {
									final delta = details.localPosition - _lastPanPosition!;
									widget.interfaceControl.moverMouseDelta(delta);
									_lastPanPosition = details.localPosition;
								}
								},
								onPanEnd: (_) {
									_lastPanPosition = null;
								},
								onTap: () {
									final now = DateTime.now();
									if (_lastTapTime != null &&
										now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
										widget.interfaceControl.clicar('duplo');
										_doubleTapTimer?.cancel();
									} else {
										_doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
											widget.interfaceControl.clicar('esquerdo');
										});
									}
									_lastTapTime = now;
								},
								onLongPress: () => widget.interfaceControl.clicar('direito'),
								child: Container(
									margin: const EdgeInsets.all(16),
									decoration: BoxDecoration(
										color: Colors.grey[900],
										borderRadius: BorderRadius.circular(20),
										boxShadow: const [
										BoxShadow(
											color: Colors.black26,
											blurRadius: 10,
											offset: Offset(0, 4),
										)
										],
									),
									child: const Center(
										child: Text(
										'Touchpad Virtual',
										style: TextStyle(color: Colors.white70, fontSize: 18),
										),
									),
								),
							),
						),
					],
				),
			),
		);
	}
}