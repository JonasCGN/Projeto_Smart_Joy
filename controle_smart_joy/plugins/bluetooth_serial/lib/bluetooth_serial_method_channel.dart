import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_serial_platform_interface.dart';

/// An implementation of [BluetoothSerialPlatform] that uses method channels.
class MethodChannelBluetoothSerial extends BluetoothSerialPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bluetooth_serial');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
