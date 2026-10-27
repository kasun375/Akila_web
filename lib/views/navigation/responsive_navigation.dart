import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../student/student_dashboard_view.dart';
import '../student/enrolled_classes_view.dart';
import '../student/student_profile_view.dart';
import '../teacher_admin/admin_dashboard_view.dart';
import '../../core/widgets/banner_ad_widget.dart';
import '../../core/utils/profile_image_helper.dart';

class ResponsiveNavigation extends StatefulWidget {
  const ResponsiveNavigation({super.key});

  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) ||
        (kIsWeb && MediaQuery.of(context).size.width >= 800);
    final isAdmin = auth.isAdmin;

    // Admin section show ONLY for admin students / teachers
    final navItems = isAdmin
        ? [
            const NavDestination(title: 'Admin Dashboard', icon: Icons.dashboard_rounded, view: AdminDashboardView()),
            const NavDestination(title: 'Student View', icon: Icons.school_rounded, view: StudentDashboardView()),
            const NavDestination(title: 'My Profile', icon: Icons.person_rounded, view: StudentProfileView()),
          ]
        : [
            const NavDestination(title: 'My Dashboard', icon: Icons.grid_view_rounded, view: StudentDashboardView()),
            const NavDestination(title: 'Enrolled Classes', icon: Icons.school_rounded, view: EnrolledClassesView()),
            const NavDestination(title: 'My Profile', icon: Icons.person_rounded, view: StudentProfileView()),
          ];

    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final currentView = navItems[_selectedIndex].view;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          // Top Navigation Bar (Desktop & Tablet Web)
          if (isDesktop)
            _buildDesktopTopNavBar(context, auth, navItems, isAdmin)
          else
            AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 1.5,
              titleSpacing: 0,
              title: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/Logo A1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Akila Com Maths',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Combined Maths',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 9,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber, width: 0.8),
                    ),
                    child: const Center(
                      child: Text(
                        'ADMIN',
                        style: TextStyle(color: Colors.amber, fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(width: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final profileIdx = navItems.indexWhere((i) => i.title == 'My Profile');
                    if (profileIdx != -1) {
                      setState(() => _selectedIndex = profileIdx);
                    }
                  },
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 12.5,
                      backgroundColor: AppColors.mintSoft,
                      backgroundImage: getProfileImageProvider(
                        auth.user?.profilePicUrl,
                        defaultAsset: isAdmin ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '',
                      ),
                      child: (auth.user?.profilePicUrl.isEmpty ?? true) && !isAdmin
                          ? Text(
                              (auth.user?.name.isNotEmpty == true) ? auth.user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mintPill,
                      foregroundColor: AppColors.primaryDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => auth.signOut(),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: AppColors.primaryDark),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),

          // Active Page View
          Expanded(child: currentView),

          // Banner Ad — mobile only
          if (!isDesktop) const BannerAdWidget(),
        ],
      ),

      drawer: !isDesktop
          ? Drawer(
              child: _buildSidebarContent(context, auth, navItems, isAdmin),
            )
          : null,

      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _selectedIndex,
              onTap: (idx) => setState(() => _selectedIndex = idx),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              type: BottomNavigationBarType.fixed,
              items: navItems
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.title,
                      ))
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildDesktopTopNavBar(
    BuildContext context,
    AuthProvider auth,
    List<NavDestination> navItems,
    bool isAdmin,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Brand Logo & Text (Left - Matching Untitled.png) ──────
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _selectedIndex = 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Image.asset(
                    'assets/Logo A1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akila Com Maths',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      'Combined Maths',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Center Navigation Items (Green & White Theme) ─────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected ? AppColors.mintPill : Colors.white.withValues(alpha: 0.9),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Right: User Profile Avatar, Name & Light Green Logout ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Profile Picture & Name (Clickable on Web to view profile)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final profileIdx = navItems.indexWhere((i) => i.title == 'My Profile');
                  if (profileIdx != -1) {
                    setState(() => _selectedIndex = profileIdx);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.mintSoft,
                          backgroundImage: getProfileImageProvider(
                            auth.user?.profilePicUrl,
                            defaultAsset: isAdmin ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '',
                          ),
                          child: (auth.user?.profilePicUrl.isEmpty ?? true) && !isAdmin
                              ? Text(
                                  (auth.user?.name.isNotEmpty == true) ? auth.user!.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        auth.user?.name ?? 'Kasun Jayaweera',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // Light pastel green Logout button matching Untitled.png
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7F9CC),
                  foregroundColor: const Color(0xFF064E3B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => auth.signOut(),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF064E3B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    AuthProvider auth,
    List<NavDestination> navItems,
    bool isAdmin,
  ) {
    return Container(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/Logo A1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.calculate_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AKILA JAYAWEERA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Akila Com Maths',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)) : null,
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected ? AppColors.accent : Colors.white60,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (!ResponsiveHelper.isDesktop(context)) {
                        Navigator.of(context).pop(); // Close drawer on mobile
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          if (isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(
                  Icons.school_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                label: const Text(
                  'Switch to Student View',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () {
                  auth.switchRole('student');
                  setState(() => _selectedIndex = 0);
                  Navigator.of(context).pop();
                },
              ),
            ),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintPill,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.primaryDark),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              onPressed: () => auth.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

class NavDestination {
  final String title;
  final IconData icon;
  final Widget view;

  const NavDestination({
    required this.title,
    required this.icon,
    required this.view,
  });
}
