import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/feedback_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return SafeArea(
      child: FutureBuilder<AppUser?>(
        future: authService.getCurrentAppUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final email = authService.currentUser?.email ?? '';
          final initials = (user?.name.isNotEmpty ?? false) ? user!.name.trim()[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
                  child: Center(
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'User', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                const SizedBox(height: 28),
                _tile(Icons.notifications_none_rounded, 'Notifications'),
                _tile(Icons.lock_outline_rounded, 'Privacy & Security'),
                _tile(Icons.help_outline_rounded, 'Help & Support'),
                _tile(Icons.info_outline_rounded, 'About PulseFeedback'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text('Sign out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tile(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.violet),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: () {},
      ),
    );
  }
}
