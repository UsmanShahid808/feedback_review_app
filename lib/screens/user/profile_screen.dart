import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../services/auth_service.dart';
import '../../models/feedback_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final themeController = context.watch<ThemeController>();

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
                Text(email, style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 13.5)),
                const SizedBox(height: 28),

                // Dark mode toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor(context)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      themeController.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.violet,
                    ),
                    title: Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimaryC(context))),
                    value: themeController.isDark,
                    activeColor: AppColors.violet,
                    onChanged: (v) => themeController.setDark(v),
                  ),
                ),

                _tile(context, Icons.notifications_none_rounded, 'Notifications'),
                _tile(context, Icons.lock_outline_rounded, 'Privacy & Security'),
                _tile(context, Icons.help_outline_rounded, 'Help & Support'),
                _tile(context, Icons.info_outline_rounded, 'About PulseFeedback'),
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

  Widget _tile(BuildContext context, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: AppColors.cardColor(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor(context))),
      child: ListTile(
        leading: Icon(icon, color: AppColors.violet),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimaryC(context))),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryC(context)),
        onTap: () {},
      ),
    );
  }
}
