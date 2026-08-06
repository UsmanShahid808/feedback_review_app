import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/toast.dart';
import '../../models/feedback_model.dart';

/// Lets the feedback's own author edit or delete it - only reachable
/// while the item is still "Pending" (once an admin has reviewed it,
/// editing is locked, matching the Firestore rules).
class EditFeedbackScreen extends StatefulWidget {
  final FeedbackModel item;
  const EditFeedbackScreen({super.key, required this.item});

  @override
  State<EditFeedbackScreen> createState() => _EditFeedbackScreenState();
}

class _EditFeedbackScreenState extends State<EditFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _messageCtrl;
  final _feedbackService = FeedbackService();

  late FeedbackCategory _category;
  late double _rating;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _messageCtrl = TextEditingController(text: widget.item.message);
    _category = widget.item.category;
    _rating = widget.item.rating;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _feedbackService.updateFeedback(
        feedbackId: widget.item.id,
        title: _titleCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
        rating: _rating,
        category: _category,
      );
      if (!mounted) return;
      showAppToast(context, 'Feedback updated');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppToast(context, 'Could not update. Try again.');
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete feedback?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await _feedbackService.deleteFeedback(widget.item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      showAppToast(context, 'Could not delete. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('Edit feedback'),
        actions: [
          IconButton(
            icon: _deleting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: _deleting ? null : _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SentimentRing(rating: _rating, size: 100, strokeWidth: 9),
                    const SizedBox(height: 16),
                    StarRatingInput(rating: _rating, onChanged: (v) => setState(() => _rating = v)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
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
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a short title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Your feedback', alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().length < 5) ? 'Please add a little more detail' : null,
              ),
              const SizedBox(height: 28),
              GradientButton(label: 'Save Changes', onPressed: _save, loading: _saving, icon: Icons.check_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
