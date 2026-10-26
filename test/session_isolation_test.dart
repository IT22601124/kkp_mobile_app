import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/provider/session_notifier.dart';

class SessionAdapter implements HttpClientAdapter {
  final Future<void> Function(RequestOptions) respond;
  SessionAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await respond(options);
    return ResponseBody.fromString(
      jsonEncode({'success': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class DetachedProvider extends SessionNotifier {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DioClient().clearAuthToken();
  });

  test(
    'existing API clients use the current account token and clear it on logout',
    () async {
      final auth = DioClient();
      final data = DioClient();
      final headers = <String?>[];
      data.dio.httpClientAdapter = SessionAdapter((options) async {
        headers.add(options.headers['Authorization'] as String?);
      });
      auth.setAuthToken('account-a');
      await data.get('mobile/sales');
      auth.clearAuthToken();
      await data.get('mobile/sales');
      auth.setAuthToken('account-b');
      await data.get('mobile/sales');
      expect(headers, ['Bearer account-a', null, 'Bearer account-b']);
    },
  );

  test(
    'a response from the previous account is rejected after switching accounts',
    () async {
      final auth = DioClient();
      final client = DioClient();
      final started = Completer<void>();
      final finish = Completer<void>();
      client.dio.httpClientAdapter = SessionAdapter((options) async {
        started.complete();
        await finish.future;
      });
      auth.setAuthToken('account-a');
      final request = client.get('mobile/sales');
      final assertion = expectLater(
        request,
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      await started.future;
      auth.setAuthToken('account-b');
      finish.complete();
      await assertion;
    },
  );

  test(
    'a request finishing after session disposal cannot notify detached screens',
    () {
      final provider = DetachedProvider();
      var calls = 0;
      provider.addListener(() => calls++);
      provider.dispose();
      provider.notifyListeners();
      expect(calls, 0);
    },
  );
}
