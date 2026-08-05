import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/feedback_model.dart';
import 'feedback_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final feedbackService = FeedbackService();
    final uid = authService.currentUser?.uid ?? '';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: StreamBuilder<List<FeedbackModel>>(
                    stream: feedbackService.streamUserFeedback(uid),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? [];
                      final avg = items.isEmpty
                          ? 0.0
                          : items.map((e) => e.rating).reduce((a, b) => a + b) / items.length;
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your feedback pulse',
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text('${items.length} submitted',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  items.isEmpty ? 'Share your first review today' : 'Average rating so far',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                            child: SentimentRing(rating: avg, size: 66, strokeWidth: 6),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
              child: Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          StreamBuilder<List<FeedbackModel>>(
            stream: feedbackService.streamUserFeedback(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: StreamErrorState(error: snapshot.error));
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final items = snapshot.data!.take(6).toList();
              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    title: 'No feedback yet',
                    message: 'Tap the Submit tab below to share your first review, rating or suggestion.',
                    icon: Icons.rate_review_outlined,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInUp(
                        delay: Duration(milliseconds: 60 * i),
                        child: FeedbackCard(
                          item: items[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => FeedbackDetailScreen(item: items[i])),
                          ),
                        ),
                      ),
                    ),
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
