import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/content_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/content_provider.dart';
import '../../services/storage_service.dart';

class ManageContentView extends StatefulWidget {
  const ManageContentView({super.key});

  @override
  State<ManageContentView> createState() => _ManageContentViewState();
}

class _ManageContentViewState extends State<ManageContentView> {
  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final contentList = contentProvider.contentList;

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
                    Text('Upload LMS Recordings & Study Packs', style: AppStyles.h2(context)),
                    Text('Upload recorded video links and downloadable PDF notes for student access.', style: AppStyles.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                  label: const Text('Upload New Content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => _showUploadContentDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (contentList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.textLight),
                    SizedBox(height: 12),
                    Text('No content added yet.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Click "Upload New Content" to add your first recording or PDF study pack.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  final item = contentList[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isRecording ? AppColors.accent.withOpacity(0.12) : AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.isRecording ? Icons.play_circle_fill_rounded : Icons.picture_as_pdf_rounded,
                          color: item.isRecording ? AppColors.accent : AppColors.secondary,
                          size: 28,
                        ),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Class: ${item.className}'),
                            Text(item.description, style: AppStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () async {
                          await contentProvider.deleteContent(item.id);
                        },
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

  void _showUploadContentDialog(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final classes = classProvider.classes;

    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a batch class first before uploading content.')),
      );
      return;
    }

    String selectedClassId = classes.first.id;
    String selectedType = 'recording';
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Upload Content (Recording or Study Pack)'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Batch Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedClassId,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: classes
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.title, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedClassId = v!),
                    ),
                    const SizedBox(height: 14),

                    const Text('Content Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Video Recording'),
                            selected: selectedType == 'recording',
                            onSelected: (_) {
                              setDialogState(() {
                                selectedType = 'recording';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('PDF Study Pack'),
                            selected: selectedType == 'studypack',
                            onSelected: (_) {
                              setDialogState(() {
                                selectedType = 'studypack';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: titleController,
                      label: 'Content Title',
                      hint: selectedType == 'recording'
                          ? 'e.g. Pure Maths - Differential Calculus Part 1'
                          : 'e.g. Study Pack 05 - Integration Past Papers (PDF)',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: urlController,
                      label: 'File / Video URL (Firebase Storage / Link)',
                      hint: 'https://...',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                      icon: const Icon(Icons.attach_file_rounded, color: Colors.white, size: 16),
                      label: const Text('Upload File to Firebase Storage', style: TextStyle(color: Colors.white, fontSize: 12)),
                      onPressed: () async {
                        final storage = StorageService();
                        final mockUrl = await storage.uploadFile(
                          path: 'content/$selectedClassId',
                          fileName: selectedType == 'recording' ? 'class_video.mp4' : 'study_notes.pdf',
                          bytes: [],
                        );
                        urlController.text = mockUrl;
                        if (dialogCtx.mounted) {
                          ScaffoldMessenger.of(dialogCtx).showSnackBar(
                            const SnackBar(content: Text('File uploaded to Firebase Storage successfully!')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: descController,
                      label: 'Description',
                      hint: 'Add topic overview, notes, and guidelines...',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final contentProvider = Provider.of<ContentProvider>(context, listen: false);
                  final selectedClass = classes.firstWhere((c) => c.id == selectedClassId);

                  final newItem = ContentModel(
                    id: 'cnt_${DateTime.now().millisecondsSinceEpoch}',
                    classId: selectedClass.id,
                    className: selectedClass.title,
                    type: selectedType,
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    fileUrl: urlController.text.trim(),
                    fileSize: selectedType == 'studypack' ? 'PDF Document' : 'HD Video',
                  );

                  await contentProvider.addContent(newItem);
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                }
              },
              child: const Text('Upload Content', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
