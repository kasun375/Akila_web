import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/class_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import '../content/content_viewer_screen.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  void _launchZoomClass(BuildContext context, ClassProvider classProvider, String studentId, List<ClassModel> classes) {
    final paidZoomClasses = classes.where((c) {
      final enr = classProvider.getEnrollment(studentId, c.id);
      return enr != null && enr.paymentStatus == 'paid' && c.zoomUrl.trim().isNotEmpty;
    }).toList();

    if (paidZoomClasses.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.accent),
              SizedBox(width: 10),
              Text('Checkout Required'),
            ],
          ),
          content: const Text(
            'You must complete monthly fee checkout for your class to unlock and join live Zoom sessions.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (paidZoomClasses.length == 1) {
      _openUrl(context, paidZoomClasses.first.zoomUrl, paidZoomClasses.first.title);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.video_camera_front_rounded, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Select Live Zoom Class'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: paidZoomClasses.map((cls) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.videocam_rounded, color: AppColors.success),
                    title: Text(cls.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(cls.schedule, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openUrl(context, cls.zoomUrl, cls.title);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  void _promptPaymentForZoom(
    BuildContext context,
    dynamic student,
    ClassModel classItem,
    PaymentProvider paymentProvider,
    ClassProvider classProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.accent),
            SizedBox(width: 10),
            Text('Zoom Class Locked'),
          ],
        ),
        content: Text(
          'Complete monthly fee payment for "${classItem.title}" to unlock the live Zoom link and full LMS content.',
          style: const TextStyle(fontSize: 14),
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
            ),
            icon: const Icon(Icons.credit_card_rounded, size: 16),
            label: const Text('Pay Fees Now'),
            onPressed: () async {
              Navigator.pop(ctx);
              if (student != null) {
                final enr = classProvider.getEnrollment(student.uid, classItem.id);
                if (enr == null) {
                  await classProvider.enrollStudent(
                    studentId: student.uid,
                    studentName: student.name,
                    studentEmail: student.email,
                    classItem: classItem,
                  );
                }
                if (!context.mounted) return;
                final resp = await paymentProvider.makeClassPayment(
                  context: context,
                  student: student,
                  classItem: classItem,
                );
                if (context.mounted) {
                  if (resp.isSuccess) {
                    _showPaymentSuccessDialog(context, classItem);
                  } else if (resp.message.isNotEmpty && !resp.message.contains('cancelled')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp.message)),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, ClassModel classItem) {
    final hasZoom = classItem.zoomUrl.trim().isNotEmpty;

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
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Completed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully unlocked access for:\n${classItem.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            if (hasZoom)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Join Zoom Class Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openUrl(context, classItem.zoomUrl, classItem.title);
                  },
                ),
              ),
            if (hasZoom) const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.folder_special_rounded, size: 20),
                label: const Text('View Class LMS Content', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentViewerScreen(classItem: classItem),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url, String title) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot launch Zoom URL for $title')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final student = auth.user;
    final enrolledClasses = classProvider.getStudentClasses(student?.uid ?? '');
    final availableClasses = classProvider.classes;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${student?.name ?? "Student"}! 👋',
                          style: AppStyles.h1(context).copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Combined Maths Class Portal • Grade: ${student?.grade ?? "2026 A/L"}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                          label: const Text('Join Live Zoom Class', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => _launchZoomClass(
                            context,
                            classProvider,
                            student?.uid ?? '',
                            enrolledClasses.isNotEmpty ? enrolledClasses : availableClasses,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 24),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/dfd8836b1cc110e21d03c83043dcb710.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Enrolled Combined Maths Classes Section
            Text('My Enrolled Classes & Access', style: AppStyles.h2(context)),
            const SizedBox(height: 16),
            if (enrolledClasses.isEmpty)
              _buildEmptyState('No active enrollments yet. Browse available batches below.')
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  childAspectRatio: isDesktop ? 2.1 : 1.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: enrolledClasses.length,
                itemBuilder: (context, index) {
                  final classItem = enrolledClasses[index];
                  final enrollment = classProvider.getEnrollment(student?.uid ?? '', classItem.id);
                  final bool isPaid = enrollment?.paymentStatus == 'paid';
                  final bool hasZoom = classItem.zoomUrl.trim().isNotEmpty;

                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                classItem.title,
                                style: AppStyles.h3(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: isPaid ? 'paid' : 'pending'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classItem.schedule,
                              style: AppStyles.bodyMedium.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Access Period: ${enrollment?.validMonth ?? "October 2026"}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          classItem.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: isPaid ? 'Access LMS Content' : 'Unlock Content (Pay Fees)',
                                height: 40,
                                icon: isPaid ? Icons.folder_special_rounded : Icons.lock_open_rounded,
                                color: isPaid ? AppColors.primary : AppColors.accent,
                                onPressed: () async {
                                  if (isPaid) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContentViewerScreen(classItem: classItem),
                                      ),
                                    );
                                  } else if (student != null) {
                                    final resp = await paymentProvider.makeClassPayment(
                                      context: context,
                                      student: student,
                                      classItem: classItem,
                                    );

                                    if (context.mounted) {
                                      if (resp.isSuccess) {
                                        _showPaymentSuccessDialog(context, classItem);
                                      } else if (resp.message.isNotEmpty && !resp.message.contains('cancelled')) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(resp.message)),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                            if (hasZoom) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: Icon(isPaid ? Icons.videocam_rounded : Icons.lock_rounded, size: 16),
                                label: Text(
                                  isPaid ? 'Zoom Live' : 'Zoom Live (Locked)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPaid ? AppColors.accent : Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  if (isPaid) {
                                    _openUrl(context, classItem.zoomUrl, classItem.title);
                                  } else {
                                    _promptPaymentForZoom(context, student, classItem, paymentProvider, classProvider);
                                  }
                                },
                              ),
                            ],
                            if (!isPaid) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.credit_card_rounded, size: 16),
                                label: const Text('Pay Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  if (student != null) {
                                    final resp = await paymentProvider.makeClassPayment(
                                      context: context,
                                      student: student,
                                      classItem: classItem,
                                    );
                                    if (context.mounted) {
                                      if (resp.isSuccess) {
                                        _showPaymentSuccessDialog(context, classItem);
                                      } else if (resp.message.isNotEmpty && !resp.message.contains('cancelled')) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(resp.message)),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 36),

            // Available Combined Maths Batches Section
            Text('Available Combined Maths Batches', style: AppStyles.h2(context)),
            const SizedBox(height: 16),
            if (availableClasses.isEmpty)
              _buildEmptyState('No batches or classes added by Admin yet. New classes will appear here once published by Teacher/Admin.')
            else
              GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 2 : 1),
                childAspectRatio: isDesktop ? 1.4 : 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: availableClasses.length,
              itemBuilder: (context, index) {
                final classItem = availableClasses[index];
                final enrollment = classProvider.getEnrollment(student?.uid ?? '', classItem.id);
                final isEnrolled = enrollment != null;
                final isPaid = enrollment?.paymentStatus == 'paid';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.functions_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    classItem.teacherName,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(classItem.title, style: AppStyles.h3(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(classItem.schedule, style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(classItem.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppStyles.bodySmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Monthly Fee:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text(
                                  AppStyles.formatLKR(classItem.monthlyFee),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: isPaid ? 'Paid (View LMS)' : (isEnrolled ? 'Pay Fees to Unlock' : 'Enroll & Pay Fees'),
                              isOutlined: isPaid,
                              color: isPaid ? AppColors.primary : AppColors.success,
                              height: 42,
                              onPressed: () async {
                                if (isPaid) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ContentViewerScreen(classItem: classItem)),
                                  );
                                } else if (student != null) {
                                  if (!isEnrolled) {
                                    await classProvider.enrollStudent(
                                      studentId: student.uid,
                                      studentName: student.name,
                                      studentEmail: student.email,
                                      classItem: classItem,
                                    );
                                  }

                                  if (!context.mounted) return;

                                  final resp = await paymentProvider.makeClassPayment(
                                    context: context,
                                    student: student,
                                    classItem: classItem,
                                  );

                                  if (context.mounted) {
                                    if (resp.isSuccess) {
                                      _showPaymentSuccessDialog(context, classItem);
                                    } else if (resp.message.isNotEmpty && !resp.message.contains('cancelled')) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(resp.message)),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
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

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
