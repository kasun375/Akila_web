import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Smooth splash duration before proceeding to main application
    _navigationTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          // Allow tap-to-skip for quick testing
          _navigationTimer?.cancel();
          widget.onComplete();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.mintSoft.withValues(alpha: 0.5),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo with scale and fade animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.16),
                            blurRadius: 36,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1.6,
                        ),
                      ),
                      child: Image.asset(
                        'assets/Logo A1.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title and Subtitle with Fade
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Akila Com Maths',
                        style: GoogleFonts.poppins(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Subtle Progress Indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Akila Jayaweera • Combined Maths',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
