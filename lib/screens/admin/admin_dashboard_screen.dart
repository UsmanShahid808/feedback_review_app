import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme/app_theme.dart';
import '../../services/feedback_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/feedback_model.dart';
import 'feedback_moderation_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _feedbackService = FeedbackService();
  final _searchCtrl = TextEditingController();
  FeedbackStatus? _filter;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<FeedbackModel>>(
        stream: _feedbackService.streamAllFeedback(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [SliverFillRemaining(child: StreamErrorState(error: snapshot.error))],
            );
          }
          final all = snapshot.data ?? [];
          final pending = all.where((e) => e.status == FeedbackStatus.pending).length;
          final avg = all.isEmpty ? 0.0 : all.map((e) => e.rating).reduce((a, b) => a + b) / all.length;
          var filtered = _filter == null ? all : all.where((e) => e.status == _filter).toList();
          if (_query.isNotEmpty) {
            filtered = filtered
                .where((e) =>
                    e.title.toLowerCase().contains(_query) ||
                    e.message.toLowerCase().contains(_query) ||
                    e.userName.toLowerCase().contains(_query))
                .toList();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 4),
                  child: Text('Admin Dashboard', style: Theme.of(context).textTheme.displayMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
                  child: Text('Live overview of everything submitted across the org.',
                      style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 13.5)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FadeInUp(
                    child: Row(
                      children: [
                        Expanded(child: StatCard(label: 'Total feedback', value: '${all.length}', icon: Icons.forum_rounded, color: AppColors.violet)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Pending review', value: '$pending', icon: Icons.hourglass_top_rounded, color: AppColors.sentimentMid)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Avg. rating', value: avg.toStringAsFixed(1), icon: Icons.star_rounded, color: AppColors.sentimentHigh)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by title, message or user...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', null),
                        _filterChip('Pending', FeedbackStatus.pending),
                        _filterChip('Reviewed', FeedbackStatus.reviewed),
                        _filterChip('Resolved', FeedbackStatus.resolved),
                      ],
                    ),
                  ),
                ),
              ),
              if (!snapshot.hasData)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())))
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(
                    title: _query.isNotEmpty ? 'No matches' : 'Nothing here',
                    message: _query.isNotEmpty ? 'Try a different search term.' : 'No feedback matches this filter yet.',
                    icon: _query.isNotEmpty ? Icons.search_off_rounded : Icons.filter_alt_off_rounded,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FadeInUp(
                          delay: Duration(milliseconds: 30 * (i % 10)),
                          child: FeedbackCard(
                            item: filtered[i],
                            showUserName: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => FeedbackModerationScreen(item: filtered[i])),
                            ),
                          ),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, FeedbackStatus? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.violet,
        backgroundColor: AppColors.cardColor(context),
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimaryC(context), fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? Colors.transparent : AppColors.borderColor(context)),
        ),
      ),
    );
  }
}
