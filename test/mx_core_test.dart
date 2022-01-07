import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mx_core/mx_core.dart';

void main() {
  // const MethodChannel channel = MethodChannel('futures_core');
  //

  // setUp(() {
  //   TestWidgetsFlutterBinding.ensureInitialized();
  //
  //   FuturesCore.settingEnv(
  //     projectCode: 'futures04',
  //     apiEnv: ApiEnv.mainChina,
  //     build: ProjectBuild.release,
  //     signUpAgent: SignUpAgent(ios: 'ios', android: 'android'),
  //     recordResponse: false,
  //   );
  //
  //   // HttpUtil().setProxy('192.168.0.126', 9000);
  //   // print('設置結束');
  // });
  //
  // testWidgets('login', (tester) async {
  //   await tester.runAsync(() async {
  //     final HttpClient client = HttpClient();
  //     final HttpClientRequest request =
  //     await client.getUrl(Uri.parse('https://google.com'));
  //
  //     final HttpClientResponse response = await request.close();
  //     print(response.statusCode);
  //   });
  // });

  // tearDown(() {
  //   channel.setMockMethodCallHandler(null);
  // });

  test('test', () async {
    final aa = 10.add(20.1);
    expect(aa, 30.1);
  });
}
