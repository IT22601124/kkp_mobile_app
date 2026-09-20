import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusChip.fromOutletStatus(OutletStatus status) {
    switch (status) {
      case OutletStatus.visited:
        return const StatusChip(
          label: 'VISITED',
          backgroundColor: Color(0x2610B981),
          textColor: AppColors.emeraldSuccess,
        );
      case OutletStatus.invoiced:
        return const StatusChip(
          label: 'INVOICED',
          backgroundColor: Color(0x2606B6D4),
          textColor: AppColors.cyanAccent,
        );
      case OutletStatus.skipped:
        return const StatusChip(
          label: 'SKIPPED',
          backgroundColor: Color(0x26F43F5E),
          textColor: AppColors.roseDanger,
        );
      case OutletStatus.pending:
        return const StatusChip(
          label: 'PENDING',
          backgroundColor: Color(0x26F59E0B),
          textColor: AppColors.amberWarning,
        );
    }
  }

  factory StatusChip.fromPaymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const StatusChip(
          label: 'PAID',
          backgroundColor: Color(0x2610B981),
          textColor: AppColors.emeraldSuccess,
        );
      case PaymentStatus.partial:
        return const StatusChip(
          label: 'PARTIAL',
          backgroundColor: Color(0x26F59E0B),
          textColor: AppColors.amberWarning,
        );
      case PaymentStatus.pending:
        return const StatusChip(
          label: 'UNPAID',
          backgroundColor: Color(0x26F43F5E),
          textColor: AppColors.roseDanger,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
