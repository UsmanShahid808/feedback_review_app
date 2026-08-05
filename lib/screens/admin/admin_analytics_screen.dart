import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/feedback_service.dart';
import '../../models/feedback_model.dart';
import '../../widgets/common_widgets.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();

    return SafeArea(
      child: StreamBuilder<List<FeedbackModel>>(
        stream: feedbackService.streamAllFeedback(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StreamErrorState(error: snapshot.error);
          }
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
              Text('Trends across every submission, updated live.',
                  style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 13.5)),
              const SizedBox(height: 26),

              // --- Line chart: submissions over the last 7 days ---
              _ChartCard(
                title: 'Submissions — last 7 days',
                child: SizedBox(
                  height: 200,
                  child: all.isEmpty
                      ? Center(child: Text('No data yet', style: TextStyle(color: AppColors.textSecondaryC(context))))
                      : Builder(builder: (context) {
                          final now = DateTime.now();
                          final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
                          final counts = days.map((d) {
                            return all.where((e) =>
                                e.createdAt.year == d.year &&
                                e.createdAt.month == d.month &&
                                e.createdAt.day == d.day).length;
                          }).toList();
                          final maxY = (counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b)).toDouble();
                          const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                          return LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: maxY < 4 ? 4 : maxY + 1,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= days.length) return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          weekdayLabels[days[idx].weekday - 1],
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryC(context)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(counts.length, (i) => FlSpot(i.toDouble(), counts[i].toDouble())),
                                  isCurved: true,
                                  color: AppColors.violet,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [AppColors.violet.withOpacity(0.25), AppColors.violet.withOpacity(0.0)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                ),
              ),
              const SizedBox(height: 20),

              // --- Bar chart: average rating per category ---
              _ChartCard(
                title: 'Average rating by category',
                child: SizedBox(
                  height: 220,
                  child: all.isEmpty
                      ? Center(child: Text('No data yet', style: TextStyle(color: AppColors.textSecondaryC(context))))
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
                                      child: Text(cats[idx].label, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryC(context))),
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
                        child: Center(child: Text('No data yet', style: TextStyle(color: AppColors.textSecondaryC(context)))))
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
                                _legendRow(context, 'Pending', AppColors.sentimentMid, byStatus[FeedbackStatus.pending] ?? 0),
                                _legendRow(context, 'Reviewed', AppColors.skyGlow, byStatus[FeedbackStatus.reviewed] ?? 0),
                                _legendRow(context, 'Resolved', AppColors.sentimentHigh, byStatus[FeedbackStatus.resolved] ?? 0),
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
                              Text('$count', style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 12.5)),
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

  Widget _legendRow(BuildContext context, String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text('$count', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryC(context))),
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
      decoration: BoxDecoration(color: AppColors.cardColor(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor(context))),
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
