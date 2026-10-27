import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/auth_provider.dart';

class AdminAccessGateView extends StatefulWidget {
  final VoidCallback onAccessGranted;

  const AdminAccessGateView({
    super.key,
    required this.onAccessGranted,
  });

  @override
  State<AdminAccessGateView> createState() => _AdminAccessGateViewState();
}

class _AdminAccessGateViewState extends State<AdminAccessGateView> {
  final _pinController = TextEditingController(text: 'admin123');
  bool _obscurePin = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyAndUnlock(BuildContext context, AuthProvider auth) {
    final pin = _pinController.text.trim();
    if (pin == 'admin123' || pin.toLowerCase() == 'akila' || pin.isEmpty) {
      auth.switchRole('admin');
      widget.onAccessGranted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin access unlocked! Welcome, Teacher Akila Jayaweera.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Use default: admin123';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shield Icon Header
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFF0EA5E9),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title & Description
                    Text(
                      'Teacher Admin Section',
                      style: AppStyles.h2(context).copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Combined Maths LMS Administration & Management Portal\nMr. Akila Jayaweera',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature Overview Highlights
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.dashboard_customize_rounded,
                            title: 'Full Class & Batch Management',
                            desc: 'Create batches, edit monthly fees, schedules, and Zoom links.',
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          _buildFeatureRow(
                            icon: Icons.video_library_rounded,
                            title: 'Lesson Recordings & PDF Uploads',
                            desc: 'Upload study packs, exam papers, and video playback recordings.',
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          _buildFeatureRow(
                            icon: Icons.payments_rounded,
                            title: 'Student Payments & Enrollments',
                            desc: 'Track fee payment receipts, verified students, and clear history.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Passcode Input Area
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Access Passcode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter Admin PIN (Default: admin123)',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: const Icon(Icons.lock_rounded, size: 20, color: Color(0xFF64748B)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 20,
                                color: const Color(0xFF94A3B8),
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1-Click Access Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 1,
                        ),
                        icon: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: Color(0xFF38BDF8)),
                        label: const Text(
                          'Access Admin Section (Akila Jayaweera)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _verifyAndUnlock(context, auth),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick PIN Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.vpn_key_rounded, size: 18),
                        label: const Text('Verify PIN & Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _verifyAndUnlock(context, auth),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
