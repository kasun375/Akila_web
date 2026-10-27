import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final student = auth.user;
    final myPayments = paymentProvider.getPaymentsForStudent(student?.uid ?? '');

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Payment History', style: AppStyles.h2(context).copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Track all online payment gateway transactions and monthly class fee receipts.', style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            if (myPayments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textLight),
                    SizedBox(height: 12),
                    Text('No payment records found yet.', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myPayments.length,
                itemBuilder: (context, index) {
                  final p = myPayments[index];
                  final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(p.timestamp);

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.mintSoft,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.mintBorder),
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(
                                  'Ref: ${p.payherePaymentId} • ${p.month}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppStyles.formatLKR(p.amount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                              ),
                              const SizedBox(height: 4),
                              StatusBadge(status: p.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
