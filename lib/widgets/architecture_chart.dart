import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class ArchitectureChart extends StatefulWidget {
  final List<ArchitectureComponent> components;
  const ArchitectureChart({super.key, required this.components});
  @override
  State<ArchitectureChart> createState() => _ArchitectureChartState();
}

class _ArchitectureChartState extends State<ArchitectureChart>
    with SingleTickerProviderStateMixin {
  int? _touchedBar;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _typeColors = {
    'frontend': AppColors.laneFront,
    'backend': AppColors.laneBack,
    'database': AppColors.laneDB,
    'external_api': AppColors.laneAI,
    'infrastructure': AppColors.laneOutput,
  };

  static const _typeLabels = {
    'frontend': 'Frontend',
    'backend': 'Backend',
    'database': 'Database',
    'external_api': 'Ext. APIs',
    'infrastructure': 'Infra',
  };

  static const _typeInsights = {
    'frontend': 'Handles all user interactions and visual presentation.',
    'backend': 'Core logic, API routing and business rules.',
    'database': 'Persistent storage and data modelling.',
    'external_api': 'Third-party services integrated into the system.',
    'infrastructure': 'Deployment, CI/CD and cloud infrastructure.',
  };

  Map<String, int> get _typeCounts {
    final map = <String, int>{};
    for (final c in widget.components) {
      map[c.type] = (map[c.type] ?? 0) + 1;
    }
    return map;
  }

  Map<String, List<ArchitectureComponent>> get _byType {
    final map = <String, List<ArchitectureComponent>>{};
    for (final c in widget.components) {
      map.putIfAbsent(c.type, () => []).add(c);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counts = _typeCounts;
    final byType = _byType;
    final entries = counts.entries.toList();
    final maxY =
        (entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b) + 1)
            .toDouble();

    final touchedEntry =
        _touchedBar != null && _touchedBar! < entries.length
            ? entries[_touchedBar!]
            : null;
    final touchedItems =
        touchedEntry != null
            ? byType[touchedEntry.key] ?? []
            : <ArchitectureComponent>[];

    return SectionCard(
      title: 'Architecture Breakdown',
      icon: Icons.bar_chart_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insight callout
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                touchedEntry == null
                    ? _DefaultInsight(
                      total: widget.components.length,
                      key: const ValueKey('def'),
                    )
                    : _TouchedInsight(
                      key: ValueKey(touchedEntry.key),
                      type: touchedEntry.key,
                      count: touchedEntry.value,
                      total: widget.components.length,
                      items: touchedItems,
                      color: _typeColors[touchedEntry.key] ?? AppColors.accent,
                      insight: _typeInsights[touchedEntry.key] ?? '',
                    ),
          ),
          const SizedBox(height: 16),

          // Bar chart
          AnimatedBuilder(
            animation: _anim,
            builder:
                (_, __) => SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.surfaceAlt,
                          getTooltipItem: (group, _, rod, __) {
                            final entry = entries[group.x];
                            final color =
                                _typeColors[entry.key] ?? AppColors.accent;
                            return BarTooltipItem(
                              '${_typeLabels[entry.key] ?? entry.key}\n',
                              TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${entry.value} component${entry.value > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.textSub,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (ev, resp) {
                          setState(() {
                            _touchedBar =
                                (ev.isInterestedForInteractions &&
                                        resp?.spot != null)
                                    ? resp!.spot!.touchedBarGroupIndex
                                    : null;
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: 1,
                            getTitlesWidget:
                                (v, _) =>
                                    v == v.floorToDouble()
                                        ? Text(
                                          v.toInt().toString(),
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 9,
                                          ),
                                        )
                                        : const SizedBox.shrink(),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) {
                              if (v.toInt() >= entries.length)
                                return const SizedBox.shrink();
                              final key = entries[v.toInt()].key;
                              final color =
                                  _typeColors[key] ?? AppColors.accent;
                              final isTouched = v.toInt() == _touchedBar;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _typeLabels[key] ?? key,
                                  style: TextStyle(
                                    color:
                                        isTouched ? color : AppColors.textMuted,
                                    fontSize: 9,
                                    fontWeight:
                                        isTouched
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (_) => const FlLine(
                              color: AppColors.border,
                              strokeWidth: 0.8,
                            ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          entries.asMap().entries.map((e) {
                            final color =
                                _typeColors[e.value.key] ?? AppColors.accent;
                            final isTouched = e.key == _touchedBar;
                            final barH = e.value.value.toDouble() * _anim.value;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: barH,
                                  width: 32,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [color, color.withOpacity(0.55)],
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: maxY,
                                    color:
                                        isTouched
                                            ? color.withOpacity(0.12)
                                            : color.withOpacity(0.05),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _DefaultInsight extends StatelessWidget {
  final int total;
  const _DefaultInsight({super.key, required this.total});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.accent.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(Icons.touch_app_outlined, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Tap any bar to see components in that layer  ·  $total total',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _TouchedInsight extends StatelessWidget {
  final String type, insight;
  final int count, total;
  final List<ArchitectureComponent> items;
  final Color color;
  const _TouchedInsight({
    super.key,
    required this.type,
    required this.insight,
    required this.count,
    required this.total,
    required this.items,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final names = items.map((e) => e.name).take(3).join(', ');
    final pct = (count / total * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$count of $total  ·  $pct%',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight,
            style: const TextStyle(color: AppColors.textSub, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            names + (items.length > 3 ? '…' : ''),
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
