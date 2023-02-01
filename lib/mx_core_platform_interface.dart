import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mx_core_method_channel.dart';

abstract class MxCorePlatform extends PlatformInterface {
  /// Constructs a MxCorePlatform.
  MxCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static MxCorePlatform _instance = MethodChannelMxCore();

  /// The default instance of [MxCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelMxCore].
  static MxCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MxCorePlatform] when
  /// they register themselves.
  static set instance(MxCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
