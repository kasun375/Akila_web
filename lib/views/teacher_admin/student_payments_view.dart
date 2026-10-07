import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';

class StudentPaymentsView extends StatelessWidget {
  const StudentPaymentsView({super.key});

  void _confirmClearAllPayments(BuildContext context, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Clear All Payments?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove all existing student payment records?\n\nThis action cannot be undone and will reset student monthly payment statuses to pending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await paymentProvider.clearAllPayments();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All student payments have been successfully removed.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePayment(BuildContext context, PaymentProvider paymentProvider, String paymentId, String studentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Payment Record'),
        content: Text('Are you sure you want to remove the payment record for $studentName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await paymentProvider.deletePayment(paymentId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment record for $studentName removed.')),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final enrollments = classProvider.enrollments;
    final payments = paymentProvider.payments;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Payments & Enrollment Tracker', style: AppStyles.h2(context)),
                    Text('Track online card payment transactions and manage student payment records.', style: AppStyles.bodyMedium),
                  ],
                ),
                if (payments.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                    label: const Text('Clear All Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => _confirmClearAllPayments(context, paymentProvider),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Payments Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Revenue Collected', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            AppStyles.formatLKR(paymentProvider.totalRevenue),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Completed Transactions', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${payments.where((p) => p.status == "success").length} Payments',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaction History Table with Delete
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Transactions History', style: AppStyles.h3(context)),
                        Text('${payments.length} total records', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (payments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: const Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textLight),
                            SizedBox(height: 12),
                            Text(
                              'No student payment records found.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Payment history is empty. New payments will appear here as students pay.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Class Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Transaction Ref', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Remove', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: payments.map((p) {
                            final dateStr = DateFormat('MMM dd, yyyy').format(p.timestamp);
                            return DataRow(cells: [
                              DataCell(Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(p.className)),
                              DataCell(Text(AppStyles.formatLKR(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              DataCell(Text(p.payherePaymentId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                              DataCell(Text(dateStr)),
                              DataCell(StatusBadge(status: p.status)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  tooltip: 'Remove Payment',
                                  onPressed: () => _confirmDeletePayment(context, paymentProvider, p.id, p.studentName),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Enrolled Students Payment Table
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student Monthly Access Statuses', style: AppStyles.h3(context)),
                        if (enrollments.isNotEmpty)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.person_remove_rounded, size: 16),
                            label: const Text('Clear All Enrollments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Clear All Enrollments?'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Are you sure you want to remove all student enrollment records?\n\nStudents will no longer have access until re-enrolled.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await classProvider.clearAllEnrollments();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('All student enrollments cleared.')),
                                          );
                                        }
                                      },
                                      child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (enrollments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: const Column(
                          children: [
                            Icon(Icons.person_search_rounded, size: 48, color: AppColors.textLight),
                            SizedBox(height: 12),
                            Text(
                              'No student monthly status records found yet.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Class Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Remove', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: enrollments.map((enr) {
                            return DataRow(cells: [
                              DataCell(Text(enr.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(enr.studentEmail)),
                              DataCell(Text(enr.className)),
                              DataCell(StatusBadge(status: enr.paymentStatus)),
                              DataCell(
                                enr.paymentStatus != 'paid'
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        ),
                                        onPressed: () async {
                                          final targetClass = classProvider.classes.firstWhere(
                                            (c) => c.id == enr.classId,
                                            orElse: () => classProvider.classes.first,
                                          );
                                          await paymentProvider.recordPayment(
                                            studentId: enr.studentId,
                                            studentName: enr.studentName,
                                            classId: enr.classId,
                                            className: enr.className,
                                            amount: targetClass.monthlyFee,
                                            payherePaymentId: 'MANUAL_VERIFIED_${DateTime.now().millisecondsSinceEpoch}',
                                            status: 'success',
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Payment approved for ${enr.studentName}')),
                                            );
                                          }
                                        },
                                        child: const Text('Approve Access', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      )
                                    : const Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                          SizedBox(width: 4),
                                          Text('Verified', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  tooltip: 'Remove Enrollment',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Remove Enrollment'),
                                        content: Text('Are you sure you want to remove the enrollment for ${enr.studentName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () async {
                                              Navigator.pop(ctx);
                                              await classProvider.deleteEnrollment(enr.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Enrollment for ${enr.studentName} removed.')),
                                                );
                                              }
                                            },
                                            child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
