import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/class_model.dart';
import '../../models/content_model.dart';
import '../../providers/content_provider.dart';

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
    final contentProvider = Provider.of<ContentProvider>(context);
    final recordings = contentProvider.getRecordings(widget.classItem.id);
    final studyPacks = contentProvider.getStudyPacks(widget.classItem.id);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.classItem.title),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(icon: const Icon(Icons.video_collection_rounded), text: 'Recordings (${recordings.length})'),
            Tab(icon: const Icon(Icons.folder_special_rounded), text: 'Study Packs (${studyPacks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordingsTab(context, recordings),
          _buildStudyPacksTab(context, studyPacks),
        ],
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
                    color: AppColors.error.withOpacity(0.1),
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
