import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../dio/dio_client.dart';
import '../resources/api_routes.dart';

class RepInboxNotification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  const RepInboxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  factory RepInboxNotification.fromJson(Map<String, dynamic> json) =>
      RepInboxNotification(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        readAt: json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at'] as String).toLocal(),
      );

  RepInboxNotification withReadAt(DateTime value) => RepInboxNotification(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: value,
  );
}

class RepNotificationInbox extends ChangeNotifier {
  final DioClient _client;
  RepNotificationInbox({DioClient? client}) : _client = client ?? DioClient();

  List<RepInboxNotification> items = [];
  int unreadCount = 0;
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  bool markingAll = false;
  String? error;
  int _nextPage = 1;
  bool _disposed = false;
  bool _refreshPending = false;
  int _readVersion = 0;
  final Set<int> _marking = {};

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _message(Object exception) {
    if (exception is DioException && exception.response?.statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    return 'Unable to update notifications. Check your connection and try again.';
  }

  Future<void> refresh() => _load(false);
  Future<void> loadMore() => _load(true);

  Future<void> _load(bool more) async {
    if (_disposed || (more && !hasMore)) return;
    if (loading || loadingMore) {
      if (!more) _refreshPending = true;
      return;
    }
    if (more) {
      loadingMore = true;
    } else {
      loading = true;
    }
    error = null;
    _notify();
    final readVersion = _readVersion;
    try {
      final response = await _client.get(
        ApiRoutes.notificationsUrl,
        queryParameters: {'page': more ? _nextPage : 1},
      );
      if (_disposed) return;
      if (readVersion != _readVersion) {
        _refreshPending = true;
        return;
      }
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      final page = Map<String, dynamic>.from(data['notifications'] as Map);
      final incoming = (page['data'] as List)
          .map(
            (item) => RepInboxNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      if (more) {
        final existingIds = items.map((item) => item.id).toSet();
        items = [
          ...items,
          ...incoming.where((item) => !existingIds.contains(item.id)),
        ];
      } else {
        items = incoming;
      }
      unreadCount = (data['unread_count'] as num).toInt();
      _nextPage = (page['current_page'] as num).toInt() + 1;
      hasMore = _nextPage <= (page['last_page'] as num).toInt();
    } catch (exception) {
      if (!_disposed) error = _message(exception);
    } finally {
      loading = false;
      loadingMore = false;
      _notify();
      if (_refreshPending && !_disposed) {
        _refreshPending = false;
        await refresh();
      }
    }
  }

  Future<void> markRead(RepInboxNotification notification) async {
    if (_disposed ||
        markingAll ||
        notification.readAt != null ||
        !_marking.add(notification.id)) {
      return;
    }
    try {
      final response = await _client.post(
        '${ApiRoutes.notificationsUrl}/${notification.id}/read',
      );
      if (_disposed) return;
      final data = response.data['data'];
      final readAt = DateTime.parse(data['read_at'] as String).toLocal();
      _readVersion++;
      items = items
          .map(
            (item) =>
                item.id == notification.id ? item.withReadAt(readAt) : item,
          )
          .toList();
      unreadCount = (data['unread_count'] as num).toInt();
      error = null;
    } catch (exception) {
      if (!_disposed) error = _message(exception);
    } finally {
      _marking.remove(notification.id);
      _notify();
    }
  }

  Future<void> markAllRead() async {
    if (_disposed || markingAll || unreadCount == 0) return;
    markingAll = true;
    final unreadIds = items
        .where((item) => item.readAt == null)
        .map((item) => item.id)
        .toSet();
    _notify();
    try {
      final response = await _client.post(
        '${ApiRoutes.notificationsUrl}/read-all',
      );
      if (_disposed) return;
      final now = DateTime.now();
      _readVersion++;
      items = items
          .map(
            (item) => unreadIds.contains(item.id) ? item.withReadAt(now) : item,
          )
          .toList();
      unreadCount = (response.data['data']['unread_count'] as num).toInt();
      error = null;
    } catch (exception) {
      if (!_disposed) error = _message(exception);
    } finally {
      markingAll = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
