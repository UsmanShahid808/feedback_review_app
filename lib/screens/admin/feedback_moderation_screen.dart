import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/toast.dart';
import '../../theme/app_theme.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/feedback_model.dart';

class FeedbackModerationScreen extends StatefulWidget {
  final FeedbackModel item;
  const FeedbackModerationScreen({super.key, required this.item});

  @override
  State<FeedbackModerationScreen> createState() => _FeedbackModerationScreenState();
}

class _FeedbackModerationScreenState extends State<FeedbackModerationScreen> {
  final _feedbackService = FeedbackService();
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _replyCtrl.text = widget.item.adminReply ?? '';
  }

  Future<void> _updateStatus(FeedbackStatus status) async {
    await _feedbackService.updateStatus(widget.item.id, status);
    showAppToast(context, 'Marked as ${status.label}');
  }

  Future<void> _sendReply() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await _feedbackService.addAdminReply(widget.item.id, _replyCtrl.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    showAppToast(context, 'Reply sent to user');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Moderate feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () async {
              await _feedbackService.deleteFeedback(item.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: SentimentRing(rating: item.rating, size: 100, strokeWidth: 9)),
            const SizedBox(height: 20),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('${item.userName} · ${DateFormat('MMM d, yyyy · h:mm a').format(item.createdAt)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
              child: Text(item.message, style: const TextStyle(fontSize: 14.5, height: 1.6)),
            ),
            const SizedBox(height: 24),
            Text('Update status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: FeedbackStatus.values.map((s) {
                final selected = item.status == s;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: selected,
                  onSelected: (_) => _updateStatus(s),
                  selectedColor: AppColors.violet,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? Colors.transparent : AppColors.border)),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            Text('Reply to user', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _replyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Write a response the user will see...'),
            ),
            const SizedBox(height: 16),
            GradientButton(label: 'Send Reply', onPressed: _sendReply, loading: _sending, icon: Icons.reply_rounded),
          ],
        ),
      ),
    );
  }
}
