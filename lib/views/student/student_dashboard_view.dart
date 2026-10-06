import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import '../content/content_viewer_screen.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

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
                    color: AppColors.primary.withOpacity(0.3),
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
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Launching Live Zoom Classroom...')),
                            );
                          },
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
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
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
            Text('My Enrolled Classes', style: AppStyles.h2(context)),
            const SizedBox(height: 16),
            if (enrolledClasses.isEmpty)
              _buildEmptyState('No active enrollments yet. Browse available batches below.')
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  childAspectRatio: isDesktop ? 2.2 : 1.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: enrolledClasses.length,
                itemBuilder: (context, index) {
                  final classItem = enrolledClasses[index];
                  final enrollment = classProvider.getEnrollment(student?.uid ?? '', classItem.id);

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
                            StatusBadge(status: enrollment?.paymentStatus ?? 'paid'),
                          ],
                        ),
                        Text(
                          classItem.schedule,
                          style: AppStyles.bodyMedium.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
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
                                text: 'Access LMS Content',
                                height: 40,
                                icon: Icons.folder_special_rounded,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContentViewerScreen(classItem: classItem),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (enrollment?.paymentStatus != 'paid')
                              ElevatedButton.icon(
                                icon: const Icon(Icons.payment_rounded, size: 16),
                                label: const Text('Pay Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  if (student != null) {
                                    await paymentProvider.makeClassPayment(
                                      context: context,
                                      student: student,
                                      classItem: classItem,
                                    );
                                  }
                                },
                              ),
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
                final isEnrolled = enrolledClasses.any((c) => c.id == classItem.id);

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
                              text: isEnrolled ? 'Enrolled (View LMS)' : 'Pay Fees',
                              isOutlined: isEnrolled,
                              color: isEnrolled ? AppColors.primary : AppColors.success,
                              height: 42,
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                if (isEnrolled) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ContentViewerScreen(classItem: classItem)),
                                  );
                                } else if (student != null) {
                                  await classProvider.enrollStudent(
                                    studentId: student.uid,
                                    studentName: student.name,
                                    studentEmail: student.email,
                                    classItem: classItem,
                                  );

                                  final resp = await paymentProvider.makeClassPayment(
                                    context: context,
                                    student: student,
                                    classItem: classItem,
                                  );

                                  messenger.showSnackBar(
                                    SnackBar(content: Text(resp.message)),
                                  );
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
