import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

class OutletCard extends StatelessWidget {
  final Outlet outlet;
  final VoidCallback onCheckIn;
  final VoidCallback onSell;

  const OutletCard({
    super.key,
    required this.outlet,
    required this.onCheckIn,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outlet.shopName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${outlet.ownerName} • ${outlet.phone}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip.fromOutletStatus(outlet.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  outlet.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (outlet.outstandingBalance > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Outstanding Balance: LKR ${outlet.outstandingBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.roseDanger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCheckIn,
                  icon: const Icon(Icons.pin_drop_outlined, size: 16),
                  label: const Text('Check In'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: const BorderSide(color: AppColors.primaryOrange),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSell,
                  icon: const Icon(Icons.point_of_sale, size: 16),
                  label: const Text('Issue Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
