import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import 'submit_feedback_screen.dart';
import 'my_feedback_screen.dart';
import 'profile_screen.dart';

/// Root shell for a normal (non-admin) user: bottom nav with Home,
/// Submit, History and Profile tabs.
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    SubmitFeedbackScreen(),
    MyFeedbackScreen(),
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
              GButton(icon: Icons.home_rounded, text: 'Home'),
              GButton(icon: Icons.add_circle_outline_rounded, text: 'Submit'),
              GButton(icon: Icons.history_rounded, text: 'History'),
              GButton(icon: Icons.person_outline_rounded, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
