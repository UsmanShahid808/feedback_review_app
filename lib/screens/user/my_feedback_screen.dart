import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/feedback_model.dart';
import 'feedback_detail_screen.dart';

class MyFeedbackScreen extends StatefulWidget {
  const MyFeedbackScreen({super.key});

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen> {
  final _authService = AuthService();
  final _feedbackService = FeedbackService();
  FeedbackCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? '';
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 6),
            child: Row(
              children: [
                Expanded(child: Text('My History', style: Theme.of(context).textTheme.displayMedium)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', null),
                  ...FeedbackCategory.values.map((c) => _filterChip(c.label, c)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<FeedbackModel>>(
              stream: _feedbackService.streamUserFeedback(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var items = snapshot.data!;
                if (_filter != null) {
                  items = items.where((e) => e.category == _filter).toList();
                }
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'Nothing here yet',
                    message: 'Your submitted feedback will show up here once you send it.',
                    icon: Icons.history_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeInUp(
                      delay: Duration(milliseconds: 40 * (i % 8)),
                      child: FeedbackCard(
                        item: items[i],
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => FeedbackDetailScreen(item: items[i]))),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, FeedbackCategory? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.violet,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? Colors.transparent : AppColors.border),
        ),
      ),
    );
  }
}
