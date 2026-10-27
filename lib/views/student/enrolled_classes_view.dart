import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/enrolled_class_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/payment_provider.dart';
import '../../models/class_model.dart';
import 'payment_history_view.dart';

class EnrolledClassesView extends StatefulWidget {
  const EnrolledClassesView({super.key});

  @override
  State<EnrolledClassesView> createState() => _EnrolledClassesViewState();
}

class _EnrolledClassesViewState extends State<EnrolledClassesView> {
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
                key: const ValueKey('enrolled_classes_search_input'),
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
                  hintText: 'Search Enrolled Classes & Batches...',
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
    Set<String> paidClassIds,
  ) {
    return TapRegion(
      groupId: 'enrolled_classes_search_region',
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
                                    'Available • Rs. ${c.monthlyFee.toStringAsFixed(0)}',
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
    Set<String> paidClassIds,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = targetWidth.isInfinite ? constraints.maxWidth : targetWidth;

        return TapRegion(
          groupId: 'enrolled_classes_search_region',
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
                  child: _buildSearchDropdown(context, actualWidth, matchingClasses, paidClassIds),
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

    // Strictly show ONLY paid classes in My Enrolled Classes (excludes pending classes)
    final enrolledClasses = classProvider.getStudentPaidClasses(student?.uid ?? '');
    final allBatches = classProvider.classes;

    // Batches not yet paid for (available to enroll / complete payment)
    final paidClassIds = enrolledClasses.map((c) => c.id).toSet();
    final otherAvailableBatches = allBatches.where((c) => !paidClassIds.contains(c.id)).toList();

    // Dynamically filter both enrolled classes and open batches
    final filteredEnrolledClasses = enrolledClasses.where((c) => _matchesSearch(c, _searchQuery)).toList();
    final filteredAvailableBatches = otherAvailableBatches.where((c) => _matchesSearch(c, _searchQuery)).toList();
    final allMatchingClasses = allBatches.where((c) => _matchesSearch(c, _searchQuery)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page Header ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Enrolled Classes',
                        style: AppStyles.h2(context).copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your active paid Combined Maths classes with full access to video lessons, study packs, and live Zoom sessions.',
                        style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  label: const Text('Payment Receipts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentHistoryView()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Quick Summary Metric Cards (Responsive) ──────────────
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Paid Batches',
                      count: '${enrolledClasses.length}',
                      subtitle: 'Full Access Granted',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'LMS Content Unlocked',
                      count: '${enrolledClasses.length}',
                      subtitle: 'Videos & Study Packs',
                      icon: Icons.folder_special_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Batches to Join',
                      count: '${otherAvailableBatches.length}',
                      subtitle: 'Open for Registration',
                      icon: Icons.school_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: _buildMetricCard(
                        title: 'Active Paid Batches',
                        count: '${enrolledClasses.length}',
                        subtitle: 'Full Access Granted',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: _buildMetricCard(
                        title: 'LMS Content Unlocked',
                        count: '${enrolledClasses.length}',
                        subtitle: 'Videos & Study Packs',
                        icon: Icons.folder_special_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: _buildMetricCard(
                        title: 'Batches to Join',
                        count: '${otherAvailableBatches.length}',
                        subtitle: 'Open for Registration',
                        icon: Icons.school_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // ── Search Bar in Enrolled Classes ─────────────────────────
            _buildSearchArea(context, isDesktop ? 380 : double.infinity, allMatchingClasses, paidClassIds),
            const SizedBox(height: 24),

            // ── Enrolled Classes Grid (Paid Classes Only) ──────────────
            if (enrolledClasses.isEmpty) ...[
              _buildEmptyEnrollmentsState(context),
            ] else if (filteredEnrolledClasses.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textLight),
                    const SizedBox(height: 10),
                    Text(
                      'No enrolled classes match "$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Text('Clear Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 440,
                ),
                itemCount: filteredEnrolledClasses.length,
                itemBuilder: (context, index) {
                  final classItem = filteredEnrolledClasses[index];
                  final enrollment = classProvider.getEnrollment(student?.uid ?? '', classItem.id);

                  return EnrolledClassCard(
                    classItem: classItem,
                    enrollment: enrollment,
                    student: student,
                  );
                },
              ),
            ],

            // ── Batches Available to Enroll / Pay Fees ─────────────────
            if (filteredAvailableBatches.isNotEmpty) ...[
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Batches Available to Enroll & Unlock', style: AppStyles.h2(context).copyWith(color: AppColors.textPrimary)),
                  Text(
                    '${filteredAvailableBatches.length} batch(es) open',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 2 : 1),
                  childAspectRatio: isDesktop ? 1.45 : 1.25,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredAvailableBatches.length,
                itemBuilder: (context, index) {
                  final item = filteredAvailableBatches[index];
                  final enrollment = classProvider.getEnrollment(student?.uid ?? '', item.id);
                  final isEnrolledPending = enrollment != null;

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.functions_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.teacherName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isEnrolledPending)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFDE68A)),
                                      ),
                                      child: const Text(
                                        'FEE PENDING',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.schedule,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Monthly Fee:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(
                                    AppStyles.formatLKR(item.monthlyFee),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.credit_card_rounded, size: 16),
                                  label: Text(
                                    isEnrolledPending ? 'Pay Fees to Unlock' : 'Enroll & Pay Fees',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    if (student != null) {
                                      if (!isEnrolledPending) {
                                        await classProvider.enrollStudent(
                                          studentId: student.uid,
                                          studentName: student.name,
                                          studentEmail: student.email,
                                          classItem: item,
                                        );
                                      }

                                      if (!context.mounted) return;

                                      final resp = await paymentProvider.makeClassPayment(
                                        context: context,
                                        student: student,
                                        classItem: item,
                                      );

                                      if (context.mounted && resp.isSuccess) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Payment successful! "${item.title}" is now unlocked in My Enrolled Classes.'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEnrollmentsState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mintBorder),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Paid Classes Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You do not have any paid Combined Maths batches yet.\nPending/unpaid batches are not shown here. Complete fee payment below to unlock and view your enrolled class cards.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
