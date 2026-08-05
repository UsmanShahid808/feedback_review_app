import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_analytics_screen.dart';
import '../user/profile_screen.dart';

/// Root shell for admins: Dashboard (all feedback + moderation),
/// Analytics (charts) and Profile.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _screens = const [
    AdminDashboardScreen(),
    AdminAnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: GNav(
            gap: 8,
            color: AppColors.textSecondary,
            activeColor: Colors.white,
            tabBackgroundColor: AppColors.violet,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            selectedIndex: _index,
            onTabChange: (i) => setState(() => _index = i),
            tabs: const [
              GButton(icon: Icons.dashboard_rounded, text: 'Dashboard'),
              GButton(icon: Icons.insights_rounded, text: 'Analytics'),
              GButton(icon: Icons.person_outline_rounded, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
