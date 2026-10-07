import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/class_model.dart';
import '../../models/content_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/payment_provider.dart';

class ContentViewerScreen extends StatefulWidget {
  final ClassModel classItem;

  const ContentViewerScreen({super.key, required this.classItem});

  @override
  State<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends State<ContentViewerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final student = auth.user;
    final enrollment = classProvider.getEnrollment(student?.uid ?? '', widget.classItem.id);
    final bool isPaid = auth.isAdmin || (enrollment != null && enrollment.paymentStatus == 'paid');

    final recordings = contentProvider.getRecordings(widget.classItem.id);
    final studyPacks = contentProvider.getStudyPacks(widget.classItem.id);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.classItem.title),
        actions: [
          if (widget.classItem.zoomUrl.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? AppColors.accent : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: Icon(isPaid ? Icons.videocam_rounded : Icons.lock_rounded, size: 18),
                label: Text(
                  isPaid ? 'Join Zoom Live' : 'Zoom Live (Locked)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () async {
                  if (!isPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zoom link is locked. Please complete checkout to join live class.'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }
                  final uri = Uri.parse(widget.classItem.zoomUrl.trim());
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cannot launch Zoom URL: ${widget.classItem.zoomUrl}')),
                      );
                    }
                  }
                },
              ),
            ),
        ],
        bottom: isPaid
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(icon: const Icon(Icons.video_collection_rounded), text: 'Recordings (${recordings.length})'),
                  Tab(icon: const Icon(Icons.folder_special_rounded), text: 'Study Packs (${studyPacks.length})'),
                ],
              )
            : null,
      ),
      body: !isPaid
          ? _buildPaymentRequiredLockScreen(context, student, paymentProvider, classProvider)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecordingsTab(context, recordings),
                _buildStudyPacksTab(context, studyPacks),
              ],
            ),
    );
  }

  /// Lock screen shown to students who haven't completed class payment
  Widget _buildPaymentRequiredLockScreen(
    BuildContext context,
    dynamic student,
    PaymentProvider paymentProvider,
    ClassProvider classProvider,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: Color(0xFFDC2626),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LMS Content Locked',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Class LMS recordings and PDF study packs are available only after completing monthly class fees.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Class & Fee Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enrolled Class:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Expanded(
                          child: Text(
                            widget.classItem.title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly Fee:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          'Rs. ${widget.classItem.monthlyFee.toStringAsFixed(2)} LKR',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pay Now Button (Stripe / PayHere)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 22),
                  label: const Text(
                    'Pay Fees Now to Unlock Content',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (student != null) {
                      await classProvider.enrollStudent(
                        studentId: student.uid,
                        studentName: student.name,
                        studentEmail: student.email,
                        classItem: widget.classItem,
                      );

                      if (!context.mounted) return;

                      final resp = await paymentProvider.makeClassPayment(
                        context: context,
                        student: student,
                        classItem: widget.classItem,
                      );

                      if (context.mounted) {
                        if (resp.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Completed! Class LMS Content and Zoom link unlocked.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          setState(() {});
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingsTab(BuildContext context, List<ContentModel> recordings) {
    if (recordings.isEmpty) {
      return _buildEmptyContent('No recorded video sessions uploaded for this class yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final item = recordings[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 42),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppStyles.h3(context)),
                      const SizedBox(height: 6),
                      Text(item.description, style: AppStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                        label: const Text('Watch Recording HD', style: TextStyle(color: Colors.white)),
                        onPressed: () => _openVideoPlayer(context, item),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudyPacksTab(BuildContext context, List<ContentModel> studyPacks) {
    if (studyPacks.isEmpty) {
      return _buildEmptyContent('No PDF study packs or notes uploaded for this class yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: studyPacks.length,
      itemBuilder: (context, index) {
        final item = studyPacks[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppStyles.h3(context)),
                      const SizedBox(height: 4),
                      Text(item.description, style: AppStyles.bodySmall),
                      const SizedBox(height: 6),
                      Text(item.fileSize, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                  label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final uri = Uri.parse(item.fileUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading study pack: ${item.title}')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _openVideoPlayer(BuildContext context, ContentModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 700,
          height: 420,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                title: Text(item.title, style: const TextStyle(fontSize: 14)),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 80),
                      const SizedBox(height: 16),
                      Text(
                        'Playing HD Recording: ${item.title}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stream URL: ${item.fileUrl}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
