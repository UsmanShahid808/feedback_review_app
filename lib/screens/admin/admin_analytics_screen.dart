import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/feedback_service.dart';
import '../../models/feedback_model.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();

    return SafeArea(
      child: StreamBuilder<List<FeedbackModel>>(
        stream: feedbackService.streamAllFeedback(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final byCategory = <FeedbackCategory, List<double>>{};
          for (final c in FeedbackCategory.values) {
            byCategory[c] = all.where((e) => e.category == c).map((e) => e.rating).toList();
          }

          final byStatus = <FeedbackStatus, int>{};
          for (final s in FeedbackStatus.values) {
            byStatus[s] = all.where((e) => e.status == s).length;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
            children: [
              Text('Analytics', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 6),
              const Text('Trends across every submission, updated live.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
              const SizedBox(height: 26),

              // --- Bar chart: average rating per category ---
              _ChartCard(
                title: 'Average rating by category',
                child: SizedBox(
                  height: 220,
                  child: all.isEmpty
                      ? const Center(child: Text('No data yet', style: TextStyle(color: AppColors.textSecondary)))
                      : BarChart(
                          BarChartData(
                            maxY: 5,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final cats = FeedbackCategory.values;
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= cats.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(cats[idx].label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(FeedbackCategory.values.length, (i) {
                              final cat = FeedbackCategory.values[i];
                              final list = byCategory[cat] ?? [];
                              final avg = list.isEmpty ? 0.0 : list.reduce((a, b) => a + b) / list.length;
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: avg,
                                  width: 34,
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.sentimentColor(avg / 5).withOpacity(0.5),
                                      AppColors.sentimentColor(avg / 5),
                                    ],
                                  ),
                                ),
                              ]);
                            }),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Pie chart: status breakdown ---
              _ChartCard(
                title: 'Status breakdown',
                child: all.isEmpty
                    ? const SizedBox(
                        height: 160,
                        child: Center(child: Text('No data yet', style: TextStyle(color: AppColors.textSecondary))))
                    : Row(
                        children: [
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: (byStatus[FeedbackStatus.pending] ?? 0).toDouble(),
                                    color: AppColors.sentimentMid,
                                    title: '',
                                    radius: 24,
                                  ),
                                  PieChartSectionData(
                                    value: (byStatus[FeedbackStatus.reviewed] ?? 0).toDouble(),
                                    color: AppColors.skyGlow,
                                    title: '',
                                    radius: 24,
                                  ),
                                  PieChartSectionData(
                                    value: (byStatus[FeedbackStatus.resolved] ?? 0).toDouble(),
                                    color: AppColors.sentimentHigh,
                                    title: '',
                                    radius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendRow('Pending', AppColors.sentimentMid, byStatus[FeedbackStatus.pending] ?? 0),
                                _legendRow('Reviewed', AppColors.skyGlow, byStatus[FeedbackStatus.reviewed] ?? 0),
                                _legendRow('Resolved', AppColors.sentimentHigh, byStatus[FeedbackStatus.resolved] ?? 0),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              _ChartCard(
                title: 'Volume by category',
                child: Column(
                  children: FeedbackCategory.values.map((c) {
                    final count = byCategory[c]?.length ?? 0;
                    final total = all.isEmpty ? 1 : all.length;
                    final ratio = count / total;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                              Text('$count', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.violet),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendRow(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text('$count', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
