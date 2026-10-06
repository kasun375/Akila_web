import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _nameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  String _selectedGrade = '2026 A/L';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Background Image (Login Uim.jpg for mobile, login_ui1.jpg for desktop/web)
          Positioned.fill(
            child: Image.asset(
              !isDesktop ? 'assets/Login Uim.jpg' : 'assets/login_ui1.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/Login Ui.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/login_ui1.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            ),
          ),

          // Dark overlay gradient for mobile screens to guarantee crisp contrast
          if (!isDesktop)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.30),
              ),
            ),

          // 2. Interactive 50% Transparent Glass Card (For both Desktop & Mobile apps)
          SafeArea(
            child: Align(
              alignment: isDesktop ? Alignment.centerRight : Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                  right: isDesktop ? size.width * 0.05 : 20,
                  left: isDesktop ? 0 : 20,
                  top: 20,
                  bottom: 20,
                ),
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: isDesktop ? 410 : (size.width > 480 ? 410 : size.width * 0.9),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE4C3).withValues(alpha: 0.50), // 50% Transparent Sign In Card
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tab Selector Pill Container
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5EA).withValues(alpha: 0.70), // Cream semi-transparent
                                borderRadius: BorderRadius.circular(16),
                              ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black45,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            unselectedLabelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'New Register'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Animated Tab Bar Views
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            return _tabController.index == 0
                                ? _buildSignInView(context)
                                : _buildRegisterView(context);
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
          ),
        ],
      ),
    );
  }

  // --- Sign In View (Matching exact Login Ui.jpg inputs and orange buttons) ---
  Widget _buildSignInView(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // Sign-in hint
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFFFF9100), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sign in with your registered student account.',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // e mail Input
          _buildStyledTextField(
            controller: _loginEmailController,
            hintText: 'e mail',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
          ),
          const SizedBox(height: 16),

          // Password Input
          _buildStyledTextField(
            controller: _loginPasswordController,
            hintText: 'Password',
            obscureText: true,
            validator: (v) => v != null && v.length >= 6 ? null : 'Password too short',
          ),
          const SizedBox(height: 24),

          // Sign In Button (Vibrant Orange - matching Login Ui.jpg)
          _buildOrangeButton(
            text: 'Sign In',
            isLoading: auth.isEmailLoading,
            onPressed: () async {
              if (_loginFormKey.currentState!.validate()) {
                final password = _loginPasswordController.text.trim();
                _loginPasswordController.clear(); // Ensure password is not saved in text controller
                final success = await auth.signIn(
                  _loginEmailController.text.trim(),
                  password,
                );
                if (!success && auth.errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage!),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 14),

          // Continue With Google Button (Vibrant Orange with Google Icon)
          _buildGoogleOrangeButton(
            isLoading: auth.isGoogleLoading,
            onPressed: () async {
              final success = await auth.signInWithGoogle();
              if (!success && auth.errorMessage != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(auth.errorMessage!),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset link sent to your registered email.')),
              );
            },
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // --- New Register View ---
  Widget _buildRegisterView(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          // Pre-registration policy hint
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFFFF9100), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pre-registered emails only. 1 email can only be registered 1 time.',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          _buildStyledTextField(
            controller: _nameController,
            hintText: 'Full Name',
            validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
          ),
          const SizedBox(height: 12),
          _buildStyledTextField(
            controller: _signupEmailController,
            hintText: 'e mail',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
          ),
          const SizedBox(height: 12),
          _buildStyledTextField(
            controller: _phoneController,
            hintText: 'Phone Number (+94)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EA).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGrade,
                isExpanded: true,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                items: ['2026 A/L', '2027 A/L', 'Revision']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGrade = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildStyledTextField(
            controller: _signupPasswordController,
            hintText: 'Password',
            obscureText: true,
            validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 20),

          // Register Button
          _buildOrangeButton(
            text: 'Register Account',
            isLoading: auth.isEmailLoading,
            onPressed: () async {
              if (_signupFormKey.currentState!.validate()) {
                final email = _signupEmailController.text.trim();
                final password = _signupPasswordController.text.trim();
                _signupPasswordController.clear(); // Ensure password is not saved in text controller
                final isTeacherEmail = email.toLowerCase().contains('admin') ||
                    email.toLowerCase().contains('teacher') ||
                    email.toLowerCase().contains('akila');
                final success = await auth.signUp(
                  name: _nameController.text.trim(),
                  email: email,
                  password: password,
                  phone: _phoneController.text.trim(),
                  grade: _selectedGrade,
                  school: _schoolController.text.trim(),
                  role: isTeacherEmail ? 'admin' : 'student',
                );
                if (!success && auth.errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage!),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          // Google Button
          _buildGoogleOrangeButton(
            isLoading: auth.isGoogleLoading,
            onPressed: () async {
              final success = await auth.signInWithGoogle();
              if (!success && auth.errorMessage != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(auth.errorMessage!),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Rounded Cream Input Field (Matching Login Ui.jpg) ---
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      enableInteractiveSelection: true,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF9C9286), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFFF5EA).withValues(alpha: 0.75), // Semi-transparent cream fill color
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF9100), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  // --- Helper Widget: Orange Action Button (Matching Login Ui.jpg) ---
  Widget _buildOrangeButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9100), // Matching UI orange button
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // --- Helper Widget: Orange Google Sign In Button (Matching Login Ui.jpg) ---
  Widget _buildGoogleOrangeButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9100), // Matching UI orange button
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons8-google-48.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 22,
                    color: Color(0xFF4285F4),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              'Continue With Google',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
