import 'package:flutter/material.dart';
import '../services/rep_notification_inbox.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final RepNotificationInbox inbox;
  const NotificationsScreen({super.key, required this.inbox});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.inbox.refresh();
    });
  }

  String _date(DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatMediumDate(value)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
  }

  void _open(RepInboxNotification notification) {
    widget.inbox.markRead(notification);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  _date(notification.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                SelectableText(
                  notification.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.inbox,
    builder: (context, _) {
      final inbox = widget.inbox;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(
              onPressed: inbox.unreadCount == 0 || inbox.markingAll
                  ? null
                  : inbox.markAllRead,
              child: const Text('Read all'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${inbox.unreadCount} unread · Announcements from your agent',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            if (inbox.error != null)
              MaterialBanner(
                content: Text(inbox.error!),
                actions: [
                  TextButton(
                    onPressed: inbox.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            if (inbox.loading) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: inbox.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: inbox.items.isEmpty
                      ? 1
                      : inbox.items.length + (inbox.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (inbox.items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 80,
                          horizontal: 24,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 56,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              inbox.loading
                                  ? 'Loading notifications…'
                                  : inbox.error != null
                                  ? 'Notifications could not be loaded.'
                                  : 'No notifications yet.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your agent’s announcements will appear here.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    if (index == inbox.items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: inbox.loadingMore
                              ? const CircularProgressIndicator()
                              : OutlinedButton(
                                  onPressed: inbox.loadMore,
                                  child: const Text('Load more'),
                                ),
                        ),
                      );
                    }
                    final item = inbox.items[index];
                    final unread = item.readAt == null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: unread
                              ? AppColors.primaryOrange
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryOrange.withValues(
                            alpha: .12,
                          ),
                          child: Icon(
                            unread
                                ? Icons.mark_email_unread_outlined
                                : Icons.drafts_outlined,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              item.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _date(item.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: unread
                            ? const Icon(
                                Icons.circle,
                                size: 9,
                                color: AppColors.primaryOrange,
                              )
                            : null,
                        onTap: () => _open(item),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
