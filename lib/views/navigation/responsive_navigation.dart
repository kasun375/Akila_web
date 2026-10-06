import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/profile_image_helper.dart';
import '../../providers/auth_provider.dart';
import '../student/student_dashboard_view.dart';
import '../student/student_profile_view.dart';
import '../student/payment_history_view.dart';
import '../teacher_admin/admin_dashboard_view.dart';
import '../teacher_admin/manage_classes_view.dart';
import '../teacher_admin/manage_content_view.dart';
import '../teacher_admin/student_payments_view.dart';

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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isAdmin = auth.isAdmin;

    // Define navigation items based on User Role
    final navItems = isAdmin
        ? [
            const NavDestination(title: 'Admin Dashboard', icon: Icons.dashboard_rounded, view: AdminDashboardView()),
            const NavDestination(title: 'Manage Classes', icon: Icons.class_rounded, view: ManageClassesView()),
            const NavDestination(title: 'Upload Content', icon: Icons.video_library_rounded, view: ManageContentView()),
            const NavDestination(title: 'Students & Payments', icon: Icons.payments_rounded, view: StudentPaymentsView()),
            const NavDestination(title: 'My Profile', icon: Icons.person_rounded, view: StudentProfileView()),
          ]
        : [
            const NavDestination(title: 'My Dashboard', icon: Icons.grid_view_rounded, view: StudentDashboardView()),
            const NavDestination(title: 'Payment History', icon: Icons.receipt_long_rounded, view: PaymentHistoryView()),
            const NavDestination(title: 'My Profile', icon: Icons.person_rounded, view: StudentProfileView()),
          ];

    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final currentView = navItems[_selectedIndex].view;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Akila Jayaweera LMS',
                    style: AppStyles.h3(context).copyWith(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              actions: [
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      auth.user?.name.isNotEmpty == true ? auth.user!.name[0] : 'U',
                      style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  label: Text(
                    isAdmin ? 'TEACHER ADMIN' : 'STUDENT',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isAdmin ? AppColors.accent : AppColors.success,
                  side: BorderSide.none,
                ),
                const SizedBox(width: 12),
              ],
            )
          : null,

      drawer: !isDesktop
          ? Drawer(
              child: _buildSidebarContent(context, auth, navItems, isAdmin),
            )
          : null,

      body: Row(
        children: [
          // Sidebar for Desktop & Tablet
          if (isDesktop)
            SizedBox(
              width: 260,
              child: _buildSidebarContent(context, auth, navItems, isAdmin),
            ),

          // Main View Container
          Expanded(
            child: Column(
              children: [
                // Top Header Bar for Desktop Web
                if (isDesktop) _buildDesktopHeader(context, auth, navItems, isAdmin),

                // Active Page Content
                Expanded(child: currentView),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar for Mobile
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (idx) => setState(() => _selectedIndex = idx),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
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

  Widget _buildDesktopHeader(BuildContext context, AuthProvider auth, List<NavDestination> navItems, bool isAdmin) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Combined Maths Learning Management System',
            style: AppStyles.h3(context).copyWith(color: AppColors.primary),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdmin ? AppColors.accent.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.verified_user_rounded : Icons.school_rounded,
                      size: 16,
                      color: isAdmin ? AppColors.accent : AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAdmin ? 'TEACHER / ADMIN' : auth.user?.grade ?? 'STUDENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? AppColors.accent : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final profileIdx = navItems.indexWhere((item) => item.title == 'My Profile');
                  if (profileIdx != -1) {
                    setState(() => _selectedIndex = profileIdx);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: getProfileImageProvider(
                          auth.user?.profilePicUrl,
                          defaultAsset: isAdmin ? 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg' : '',
                        ),
                        child: (auth.user?.profilePicUrl.isEmpty == true) && !isAdmin
                            ? Text(
                                auth.user?.name.isNotEmpty == true ? auth.user!.name[0] : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.name ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            auth.user?.email ?? '',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: getProfileImageProvider(
                            auth.user?.profilePicUrl,
                            defaultAsset: 'assets/dfd8836b1cc110e21d03c83043dcb710.jpg',
                          ) ??
                          const AssetImage('assets/dfd8836b1cc110e21d03c83043dcb710.jpg'),
                      fit: BoxFit.cover,
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
                        'Combined Maths LMS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
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
                    color: isSelected ? AppColors.primaryLight.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: AppColors.primaryLight.withOpacity(0.4)) : null,
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

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
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
