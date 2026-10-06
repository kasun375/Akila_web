import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/profile_image_helper.dart';
import '../../services/storage_service.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  String _selectedGrade = '2026 A/L';
  String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _schoolController.text = user.school;
        setState(() {
          _selectedGrade = ['2026 A/L', '2027 A/L', 'Revision'].contains(user.grade)
              ? user.grade
              : (user.isAdmin ? 'Teacher / Lecturer' : '2026 A/L');
          _profilePicUrl = user.profilePicUrl;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isAdmin ? 'Teacher Admin Profile' : 'Student Profile Details',
                        style: AppStyles.h2(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auth.isAdmin
                            ? 'Update your name, contact details, and upload your profile picture from device storage.'
                            : 'Update your school, grade year, and personal contact details.',
                        style: AppStyles.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // Avatar Upload & Preview
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                              backgroundImage: getProfileImageProvider(
                                _profilePicUrl,
                                defaultAsset: auth.isAdmin ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '',
                              ),
                              child: _profilePicUrl.isEmpty && !auth.isAdmin
                                  ? Text(
                                      user?.name.isNotEmpty == true ? user!.name[0] : 'S',
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _uploadProfilePicFromDevice(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _uploadProfilePicFromDevice(context),
                          icon: const Icon(Icons.upload_file_rounded, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Upload from Device',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: TextEditingController(text: user?.email ?? ''),
                        label: 'Email Address (Read-only)',
                        prefixIcon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),

                      if (!auth.isAdmin) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('A/L Grade / Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: ['2026 A/L', '2027 A/L', 'Revision'].contains(_selectedGrade)
                                        ? _selectedGrade
                                        : '2026 A/L',
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    items: ['2026 A/L', '2027 A/L', 'Revision']
                                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (v) => setState(() => _selectedGrade = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        CustomTextField(
                          controller: TextEditingController(text: 'Teacher / Lecturer'),
                          label: 'Designation / Role',
                          prefixIcon: Icons.badge_outlined,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      CustomTextField(
                        controller: _schoolController,
                        label: auth.isAdmin ? 'Academy / Institution' : 'School / Institution',
                        hint: auth.isAdmin ? 'Combined Maths Academy' : 'e.g. Royal College, Ananda College, Visakha Vidyalaya',
                        prefixIcon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 32),

                      CustomButton(
                        text: 'Save Profile Changes',
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await auth.updateProfile(
                              name: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              grade: _selectedGrade,
                              school: _schoolController.text.trim(),
                              profilePicUrl: _profilePicUrl,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully!')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicFromDevice(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final storageService = StorageService();

    final newUrl = await storageService.pickAndUploadProfileImage(userId: user?.uid ?? '');

    if (newUrl != null && mounted) {
      setState(() => _profilePicUrl = newUrl);

      // Save profile picture continuously to Firebase Firestore
      await auth.updateProfile(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (user?.name ?? 'User'),
        phone: _phoneController.text.trim(),
        grade: _selectedGrade,
        school: _schoolController.text.trim(),
        profilePicUrl: newUrl,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture saved to Firebase & updated continuously across app!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
