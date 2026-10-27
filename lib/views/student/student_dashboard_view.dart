import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/class_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import '../content/content_viewer_screen.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({super.key});

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus && _searchQuery.trim().isNotEmpty) {
      if (!_overlayController.isShowing) {
        _overlayController.show();
      }
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _matchesSearch(ClassModel c, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final title = c.title.toLowerCase();
    final titleNoSpaces = title.replaceAll(RegExp(r'[\s\-_]'), '');
    final schedule = c.schedule.toLowerCase();
    final description = c.description.toLowerCase();
    final teacher = c.teacherName.toLowerCase();

    // 1. Direct query matching (e.g. 'Maths 1' -> 'maths1' in '2026commaths1')
    final queryNoSpaces = cleanQuery.replaceAll(RegExp(r'[\s\-_]'), '');
    if (queryNoSpaces.isNotEmpty) {
      if (titleNoSpaces.contains(queryNoSpaces) ||
          schedule.replaceAll(RegExp(r'[\s\-_]'), '').contains(queryNoSpaces) ||
          description.replaceAll(RegExp(r'[\s\-_]'), '').contains(queryNoSpaces) ||
          teacher.replaceAll(RegExp(r'[\s\-_]'), '').contains(queryNoSpaces)) {
        return true;
      }
    }

    // 2. Tokenized search for cross-field multi-word queries (e.g. 'Sunday Maths', 'Monday 2026')
    final terms = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return true;

    return terms.every((term) {
      // If term is a single digit (e.g. '1', '2'), ensure it matches the batch number or standalone digit,
      // not random numbers like 2026 or 170
      if (RegExp(r'^\d+$').hasMatch(term)) {
        final digitPattern = RegExp('(^|\\D)$term(\\D|\$)');
        return digitPattern.hasMatch(title) ||
            titleNoSpaces.contains('maths$term') ||
            titleNoSpaces.contains('com$term') ||
            digitPattern.hasMatch(schedule);
      }

      // For words, check title, schedule, description, teacher
      return title.contains(term) ||
          titleNoSpaces.contains(term) ||
          schedule.contains(term) ||
          description.contains(term) ||
          teacher.contains(term);
    });
  }

  String _getScheduleDay(String schedule) {
    if (schedule.contains(',')) {
      return schedule.split(',').first.trim();
    }
    if (schedule.contains('•')) {
      return schedule.split('•').first.trim();
    }
    if (schedule.contains('\n')) {
      return schedule.split('\n').first.trim();
    }
    return schedule.isNotEmpty ? schedule : 'Every Sunday';
  }

  String _getScheduleTime(String schedule) {
    if (schedule.contains(',')) {
      final parts = schedule.split(',');
      if (parts.length > 1) return parts.sublist(1).join(',').trim();
    }
    if (schedule.contains('•')) {
      final parts = schedule.split('•');
      if (parts.length > 1) return parts.sublist(1).join('•').trim();
    }
    if (schedule.contains('\n')) {
      final parts = schedule.split('\n');
      if (parts.length > 1) return parts.sublist(1).join('\n').trim();
    }
    return '7.00 p.m - 9.00 pm';
  }

  void _showPaymentSuccessDialog(BuildContext context, ClassModel classItem) {
    final hasZoom = classItem.zoomUrl.trim().isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Completed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully unlocked access for:\n${classItem.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            if (hasZoom)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Join Zoom Class Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openUrl(context, classItem.zoomUrl, classItem.title);
                  },
                ),
              ),
            if (hasZoom) const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.folder_special_rounded, size: 20),
                label: const Text('View Class LMS Content', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentViewerScreen(classItem: classItem),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url, String title) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot launch Zoom URL for $title')),
        );
      }
    }
  }

  Widget _buildSearchCapsule(double width) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.requestFocus();
        if (_searchQuery.trim().isNotEmpty && !_overlayController.isShowing) {
          _overlayController.show();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _searchFocusNode.hasFocus
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.35),
            width: _searchFocusNode.hasFocus ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                key: const ValueKey('student_dashboard_search_input'),
                controller: _searchController,
                focusNode: _searchFocusNode,
                onTap: () {
                  if (_searchQuery.trim().isNotEmpty && !_overlayController.isShowing) {
                    _overlayController.show();
                  }
                },
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                  if (val.trim().isNotEmpty) {
                    if (!_overlayController.isShowing) {
                      _overlayController.show();
                    }
                  } else {
                    if (_overlayController.isShowing) {
                      _overlayController.hide();
                    }
                  }
                },
                onSubmitted: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                  if (_overlayController.isShowing) {
                    _overlayController.hide();
                  }
                  _searchFocusNode.unfocus();
                },
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Search Classes (e.g. Maths 1, Sunday, 2026)...',
                  hintStyle: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 16,
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                  if (_overlayController.isShowing) {
                    _overlayController.hide();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDropdown(
    BuildContext context,
    double width,
    List<ClassModel> matchingClasses,
    AuthProvider auth,
  ) {
    final student = auth.user;
    final paidClasses = Provider.of<ClassProvider>(context, listen: false).getStudentPaidClasses(student?.uid ?? '');
    final paidClassIds = paidClasses.map((c) => c.id).toSet();

    return TapRegion(
      groupId: 'student_dashboard_search_region',
      child: Material(
        elevation: 14,
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: AppColors.mintSoft,
                child: Row(
                  children: [
                    const Icon(Icons.manage_search_rounded, size: 17, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        matchingClasses.isEmpty
                            ? 'No Classes Found'
                            : 'Matching Classes (${matchingClasses.length})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_overlayController.isShowing) {
                          _overlayController.hide();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.mintBorder),

              // Items List or Empty State
              if (matchingClasses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 32, color: AppColors.textLight),
                      const SizedBox(height: 8),
                      Text(
                        'No classes matching "$_searchQuery"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try searching "Maths 1", "Sunday", or "2026"',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: matchingClasses.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final c = matchingClasses[index];
                      final isEnrolled = paidClassIds.contains(c.id);

                      return InkWell(
                        onTap: () {
                          _searchController.text = c.title;
                          setState(() {
                            _searchQuery = c.title;
                          });
                          if (_overlayController.isShowing) {
                            _overlayController.hide();
                          }
                          _searchFocusNode.unfocus();
                        },
                        hoverColor: AppColors.mintSoft.withValues(alpha: 0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.mintSoft,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.mintBorder),
                                ),
                                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.title,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${c.schedule} • ${c.teacherName}',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isEnrolled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.mintSoft,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Enrolled',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    'Rs. ${c.monthlyFee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textLight),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Bottom hint
              if (matchingClasses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: const Color(0xFFF8FAFC),
                  child: const Text(
                    'Tap any class to view details & materials',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchArea(
    BuildContext context,
    double targetWidth,
    List<ClassModel> matchingClasses,
    AuthProvider auth,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = targetWidth.isInfinite ? constraints.maxWidth : targetWidth;

        return TapRegion(
          groupId: 'student_dashboard_search_region',
          onTapOutside: (_) {
            if (_overlayController.isShowing) {
              _overlayController.hide();
            }
          },
          child: OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (context) {
              return CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 6),
                showWhenUnlinked: false,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _buildSearchDropdown(context, actualWidth, matchingClasses, auth),
                ),
              );
            },
            child: CompositedTransformTarget(
              link: _layerLink,
              child: _buildSearchCapsule(actualWidth),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final student = auth.user;
    final availableClasses = classProvider.classes;

    // Filter classes dynamically with robust tokenized search
    final filteredClasses = availableClasses.where((c) => _matchesSearch(c, _searchQuery)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 20,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Admin Preview Notice
            if (auth.isAdmin)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Admin Preview: Viewing student dashboard layout.',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Top Header Section (Green & White Theme - Responsive) ─────
            if (isDesktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${student?.name ?? "Kasun Jayaweera"}!',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.mintBorder),
                          ),
                          child: Text(
                            student?.grade ?? '2026 A/L',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Available Classes',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSearchArea(context, 340, filteredClasses, auth),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${student?.name ?? "Kasun Jayaweera"}!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.mintBorder),
                    ),
                    child: Text(
                      student?.grade ?? '2026 A/L',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSearchArea(context, double.infinity, filteredClasses, auth),
                  const SizedBox(height: 14),
                  Text(
                    'Available Classes',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // ── 3-Column Grid of Clean White Cards with Green Accents ─
            if (filteredClasses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textLight),
                    const SizedBox(height: 12),
                    Text(
                      classProvider.classes.isEmpty
                          ? 'No Classes Available Yet'
                          : 'No classes match "$_searchQuery"',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      classProvider.classes.isEmpty
                          ? 'New Combined Maths batches will appear here as soon as the teacher publishes them.'
                          : 'Try searching by batch number (e.g. Maths 1), schedule day (e.g. Sunday), or teacher name.',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    if (classProvider.classes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mintSoft,
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Text('Clear Search Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 2 : 1),
                  childAspectRatio: isDesktop ? 1.48 : 1.35,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemCount: filteredClasses.length,
                itemBuilder: (context, index) {
                  final classItem = filteredClasses[index];
                  final enrollment = classProvider.getEnrollment(student?.uid ?? '', classItem.id);
                  final isPaid = enrollment?.paymentStatus.toLowerCase() == 'paid';
                  final scheduleDay = _getScheduleDay(classItem.schedule);
                  final scheduleTime = _getScheduleTime(classItem.schedule);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPaid ? AppColors.mintBorder : const Color(0xFFE2E8F0),
                        width: isPaid ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Card Top Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    classItem.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.5,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPaid)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.mintSoft,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.mintBorder),
                                    ),
                                    child: const Text(
                                      'Enrolled',
                                      style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  scheduleDay,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  scheduleTime,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Monthly fee Rs. ${classItem.monthlyFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Action Button (Green & White Theme)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              if (isPaid) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentViewerScreen(classItem: classItem),
                                  ),
                                );
                              } else if (student != null) {
                                final enr = classProvider.getEnrollment(student.uid, classItem.id);
                                if (enr == null) {
                                  await classProvider.enrollStudent(
                                    studentId: student.uid,
                                    studentName: student.name,
                                    studentEmail: student.email,
                                    classItem: classItem,
                                  );
                                }

                                if (!context.mounted) return;

                                final resp = await paymentProvider.makeClassPayment(
                                  context: context,
                                  student: student,
                                  classItem: classItem,
                                );

                                if (context.mounted) {
                                  if (resp.isSuccess) {
                                    _showPaymentSuccessDialog(context, classItem);
                                  } else if (resp.message.isNotEmpty && !resp.message.contains('cancelled')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(resp.message)),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              decoration: BoxDecoration(
                                color: isPaid ? AppColors.primaryDark : AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPaid ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPaid ? Icons.folder_special_rounded : Icons.payment_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isPaid ? 'Access Content' : 'Pay Fees',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
