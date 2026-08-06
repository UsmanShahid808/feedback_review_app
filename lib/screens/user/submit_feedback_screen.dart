import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/toast.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/feedback_model.dart';

class SubmitFeedbackScreen extends StatefulWidget {
  const SubmitFeedbackScreen({super.key});

  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _authService = AuthService();
  final _feedbackService = FeedbackService();

  FeedbackCategory _category = FeedbackCategory.task;
  double _rating = 4;
  bool _loading = false;
  bool _anonymous = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = _authService.currentUser;
      final appUser = await _authService.getCurrentAppUser();
      await _feedbackService.submitFeedback(
        FeedbackModel(
          id: '',
          userId: user!.uid,
          userName: appUser?.name ?? user.email ?? 'User',
          title: _titleCtrl.text.trim(),
          message: _messageCtrl.text.trim(),
          rating: _rating,
          category: _category,
          createdAt: DateTime.now(),
          isAnonymous: _anonymous,
        ),
      );

      if (!mounted) return;
      _titleCtrl.clear();
      _messageCtrl.clear();
      setState(() {
        _rating = 4;
        _category = FeedbackCategory.task;
        _anonymous = false;
        _loading = false;
      });
      await SuccessCelebration.show(context, message: 'Feedback submitted.\nThank you!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppToast(context, 'Could not submit feedback. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: Text('Share feedback', style: Theme.of(context).textTheme.displayMedium)),
              const SizedBox(height: 6),
              FadeInDown(
                delay: Duration(milliseconds: 80),
                child: Text('Rate a task, course or service and tell us more.',
                    style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 14)),
              ),
              const SizedBox(height: 28),

              // Rating
              FadeInUp(
                child: Center(
                  child: Column(
                    children: [
                      SentimentRing(rating: _rating, size: 100, strokeWidth: 9),
                      const SizedBox(height: 16),
                      StarRatingInput(rating: _rating, onChanged: (v) => setState(() => _rating = v)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Category selector
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              FadeInUp(
                child: Wrap(
                  spacing: 10,
                  children: FeedbackCategory.values.map((c) {
                    final selected = c == _category;
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = c),
                      selectedColor: AppColors.violet,
                      backgroundColor: AppColors.cardColor(context),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimaryC(context),
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: selected ? Colors.transparent : AppColors.borderColor(context)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Onboarding session'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a short title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your feedback',
                  hintText: 'What went well? What could improve?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'Please add a little more detail' : null,
              ),
              const SizedBox(height: 10),

              // Anonymous toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.visibility_off_outlined, color: AppColors.violet),
                  title: Text('Submit anonymously', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimaryC(context))),
                  subtitle: Text('Your name will be hidden from everyone, including admins',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryC(context))),
                  value: _anonymous,
                  activeColor: AppColors.violet,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
              ),

              const SizedBox(height: 28),
              GradientButton(
                label: 'Submit Feedback',
                onPressed: _submit,
                loading: _loading,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
