import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kkp_rep_mobile_app/dio/dio_client.dart';
import 'package:kkp_rep_mobile_app/services/rep_notification_inbox.dart';

class InboxAdapter implements HttpClientAdapter {
  final Future<Map<String, dynamic>> Function(RequestOptions) respond;
  InboxAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final data = await respond(options);
    return ResponseBody.fromString(
      jsonEncode({'success': true, 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> item(int id) => {
  'id': id,
  'title': 'Title $id',
  'body': 'Message $id',
  'created_at': '2026-10-19T08:00:00Z',
  'read_at': null,
};
Map<String, dynamic> page(
  List<Map<String, dynamic>> items, {
  int current = 1,
  int last = 1,
  int unread = 2,
}) => {
  'notifications': {'data': items, 'current_page': current, 'last_page': last},
  'unread_count': unread,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'auth_token': 'unit-test-token',
    }),
  );

  test(
    'loads saved notifications and paginates without duplicating rows',
    () async {
      final client = DioClient();
      client.dio.httpClientAdapter = InboxAdapter(
        (options) async => options.queryParameters['page'] == 1
            ? page([item(3), item(2)], last: 2, unread: 3)
            : page([item(2), item(1)], current: 2, last: 2, unread: 3),
      );
      final inbox = RepNotificationInbox(client: client);
      addTearDown(inbox.dispose);
      await inbox.refresh();
      expect(inbox.items.map((item) => item.id), [3, 2]);
      expect(inbox.unreadCount, 3);
      expect(inbox.hasMore, isTrue);
      await inbox.loadMore();
      expect(inbox.items.map((item) => item.id), [3, 2, 1]);
      expect(inbox.hasMore, isFalse);
    },
  );

  test(
    'read and read-all actions persist through the API and update the badge',
    () async {
      final client = DioClient();
      var readRequests = 0;
      client.dio.httpClientAdapter = InboxAdapter((options) async {
        if (options.path.endsWith('/read-all')) return {'unread_count': 0};
        if (options.path.endsWith('/read')) {
          readRequests++;
          expect(options.method, 'POST');
          return {
            'id': 2,
            'read_at': '2026-10-19T09:00:00Z',
            'unread_count': 1,
          };
        }
        return page([item(2), item(1)]);
      });
      final inbox = RepNotificationInbox(client: client);
      addTearDown(inbox.dispose);
      await inbox.refresh();
      await inbox.markRead(inbox.items.first);
      expect(inbox.items.first.readAt, isNotNull);
      expect(inbox.unreadCount, 1);
      await inbox.markRead(inbox.items.first);
      expect(readRequests, 1);
      await inbox.markAllRead();
      expect(inbox.items.every((item) => item.readAt != null), isTrue);
      expect(inbox.unreadCount, 0);
    },
  );

  test(
    'a failed refresh retains already loaded notifications and offers retry',
    () async {
      final client = DioClient();
      var offline = false;
      client.dio.httpClientAdapter = InboxAdapter((options) async {
        if (offline) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return page([item(1)], unread: 1);
      });
      final inbox = RepNotificationInbox(client: client);
      addTearDown(inbox.dispose);
      await inbox.refresh();
      offline = true;
      await inbox.refresh();
      expect(inbox.items.single.id, 1);
      expect(inbox.error, isNotNull);
      expect(inbox.loading, isFalse);
      offline = false;
      await inbox.refresh();
      expect(inbox.error, isNull);
    },
  );

  test(
    'an API response arriving after logout cannot refill the disposed inbox',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final client = DioClient();
      client.dio.httpClientAdapter = InboxAdapter((_) => pending.future);
      final inbox = RepNotificationInbox(client: client);
      final request = inbox.refresh();
      inbox.dispose();
      pending.complete(page([item(1)]));
      await request;
      expect(inbox.items, isEmpty);
    },
  );

  test('an older refresh cannot undo a notification marked read', () async {
    final client = DioClient();
    final olderRefresh = Completer<Map<String, dynamic>>();
    final refreshStarted = Completer<void>();
    var gets = 0;
    client.dio.httpClientAdapter = InboxAdapter((options) async {
      if (options.method == 'POST') {
        return {'id': 1, 'read_at': '2026-10-19T09:00:00Z', 'unread_count': 0};
      }
      gets++;
      if (gets == 2) {
        refreshStarted.complete();
        return olderRefresh.future;
      }
      return page([
        {...item(1), if (gets > 2) 'read_at': '2026-10-19T09:00:00Z'},
      ], unread: gets > 2 ? 0 : 1);
    });
    final inbox = RepNotificationInbox(client: client);
    addTearDown(inbox.dispose);
    await inbox.refresh();
    final refresh = inbox.refresh();
    await refreshStarted.future;
    await inbox.markRead(inbox.items.single);
    olderRefresh.complete(page([item(1)], unread: 1));
    await refresh;
    expect(inbox.items.single.readAt, isNotNull);
    expect(inbox.unreadCount, 0);
  });
}
