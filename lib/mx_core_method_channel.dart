import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mx_core_platform_interface.dart';

/// An implementation of [MxCorePlatform] that uses method channels.
class MethodChannelMxCore extends MxCorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mx_core');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
