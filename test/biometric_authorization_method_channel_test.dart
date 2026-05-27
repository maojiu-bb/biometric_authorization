import 'package:biometric_authorization/biometric_authorization_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelBiometricAuthorization', () {
    const channel = MethodChannel('biometric_authorization');
    final log = <MethodCall>[];
    late MethodChannelBiometricAuthorization platform;

    setUp(() {
      platform = MethodChannelBiometricAuthorization();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'stopAuth') {
          return true;
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();
    });

    test('stopAuth delegates to the platform channel', () async {
      final result = await platform.stopAuth();

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'stopAuth');
      expect(log.single.arguments, isNull);
    });
  });
}
