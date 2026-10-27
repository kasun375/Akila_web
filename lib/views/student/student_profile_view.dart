import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/profile_image_helper.dart';
import '../../services/storage_service.dart';
import 'payment_history_view.dart';

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
  bool _isUploadingPic = false;

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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isAdmin ? 'Teacher Admin Profile' : 'Student Profile Details',
                      style: AppStyles.h2(context).copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth.isAdmin
                          ? 'Update your name, contact details, and profile picture.'
                          : 'Update your school, grade year, and personal contact details.',
                      style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Avatar Upload & Preview
                    Builder(
                      builder: (context) {
                        final displayPicUrl = _profilePicUrl.isNotEmpty ? _profilePicUrl : (user?.profilePicUrl ?? '');
                        return Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Tooltip(
                                    message: 'Tap to change profile picture',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(56),
                                      onTap: _isUploadingPic ? null : () => _uploadProfilePicFromDevice(context),
                                      child: CircleAvatar(
                                        radius: 52,
                                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                                        backgroundImage: getProfileImageProvider(
                                          displayPicUrl,
                                          defaultAsset: auth.isAdmin ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '',
                                        ),
                                        child: _isUploadingPic
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.45),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: const SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                              )
                                            : (displayPicUrl.isEmpty && !auth.isAdmin
                                                ? Text(
                                                    user?.name.isNotEmpty == true ? user!.name[0] : 'S',
                                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                  )
                                                : null),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _isUploadingPic ? null : () => _uploadProfilePicFromDevice(context),
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
                              const SizedBox(height: 8),
                              const Text(
                                'Tap photo to change',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                      if (!auth.isAdmin) ...[
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Receipts & History',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'View slips, verified transactions and monthly fee records.',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PaymentHistoryView()),
                                  );
                                },
                                child: const Text('View Receipts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
    final messenger = ScaffoldMessenger.of(context);

    ImageSource selectedSource = ImageSource.gallery;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final ImageSource? source;
    if (isDesktop) {
      source = await showDialog<ImageSource>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Change Profile Picture',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select a photo from device storage'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Capture using camera / webcam'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Change Profile Picture',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select a photo from device storage'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Capture using camera'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (source == null) return;
    selectedSource = source;

    setState(() => _isUploadingPic = true);

    try {
      final newUrl = await storageService.pickAndUploadProfileImage(
        userId: user?.uid ?? '',
        source: selectedSource,
      );

      if (newUrl != null && mounted) {
        setState(() => _profilePicUrl = newUrl);

        // Save profile picture continuously to Firebase Firestore
        final success = await auth.updateProfile(
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (user?.name ?? 'User'),
          phone: _phoneController.text.trim(),
          grade: _selectedGrade,
          school: _schoolController.text.trim(),
          profilePicUrl: newUrl,
        );

        messenger.clearSnackBars();
        if (success) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: ${auth.errorMessage}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading profile pic: $e');
      messenger.clearSnackBars();
      final isMissingPlugin = e.toString().contains('MissingPluginException');
      final message = isMissingPlugin
          ? 'Please restart the mobile app completely to link the camera & gallery picker.'
          : 'Failed to upload profile picture: $e';
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingPic = false);
      }
    }
  }
}
