import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class TimelineChart extends StatelessWidget {
  final Map<String, String> timeline;
  const TimelineChart({super.key, required this.timeline});

  static final _durationPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s*(day|week|month|hour)',
  );

  double _parseDuration(String raw) {
    final m = _durationPattern.firstMatch(raw.toLowerCase());
    if (m == null) return 1;
    final n = double.parse(m.group(1)!);
    final unit = m.group(2)!;
    if (unit.startsWith('hour')) return n / (24 * 7);
    if (unit.startsWith('day')) return n / 7;
    if (unit.startsWith('month')) return n * 4;
    return n; // weeks
  }

  @override
  Widget build(BuildContext context) {
    final entries = timeline.entries.toList();
    final durations = entries.map((e) => _parseDuration(e.value)).toList();
    final maxDur = durations.fold(0.0, (a, b) => a > b ? a : b);

    return SectionCard(
      title: 'Project Timeline',
      icon: Icons.timeline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gantt bars
          ...entries.asMap().entries.map((e) {
            final phase = e.value.key;
            final dur = e.value.value;
            final weeks = durations[e.key];
            final fraction = maxDur > 0 ? weeks / maxDur : 0.5;
            final color =
                AppColors.chartPalette[e.key % AppColors.chartPalette.length];

            return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              phase,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            dur,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (_, constraints) {
                          final barW = constraints.maxWidth * fraction;
                          return Stack(
                            children: [
                              Container(
                                height: 28,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 400 + e.key * 80,
                                ),
                                curve: Curves.easeOutCubic,
                                height: 28,
                                width: barW,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color.withOpacity(0.8), color],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child:
                                      barW > 48
                                          ? Text(
                                            '${(fraction * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          )
                                          : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: e.key * 70))
                .slideX(begin: -0.05, end: 0);
          }),

          const Divider(height: 24, color: AppColors.border),

          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Phases', value: '${entries.length}'),
              _Stat(label: 'Total Est.', value: _totalStr(entries)),
            ],
          ),
        ],
      ),
    );
  }

  String _totalStr(List<MapEntry<String, String>> entries) {
    final total = entries
        .map((e) => _parseDuration(e.value))
        .fold(0.0, (a, b) => a + b);
    if (total < 4) return '${total.toStringAsFixed(1)} wks';
    final months = total / 4;
    return '~${months.toStringAsFixed(1)} mo';
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
    ],
  );
}
