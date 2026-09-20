import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final DsrRepProfile profile;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final VoidCallback onLogout;

  const ProfileSettingsScreen({
    super.key,
    required this.profile,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'shop': 'Saman Stores',
      'time': '09:15 AM',
      'items': 'CARD-100 (50u), SIM-4G (10u)',
      'amount': 'LKR 7,300',
      'payment': 'Split (Cash/Slip)',
      'color': AppColors.emeraldSuccess,
    },
    {
      'shop': 'Lanka Traders',
      'time': '08:45 AM',
      'items': 'CARD-500 (15u), Reload (10K)',
      'amount': 'LKR 17,200',
      'payment': 'Cash Paid',
      'color': AppColors.emeraldSuccess,
    },
    {
      'shop': 'Shanika Comm.',
      'time': 'Yesterday',
      'items': 'CARD-100 (100u), SIM-4G (20u)',
      'amount': 'LKR 14,600',
      'payment': 'Shop Credit',
      'color': AppColors.purpleAccent,
    },
    {
      'shop': 'New City Mobile',
      'time': 'Yesterday',
      'items': 'CARD-500 (10u), Reload (5K)',
      'amount': 'LKR 9,800',
      'payment': 'EzCash Wallet',
      'color': AppColors.primaryOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Header matching screenshot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profile.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: AppColors.cyanAccent),
                              SizedBox(width: 4),
                              Text(
                                'Dampola Route (R-01)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.cyanAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, size: 20),
                              onPressed: () {},
                              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.roseDanger,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '2',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: IconButton(
                          icon: Icon(widget.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round, size: 20),
                          onPressed: widget.onToggleTheme,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Top Banner Card: Sales Summary & History Hub
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cyanAccent.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanAccent.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SALES SUMMARY & HISTORY HUB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextSub,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Field Performance &\nReports',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cyanAccent,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Audited\nLogs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Cards Row (Total Sales Revenue & Rep Commissions)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SALES REVENUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'LKR 45,000.00',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '14 Completed Bills',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REP COMMISSIONS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'LKR 2,250.00',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.purpleAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '5.0% Avg Rate',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Export Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting PDF Report...')),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('Export PDF Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roseDanger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting Excel CSV Report...')),
                        );
                      },
                      icon: const Icon(Icons.table_chart, size: 16),
                      label: const Text('Export Excel CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sales Transaction History Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sales Transaction History',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkInput : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            children: const [
                              Text('Today (22 Aug)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Text('TIME / SHOP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(flex: 2, child: Text('ITEMS SOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(child: Text('AMOUNT', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(flex: 2, child: Text('PAYMENT', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                      ],
                    ),
                    const Divider(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 16,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['shop'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain)),
                                  const SizedBox(height: 2),
                                  Text(tx['time'] as String, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSub)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                tx['items'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.darkTextSub),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tx['amount'] as String,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tx['color'] as Color),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                tx['payment'] as String,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tx['color'] as Color),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text('Are you sure you want to log out of your account?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onLogout();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDanger),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.roseDanger,
                    side: const BorderSide(color: AppColors.roseDanger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('LOG OUT FROM APP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
