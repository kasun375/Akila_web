import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../../models/class_model.dart';
import '../../models/enrollment_model.dart';
import '../../models/user_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import '../../views/content/content_viewer_screen.dart';

class EnrolledClassCard extends StatelessWidget {
  final ClassModel classItem;
  final EnrollmentModel? enrollment;
  final UserModel? student;
  final VoidCallback? onPaymentSuccess;

  const EnrolledClassCard({
    super.key,
    required this.classItem,
    required this.enrollment,
    required this.student,
    this.onPaymentSuccess,
  });

  bool get isPaid => enrollment?.paymentStatus.toLowerCase() == 'paid';
  bool get hasZoom => classItem.zoomUrl.trim().isNotEmpty;

  Future<void> _handlePayment(BuildContext context) async {
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to complete payment.')),
      );
      return;
    }

    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    // If not enrolled yet, enroll first
    if (enrollment == null) {
      await classProvider.enrollStudent(
        studentId: student!.uid,
        studentName: student!.name,
        studentEmail: student!.email,
        classItem: classItem,
      );
    }

    if (!context.mounted) return;

    final result = await paymentProvider.makeClassPayment(
      context: context,
      student: student!,
      classItem: classItem,
    );

    if (context.mounted) {
      if (result.isSuccess) {
        _showSuccessDialog(context);
        onPaymentSuccess?.call();
      } else if (result.message.isNotEmpty &&
          !result.message.toLowerCase().contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Completed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access has been unlocked for:\n${classItem.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.folder_special_rounded, size: 20),
                label: const Text('Access LMS Content Now',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContentViewerScreen(classItem: classItem),
                    ),
                  );
                },
              ),
            ),
            if (hasZoom) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Join Live Zoom Session',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openZoomUrl(context);
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, {required String feature}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_rounded, color: Color(0xFFDC2626)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$feature Locked',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access to $feature for "${classItem.title}" is locked.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please complete the monthly fee of ${AppStyles.formatLKR(classItem.monthlyFee)} to unlock full video recordings, study packs, and live Zoom sessions.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.credit_card_rounded, size: 16),
            label: Text('Pay ${AppStyles.formatLKR(classItem.monthlyFee)} Now'),
            onPressed: () {
              Navigator.pop(ctx);
              _handlePayment(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openZoomUrl(BuildContext context) async {
    final uri = Uri.parse(classItem.zoomUrl.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot launch Zoom link: ${classItem.zoomUrl}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? AppColors.mintBorder
              : const Color(0xFFE2E8F0),
          width: isPaid ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.mintBorder.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.mintBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.functions_rounded, size: 14, color: AppColors.primaryDark),
                          SizedBox(width: 4),
                          Text(
                            'COMBINED MATHS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Payment Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                        size: 14,
                        color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaid ? 'FEES PAID • UNLOCKED' : 'FEE UNPAID • LOCKED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content Area ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Title
                Text(
                  classItem.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Teacher Name & Badge
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Teacher: ${classItem.teacherName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.mintBorder),
                      ),
                      child: const Text(
                        'Lecturer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Schedule & Timetable
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mintBorder.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          classItem.schedule,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                if (classItem.description.trim().isNotEmpty) ...[
                  Text(
                    classItem.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Fee & Access Validity Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Fee',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          '${AppStyles.formatLKR(classItem.monthlyFee)} / mo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Access Period',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          enrollment?.validMonth.isNotEmpty == true
                              ? enrollment!.validMonth
                              : 'Current Month',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPaid ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Fee Payment Restriction Banner (Only when NOT paid) ─────
                if (!isPaid)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_rounded, size: 18, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Access Restricted • Fees Required',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Video lessons, study packs, and live Zoom class are locked until monthly fee is paid.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade800,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Full Access Granted: Recordings, PDFs & Live sessions active.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Action Buttons ─────────────────────────────────────────
                if (isPaid) ...[
                  // Unlocked State: Full Access Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.folder_special_rounded, size: 18),
                          label: const Text(
                            'Access LMS Content',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ContentViewerScreen(classItem: classItem),
                              ),
                            );
                          },
                        ),
                      ),
                      if (hasZoom) ...[
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.videocam_rounded, size: 18),
                          label: const Text(
                            'Join Zoom Live',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: () => _openZoomUrl(context),
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  // Locked State: Pay Fees Button & Locked Indicators
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                          ),
                          icon: const Icon(Icons.credit_card_rounded, size: 18),
                          label: Text(
                            'Pay Fees to Unlock (${AppStyles.formatLKR(classItem.monthlyFee)})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () => _handlePayment(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.lock_rounded, size: 15, color: Colors.grey),
                          label: const Text(
                            'LMS Content (Locked)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () =>
                              _showLockedDialog(context, feature: 'LMS Content'),
                        ),
                      ),
                      if (hasZoom) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.lock_rounded, size: 15, color: Colors.grey),
                          label: const Text(
                            'Zoom (Locked)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () =>
                              _showLockedDialog(context, feature: 'Live Zoom Session'),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
