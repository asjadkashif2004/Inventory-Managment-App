import 'package:flutter/material.dart';
import 'package:my_app/core/app_breakpoints.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/screens/dashboard_screen.dart';
import 'package:my_app/screens/profile_screen.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/item_service.dart';
import 'package:my_app/services/profile_service.dart';
import 'package:my_app/shell/app_side_nav.dart';
import 'package:my_app/shell/nav_item.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_svg_icons.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authService,
    required this.itemService,
    required this.profileService,
  });

  final AuthService authService;
  final ItemService itemService;
  final ProfileService profileService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<NavItem> get _navItems => [
        NavItem(
          label: 'Dashboard',
          icon: AppSvgIcons.dashboard(color: AppColors.textSecondary, size: 22),
          selectedIcon: AppSvgIcons.dashboard(color: AppColors.accentDark, size: 22),
        ),
        NavItem(
          label: 'Profile',
          icon: AppSvgIcons.profile(color: AppColors.textSecondary, size: 22),
          selectedIcon: AppSvgIcons.profile(color: AppColors.accentDark, size: 22),
        ),
      ];

  UserProfile get _profile =>
      widget.authService.profile ??
      UserProfile(id: '', email: 'user@example.com');

  Future<void> _signOut() async {
    await widget.authService.signOut();
  }

  void _onNavSelected(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return ProfileScreen(
          authService: widget.authService,
          profileService: widget.profileService,
          onProfileUpdated: () => setState(() {}),
        );
      case 0:
      default:
        return DashboardScreen(
          authService: widget.authService,
          itemService: widget.itemService,
          profile: _profile,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = AppBreakpoints.isDesktop(width);
    final extendedNav = isDesktop;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Row(
          children: [
            AppSideNav(
              items: _navItems,
              selectedIndex: _selectedIndex,
              onSelected: _onNavSelected,
              profile: _profile,
              extended: extendedNav,
              onSignOut: _signOut,
            ),
            Expanded(child: _buildPage(_selectedIndex)),
          ],
        ),
      );
    }

    if (AppBreakpoints.isTablet(width)) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Row(
          children: [
            AppSideNav(
              items: _navItems,
              selectedIndex: _selectedIndex,
              onSelected: _onNavSelected,
              profile: _profile,
              extended: false,
              onSignOut: _signOut,
            ),
            Expanded(child: _buildPage(_selectedIndex)),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surface,
      drawer: Drawer(
        child: AppSideNav(
          items: _navItems,
          selectedIndex: _selectedIndex,
          onSelected: _onNavSelected,
          profile: _profile,
          extended: true,
          onSignOut: _signOut,
        ),
      ),
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
        leading: IconButton(
          icon: AppSvgIcons.menu(color: AppColors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavSelected,
        destinations: [
          for (final item in _navItems)
            NavigationDestination(
              icon: item.icon,
              selectedIcon: item.selectedIcon,
              label: item.label,
            ),
        ],
      ),
    );
  }
}
