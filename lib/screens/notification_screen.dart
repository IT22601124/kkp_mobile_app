import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  final bool isDarkMode;

  const NotificationScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> dummyNotifications = [
      {
        'title': 'New Route Assigned',
        'body': 'Admin has assigned you to Dampola Route (R-01) for today.',
        'time': '10 mins ago',
        'icon': Icons.route,
        'color': AppColors.emeraldSuccess,
        'isRead': false,
      },
      {
        'title': 'Credit Limit Warning',
        'body': 'Saman Stores is nearing their maximum credit limit of LKR 100,000.',
        'time': '1 hour ago',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.amberWarning,
        'isRead': false,
      },
      {
        'title': 'Daily Target Update',
        'body': 'You have achieved 90% of your LKR 50,000 target for today!',
        'time': '3 hours ago',
        'icon': Icons.trending_up,
        'color': AppColors.primaryOrange,
        'isRead': true,
      },
      {
        'title': 'Stock Replenished',
        'body': 'Your stock request for 4G SIM cards has been approved and allocated.',
        'time': 'Yesterday',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.cyanAccent,
        'isRead': true,
      },
      {
        'title': 'System Maintenance',
        'body': 'Backend systems will be down for 15 minutes tonight at 12:00 AM.',
        'time': '2 days ago',
        'icon': Icons.build_circle_outlined,
        'color': AppColors.roseDanger,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            icon: const Icon(Icons.done_all, color: AppColors.primaryOrange),
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: SafeArea(
        child: dummyNotifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                    const SizedBox(height: 16),
                    Text(
                      'No new notifications',
                      style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dummyNotifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = dummyNotifications[index];
                  final bool isRead = notif['isRead'];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isRead
                            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                            : notif['color'].withAlpha(100),
                        width: isRead ? 1 : 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notif['color'].withAlpha(38),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notif['icon'], color: notif['color'], size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['body'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notif['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSub : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
