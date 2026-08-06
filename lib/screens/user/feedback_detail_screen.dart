import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/feedback_service.dart';
import '../../models/feedback_model.dart';
import 'edit_feedback_screen.dart';

class FeedbackDetailScreen extends StatefulWidget {
  final FeedbackModel item;
  const FeedbackDetailScreen({super.key, required this.item});

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  final _feedbackService = FeedbackService();

  @override
  void initState() {
    super.initState();
    // Clear the "New" badge the moment the author opens an item that
    // has an unseen admin reply / status change.
    if (!widget.item.seenByUser) {
      _feedbackService.markSeen(widget.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('Feedback details'),
        actions: [
          // Editing is only allowed while the item is still Pending -
          // matches the server-side rule so the button never promises
          // something the backend would reject.
          if (item.status == FeedbackStatus.pending)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditFeedbackScreen(item: item)),
                );
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
            Center(child: SentimentRing(rating: item.rating, size: 110, strokeWidth: 10)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.violet.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(item.category.label,
                  style: const TextStyle(color: AppColors.violet, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${item.displayName} · ${DateFormat('MMM d, yyyy · h:mm a').format(item.createdAt)}',
              style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.cardColor(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderColor(context))),
              child: Text(item.message, style: TextStyle(fontSize: 14.5, height: 1.6, color: AppColors.textPrimaryC(context))),
            ),
            if (item.adminReply != null && item.adminReply!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.admin_panel_settings_rounded, size: 18, color: AppColors.violet),
                  SizedBox(width: 6),
                  Text('Admin response', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.violet)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(item.adminReply!, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
