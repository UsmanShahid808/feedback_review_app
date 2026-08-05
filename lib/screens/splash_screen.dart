import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/feedback_model.dart';
import 'auth/login_screen.dart';
import 'user/user_shell.dart';
import 'admin/admin_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    AppUser? appUser;
    try {
      appUser = await _authService.getCurrentAppUser();
    } catch (_) {
      appUser = null;
    }

    if (!mounted) return;
    if (appUser != null && appUser.isAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 700),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 46),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  'PulseFeedback',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: Text(
                  'Every voice, measured.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
