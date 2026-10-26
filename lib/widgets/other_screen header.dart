
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kkp_rep_mobile_app/provider/auth_provider.dart';
import 'package:kkp_rep_mobile_app/services/notification_service.dart';
import 'package:kkp_rep_mobile_app/services/rep_notification_inbox.dart';

import '../screens/user_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_theme.dart';

class OtherScreenHeader extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool isKeepTheme;
  final String title;

  const OtherScreenHeader({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.isKeepTheme = false,
    required this.title,
  });

  @override
  State<OtherScreenHeader> createState() =>
      _OtherScreenHeaderState();
}

class _OtherScreenHeaderState extends State<OtherScreenHeader>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _inboxOpen = false;

  final RepNotificationInbox _notificationInbox =
  RepNotificationInbox();

  StreamSubscription<void>? _notificationSubscription;
  Timer? _notificationTimer;

  final NotificationService _notificationService =
  NotificationService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadUserData();
      _initializeNotifications();
    });
  }

  // ==========================================
  // USER DATA
  // ==========================================

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user != null) return;

    setState(() => _isLoading = true);

    try {
      await authProvider.checkSavedToken();
    } catch (e) {
      debugPrint('Header user loading error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================
  // NOTIFICATION INITIALIZATION
  // ==========================================

  void _initializeNotifications() {
    _notificationService.inboxRequested
        .addListener(_handleInboxRequest);

    _notificationSubscription =
        _notificationService.inboxUpdates.listen((_) {
          if (!mounted) return;
          _refreshNotifications();
        });

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (!mounted) return;

        if (WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.resumed &&
            !_inboxOpen) {
          _refreshNotifications();
        }
      },
    );

    // Initial notification loading
    _refreshNotifications();

    // Handle pending notification tap
    _handleInboxRequest();
  }

  // ==========================================
  // REFRESH NOTIFICATIONS
  // ==========================================

  void _refreshNotifications() {
    if (!mounted) return;

    _notificationInbox.refresh();
  }

  // ==========================================
  // PUSH NOTIFICATION TAP
  // ==========================================

  void _handleInboxRequest() {
    if (!mounted) return;

    if (!_notificationService.inboxRequested.value) {
      return;
    }

    _notificationService.inboxRequested.value = false;

    _openInbox();
  }

  // ==========================================
  // OPEN NOTIFICATION SCREEN
  // ==========================================

  Future<void> _openInbox() async {
    if (!mounted) return;

    if (_inboxOpen) {
      _refreshNotifications();
      return;
    }

    _inboxOpen = true;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NotificationsScreen(
            inbox: _notificationInbox,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Notification navigation error: $e');
    } finally {
      _inboxOpen = false;

      if (mounted) {
        _refreshNotifications();
      }
    }
  }

  // ==========================================
  // APP LIFECYCLE
  // ==========================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
      _handleInboxRequest();
    }
  }

  // ==========================================
  // OPEN PROFILE
  // ==========================================

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _notificationTimer?.cancel();
    _notificationSubscription?.cancel();

    _notificationService.inboxRequested
        .removeListener(_handleInboxRequest);

    _notificationInbox.dispose();

    super.dispose();
  }

  // ==========================================
  // BUILD UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextMain
        : AppColors.lightTextMain;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          final userName = user?.name ?? 'DSR Rep';
          final initial = userName.isNotEmpty
              ? userName[0].toUpperCase()
              : 'R';

          final userSubtext = user?.phone ?? '';
          final avatarUrl = user?.avatarUrl?.trim();

          return Row(
            children: [

              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 0
                  ),
                ),
              ),

              // ====================================
              // NOTIFICATION ICON + UNREAD COUNT
              // ====================================
              AnimatedBuilder(
                animation: _notificationInbox,
                builder: (context, _) {
                  final unreadCount =
                      _notificationInbox.unreadCount;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _openInbox,
                        tooltip: 'Notifications',
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 27,
                          color: textColor,
                        ),
                        constraints:
                        const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                        padding: EdgeInsets.zero,
                      ),

                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            constraints:
                            const BoxConstraints(
                              minWidth: 17,
                              minHeight: 17,
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                              AppColors.roseDanger,
                              borderRadius:
                              BorderRadius.circular(
                                10,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBg
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              unreadCount > 99
                                  ? '99+'
                                  : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // ====================================
              // THEME TOGGLE
              // ====================================
              if (widget.isKeepTheme) ...[
                const SizedBox(width: 2),
                IconButton(
                  icon: Icon(
                    widget.isDarkMode
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    size: 26,
                    color: textColor,
                  ),
                  tooltip: 'Toggle theme',
                  onPressed: widget.onToggleTheme,
                  constraints:
                  const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],

              const SizedBox(width: 8),

              // ====================================
              // PROFILE AVATAR
              // ====================================
              GestureDetector(
                onTap: _openProfile,
                child: Container(
                  width: 38,
                  height: 38,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Center(
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : avatarUrl != null &&
                      avatarUrl.isNotEmpty
                      ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, error, stack) =>
                        _buildInitial(
                          initial,
                        ),
                  )
                      : _buildInitial(initial),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
