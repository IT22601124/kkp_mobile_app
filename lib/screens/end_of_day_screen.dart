import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EndOfDayScreen extends StatelessWidget {
  final VoidCallback onEndTripSuccess;

  const EndOfDayScreen({super.key, required this.onEndTripSuccess});

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
              // DSR Daily Settlement Sheet Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.12),
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
                          'DSR DAILY SETTLEMENT SHEET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextSub,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Dampola Route\n(22/08/2026)',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryOrange,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSuccess.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emeraldSuccess.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Audited 0\nVariance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.emeraldSuccess,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Info Note Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.cyanAccent, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Auto-Balanced Real-Time from Field Sales. Read-Only Ledger Ready for Submission.',
                        style: TextStyle(fontSize: 12, color: AppColors.cyanAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Product Stock & Sales Matrix
              const Text(
                '1. Product Stock & Sales Matrix',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.cyanAccent),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // Table Header
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Text('PRODUCT\nITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(child: Text('OPEN\n(YEST)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(child: Text('NEW\n(+)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(child: Text('SOLD\n(-)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(flex: 2, child: Text('REVENUE', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildMatrixRow('CARD-100', '30', '500', '30', 'LKR 2,880', isDark),
                    const Divider(height: 16),
                    _buildMatrixRow('CARD-500', '430', '0', '30', 'LKR 4,579.20', isDark),
                    const Divider(height: 16),
                    _buildMatrixRow('RELOAD-EASY', '117.1K', '0', '110K', 'LKR 110,000', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Cash Note Denomination Ledger
              const Text(
                '2. Cash Note Denomination Ledger',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.cyanAccent),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildCashRow('Rs. 5,000 Notes (8 Notes)', 'LKR 40,000.00', isDark),
                    const SizedBox(height: 8),
                    _buildCashRow('Rs. 1,000 Notes (5 Notes)', 'LKR 5,000.00', isDark),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'TOTAL PHYSICAL CASH\nCOLLECTED:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess),
                        ),
                        Text(
                          'LKR 45,000.00',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.emeraldSuccess),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Shop Credit Reconciliation
              const Text(
                '3. Shop Credit Reconciliation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.purpleAccent),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildReconRow('Prior Credit Balance:', 'LKR 315,650', isDark, Colors.white),
                    const SizedBox(height: 8),
                    _buildReconRow('Today Issued (+):', '+LKR 9,500', isDark, AppColors.primaryOrange),
                    const SizedBox(height: 8),
                    _buildReconRow('Today Collected (-):', '-LKR 25,500', isDark, AppColors.emeraldSuccess),
                    const Divider(height: 20),
                    _buildReconRow('ENDING SHOP CREDIT:', 'LKR 299,650.00', isDark, AppColors.purpleAccent, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Submit Settlement Sheet'),
                        content: const Text('Submit pre-balanced settlement sheet to agent?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onEndTripSuccess();
                            },
                            child: const Text('Confirm & Submit'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text('Submit Pre-Balanced Sheet to Agent', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixRow(String item, String open, String newAdded, String sold, String revenue, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 2, child: Text(item, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain))),
        Expanded(child: Text(open, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSub))),
        Expanded(child: Text(newAdded, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSub))),
        Expanded(child: Text(sold, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roseDanger))),
        Expanded(flex: 2, child: Text(revenue, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess))),
      ],
    );
  }

  Widget _buildCashRow(String title, String amount, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess)),
      ],
    );
  }

  Widget _buildReconRow(String title, String amount, bool isDark, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
        Text(amount, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
