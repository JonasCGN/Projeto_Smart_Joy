import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluetooth_serial_method_channel.dart';

abstract class BluetoothSerialPlatform extends PlatformInterface {
  /// Constructs a BluetoothSerialPlatform.
  BluetoothSerialPlatform() : super(token: _token);

  static final Object _token = Object();

  static BluetoothSerialPlatform _instance = MethodChannelBluetoothSerial();

  /// The default instance of [BluetoothSerialPlatform] to use.
  ///
  /// Defaults to [MethodChannelBluetoothSerial].
  static BluetoothSerialPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BluetoothSerialPlatform] when
  /// they register themselves.
  static set instance(BluetoothSerialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
