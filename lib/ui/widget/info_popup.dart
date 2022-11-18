// import 'dart:async';
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:mx_core/mx_core.dart' hide Path;
// import 'package:mx_core/popup/impl.dart';
// import 'package:package_info_plus/package_info_plus.dart';
//
// class InfoPopup extends StatefulWidget {
//   final Widget child;
//   final InfoPopupAction? controller;
//
//   const InfoPopup({
//     Key? key,
//     required this.child,
//     this.controller,
//   }) : super(key: key);
//
//   @override
//   _InfoPopupState createState() => _InfoPopupState();
// }
//
// class _InfoPopupState extends State<InfoPopup> {
//   final int _detectTapCount = 3;
//   double _currentTap = 0;
//   PopupController? _popupController;
//
//   Timer? timer;
//
//   @override
//   void initState() {
//     widget.controller?._bind(
//       show: () async {
//         _showInfo();
//       },
//       hide: () async {
//         var current = _popupController;
//         _popupController = null;
//         await current?.remove();
//       },
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       onPointerUp: (pointer) {
//         _saveTapUp();
//       },
//       onPointerDown: (pointer) {
//         _saveTapDown();
//       },
//       child: widget.child,
//     );
//   }
//
//   void _saveTapDown() {
//     timer?.cancel();
//     timer = Timer(const Duration(milliseconds: 100), () {
//       _currentTap = 0;
//     });
//   }
//
//   void _saveTapUp() {
//     if (timer?.isActive == true) {
//       _currentTap++;
//     }
//
//     timer?.cancel();
//
//     if (_currentTap >= _detectTapCount) {
//       _currentTap = 0;
//       _showInfo();
//     } else {
//       timer = Timer(const Duration(milliseconds: 300), () {
//         _currentTap = 0;
//       });
//     }
//   }
//
//   void _showInfo() {
//     if (_popupController != null) {
//       return;
//     }
//     _popupController = Popup.showOverlay(
//       builder: (controller) {
//         return GestureDetector(
//           onTap: () => controller.remove(),
//           child: const _DeviceInfo(),
//         );
//       },
//       option: PopupOption(
//         maskColor: Colors.black.withAlpha(50),
//       ),
//       onTapBack: (controller) => controller.remove(),
//       onTapSpace: (controller) => controller.remove(),
//       hitRule: HitRule.intercept,
//     )..registerRemoveEventCallback(
//         onStart: () {
//           _popupController = null;
//         },
//       );
//   }
//
//   @override
//   void dispose() {
//     widget.controller?._unbind();
//     _popupController?.remove();
//     _popupController = null;
//     timer?.cancel();
//     super.dispose();
//   }
// }
//
// class _DeviceInfo extends StatefulWidget {
//   const _DeviceInfo();
//
//   @override
//   __DeviceInfoState createState() => __DeviceInfoState();
// }
//
// class __DeviceInfoState extends State<_DeviceInfo> {
//   var infoPlugin = DeviceInfoPlugin();
//
//   @override
//   Widget build(BuildContext context) {
// //    return Container();
//     return Align(
//       alignment: Alignment.center,
//       child: Card(
//         color: Colors.white,
//         child: FutureBuilder<PackageInfo>(
//           future: PackageInfo.fromPlatform(),
//           builder: (context, snapshot) {
//             var packageInfo = snapshot.data;
//             return Padding(
//               padding: const EdgeInsets.all(10),
//               child: Platform.isAndroid
//                   ? FutureBuilder<AndroidDeviceInfo>(
//                       future: infoPlugin.androidInfo,
//                       builder: (context, snapshot) {
//                         var androidInfo = snapshot.data;
//                         if (androidInfo == null || packageInfo == null) {
//                           return Container(
//                             child: Loading.circle(
//                               color: Colors.blueAccent,
//                             ),
//                           );
//                         }
//                         return Text('''
// ═══════ 裝置資訊 ═══════
//
// 模組 ${androidInfo.model}
// 硬體 ${androidInfo.hardware}
// 版本 ${androidInfo.version.release}
// 號碼 ${androidInfo.version.sdkInt}
// 標示 ${androidInfo.tags}
// 製造商 ${androidInfo.manufacturer}
//
// ═══════ 軟體資訊 ═══════
//
// 名稱 ${packageInfo.appName}
// 包名 ${packageInfo.packageName}
// 版本 ${packageInfo.version}+${packageInfo.buildNumber}
// 模式 ${kReleaseMode ? '正式' : '測試'}
//                         ''');
//                       },
//                     )
//                   : FutureBuilder<IosDeviceInfo>(
//                       future: infoPlugin.iosInfo,
//                       builder: (context, snapshot) {
//                         var iosInfo = snapshot.data;
//                         if (iosInfo == null || packageInfo == null) {
//                           return Container(
//                             child: Loading.circle(color: Colors.blueAccent),
//                           );
//                         }
//                         return Text('''
// ═══════ 裝置資訊 ═══════
//
// 模組 ${iosInfo.model}
// 硬體 ${iosInfo.utsname.machine}
//
// ═══════ 軟體資訊 ═══════
//
// 名稱 ${packageInfo.appName}
// 包名 ${packageInfo.packageName}
// 版本 ${packageInfo.version}+${packageInfo.buildNumber}
// 模式 ${kReleaseMode ? '正式' : '測試'}
//                         ''');
//                       },
//                     ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class InfoPopupAction {
//   Future<void> Function()? _show;
//   Future<void> Function()? _hide;
//
//   Future<void> show() async {
//     if (_show != null) {
//       return _show!.call();
//     }
//   }
//
//   Future<void> hide() async {
//     if (_hide != null) {
//       return _hide!.call();
//     }
//   }
//
//   @protected
//   void _bind({Future<void> Function()? show, Future<void> Function()? hide}) {
//     _show = show;
//     _hide = hide;
//   }
//
//   @protected
//   void _unbind() {
//     _show = null;
//     _hide = null;
//   }
// }
