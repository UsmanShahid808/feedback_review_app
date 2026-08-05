import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/toast.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/feedback_model.dart';
import '../../widgets/common_widgets.dart';
import '../user/user_shell.dart';
import '../admin/admin_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await _authService.signIn(email: _emailCtrl.text, password: _passCtrl.text);

    if (!mounted) return;
    if (error != null) {
      setState(() => _loading = false);
      showAppToast(context, error);
      return;
    }

    AppUser? appUser;
    try {
      appUser = await _authService.getCurrentAppUser();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _loading = false);

    if (appUser != null && appUser.isAdmin) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminShell()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UserShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 28),
                FadeInLeft(
                  child: Text('Welcome back', style: Theme.of(context).textTheme.displayMedium),
                ),
                const SizedBox(height: 6),
                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Sign in to share feedback or manage your dashboard.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                  ),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: GradientButton(label: 'Sign In', onPressed: _submit, loading: _loading, icon: Icons.arrow_forward_rounded),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(text: 'Create one', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
