import 'package:flutter/material.dart';
import 'package:smart_joy/bluetooth/server/bluetooth_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_joy/bluetooth/server/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  startBluetoothServerNativeThreaded();
  final mac = getBluetoothMacAddress();
  debugPrint('[JOY SERVER] Endereço MAC Bluetooth: $mac');

  runApp(JoyServerApp(macAddress: mac));
}

class JoyServerApp extends StatelessWidget {
	final String macAddress;
	const JoyServerApp({super.key, required this.macAddress});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Joy Server',
			theme: ThemeData.light(),
			home: ServerHomePage(macAddress: macAddress),
		);
	}
}