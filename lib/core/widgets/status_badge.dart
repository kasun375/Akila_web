import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'approved':
        bg = AppColors.success.withOpacity(0.12);
        fg = AppColors.success;
        break;
      case 'pending':
        bg = AppColors.warning.withOpacity(0.12);
        fg = AppColors.warning;
        break;
      case 'failed':
      case 'rejected':
      case 'overdue':
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.textLight.withOpacity(0.12);
        fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
