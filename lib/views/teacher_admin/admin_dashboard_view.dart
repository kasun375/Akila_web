import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import 'manage_classes_view.dart';
import 'manage_content_view.dart';
import 'student_payments_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final totalStudents = classProvider.enrollments.map((e) => e.studentId).toSet().length;
    final activeClasses = classProvider.classes.where((c) => c.active).length;
    final totalRevenue = paymentProvider.totalRevenue;

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
                    Text('Teacher Admin Panel', style: AppStyles.h1(context)),
                    Text(
                      'Welcome Mr. Akila Jayaweera • Combined Maths LMS Portal',
                      style: AppStyles.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Pre-Register Email', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        _showPreRegisterDialog(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text('Add New Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageClassesView()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stat Counter Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 2 : 1),
              childAspectRatio: isDesktop ? 2.5 : 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Enrolled Students',
                  value: '$totalStudents',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primaryLight,
                  subText: 'Across all Combined Maths batches',
                ),
                _buildStatCard(
                  context,
                  title: 'Active Combined Maths Batches',
                  value: '$activeClasses',
                  icon: Icons.class_rounded,
                  color: AppColors.secondary,
                  subText: 'Pure & Applied Maths Theory/Revision',
                ),
                _buildStatCard(
                  context,
                  title: 'Monthly Revenue (LKR / Rs.)',
                  value: AppStyles.formatLKR(totalRevenue),
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  subText: 'PayHere Gateway & Bank Transfers',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Management Shortcut Cards
            Text('LMS Content & Batch Management', style: AppStyles.h2(context)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 2 : 1),
              childAspectRatio: isDesktop ? 2.3 : 2.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  title: 'Upload Recordings & Notes',
                  description: 'Add video links or PDF study packs for Pure/Applied Maths.',
                  icon: Icons.upload_file_rounded,
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageContentView()),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Student Payments Tracker',
                  description: 'View monthly fee statuses, receipts & approve pending payments.',
                  icon: Icons.payments_rounded,
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentPaymentsView()),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Manage Batch Schedules',
                  description: 'Update class fees in LKR, Zoom links, and weekly timetables.',
                  icon: Icons.edit_calendar_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageClassesView()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Enrolled Students Summary Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Student Enrollments', style: AppStyles.h2(context)),
                if (classProvider.enrollments.isNotEmpty)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.person_remove_rounded, size: 18),
                    label: const Text('Clear All Enrollments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                            'Are you sure you want to remove all student enrollment records?\n\nStudents will no longer have active access to these class batches until re-enrolled.',
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
                                    const SnackBar(content: Text('All student enrollments have been cleared.')),
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: classProvider.enrollments.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: Text(
                            'No student enrollments yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Class Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Payment Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Enrolled Month', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: classProvider.enrollments.map((e) {
                            return DataRow(cells: [
                              DataCell(Text(e.studentName)),
                              DataCell(Text(e.className)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: e.isPaid ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    e.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: e.isPaid ? AppColors.success : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(e.validMonth)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  tooltip: 'Remove Enrollment',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Remove Enrollment'),
                                        content: Text('Are you sure you want to remove the enrollment for ${e.studentName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () async {
                                              Navigator.pop(ctx);
                                              await classProvider.deleteEnrollment(e.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Enrollment for ${e.studentName} removed.')),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subText,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(subText, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(description, style: AppStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreRegisterDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Pre-Register Student Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter student email address to pre-approve them for LMS access:\n(1 email can only be registered 1 time)',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Student Email Address',
                hintText: 'e.g. student@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.pop(ctx);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.preRegisterStudentEmail(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("'$email' pre-registered successfully!")),
                  );
                }
              }
            },
            child: const Text('Pre-Register Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
