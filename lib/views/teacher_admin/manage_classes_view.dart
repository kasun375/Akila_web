import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';

class ManageClassesView extends StatefulWidget {
  const ManageClassesView({super.key});

  @override
  State<ManageClassesView> createState() => _ManageClassesViewState();
}

class _ManageClassesViewState extends State<ManageClassesView> {
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final classes = classProvider.classes;

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
                    Text('Manage Combined Maths Classes', style: AppStyles.h2(context)),
                    Text('Add new batches, edit timetable schedules, and set monthly fees in LKR.', style: AppStyles.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                  label: const Text('Create New Batch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddEditClassDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final item = classes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(item.title, style: AppStyles.h3(context)),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: AppColors.primaryLight),
                                  onPressed: () => _showAddEditClassDialog(context, existingClass: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Class?'),
                                        content: Text('Are you sure you want to delete "${item.title}"?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await classProvider.deleteClass(item.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.schedule,
                          style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(item.description, style: AppStyles.bodyMedium),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Teacher: ${item.teacherName} • ${item.studentCount} Students',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              'Monthly Fee: ${AppStyles.formatLKR(item.monthlyFee)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
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

  void _showAddEditClassDialog(BuildContext context, {ClassModel? existingClass}) {
    final titleController = TextEditingController(text: existingClass?.title ?? '');
    final descController = TextEditingController(text: existingClass?.description ?? '');
    final scheduleController = TextEditingController(text: existingClass?.schedule ?? '');
    final feeController = TextEditingController(text: existingClass?.monthlyFee.toString() ?? '3500');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existingClass == null ? 'Create Combined Maths Batch' : 'Edit Batch Details'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleController,
                    label: 'Class Title',
                    hint: 'e.g. 2026 Combined Maths Theory',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: scheduleController,
                    label: 'Timetable Schedule',
                    hint: 'e.g. Every Sunday | 8:00 AM - 1:00 PM',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: feeController,
                    label: 'Monthly Fee in LKR (Rs.)',
                    hint: '3500',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid fee' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descController,
                    label: 'Batch Description & Syllabus Coverage',
                    hint: 'Describe topics covered (e.g. Calculus, Statics, Kinematics)...',
                    maxLines: 3,
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
                final classProvider = Provider.of<ClassProvider>(context, listen: false);
                final newModel = ClassModel(
                  id: existingClass?.id ?? 'cls_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  schedule: scheduleController.text.trim(),
                  monthlyFee: double.parse(feeController.text.trim()),
                  teacherName: 'Akila Jayaweera',
                );

                if (existingClass == null) {
                  await classProvider.addClass(newModel);
                } else {
                  await classProvider.updateClass(newModel);
                }

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            child: Text(existingClass == null ? 'Create Class' : 'Save Changes', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
