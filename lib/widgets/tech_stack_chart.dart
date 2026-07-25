import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class TechStackChart extends StatefulWidget {
  final List<TechStackItem> techStack;
  const TechStackChart({super.key, required this.techStack});
  @override
  State<TechStackChart> createState() => _TechStackChartState();
}

class _TechStackChartState extends State<TechStackChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  Map<String, List<TechStackItem>> get _byCategory {
    final map = <String, List<TechStackItem>>{};
    for (final item in widget.techStack) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = _byCategory;
    final keys = cats.keys.toList();
    final total = widget.techStack.length;
    final touched = _touchedIndex >= 0 && _touchedIndex < keys.length;
    final touchKey = touched ? keys[_touchedIndex] : null;
    final touchItems = touchKey != null ? cats[touchKey]! : <TechStackItem>[];

    final sections =
        keys.asMap().entries.map((e) {
          final isTouched = e.key == _touchedIndex;
          final color =
              AppColors.chartPalette[e.key % AppColors.chartPalette.length];
          final pct = ((cats[e.value]!.length / total) * 100).toStringAsFixed(
            0,
          );
          return PieChartSectionData(
            value: cats[e.value]!.length.toDouble(),
            color: color,
            radius: isTouched ? 62 : 52,
            title: '$pct%',
            titleStyle: TextStyle(
              color: isTouched ? Colors.white : Colors.white70,
              fontSize: isTouched ? 12 : 10,
              fontWeight: FontWeight.w800,
            ),
            borderSide:
                isTouched
                    ? BorderSide(color: color, width: 2.5)
                    : BorderSide.none,
            badgeWidget: isTouched ? null : null,
          );
        }).toList();

    return SectionCard(
      title: 'Tech Stack Breakdown',
      icon: Icons.donut_large_outlined,
      child: Column(
        children: [
          // Insight callout
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child:
                touched
                    ? _InsightBox(
                      key: ValueKey(touchKey),
                      color:
                          AppColors.chartPalette[_touchedIndex %
                              AppColors.chartPalette.length],
                      category: touchKey!,
                      count: touchItems.length,
                      total: total,
                      items: touchItems,
                    )
                    : _InsightBox(
                      key: const ValueKey('default'),
                      color: AppColors.accent,
                      category: 'All Categories',
                      count: total,
                      total: total,
                      items: widget.techStack,
                      isDefault: true,
                    ),
          ),
          const SizedBox(height: 16),

          // Chart
          AnimatedBuilder(
            animation: _anim,
            builder:
                (_, __) => SizedBox(
                  height: 210,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 46,
                      sectionsSpace: 3,
                      startDegreeOffset: -90,
                      pieTouchData: PieTouchData(
                        touchCallback: (ev, resp) {
                          setState(() {
                            _touchedIndex =
                                (ev.isInterestedForInteractions &&
                                        resp?.touchedSection != null)
                                    ? resp!.touchedSection!.touchedSectionIndex
                                    : -1;
                          });
                        },
                      ),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 300),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                ),
          ),

          const SizedBox(height: 16),

          // Legend grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: keys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final color =
                  AppColors.chartPalette[i % AppColors.chartPalette.length];
              final isActive = i == _touchedIndex;
              return GestureDetector(
                onTap: () => setState(() => _touchedIndex = isActive ? -1 : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? color.withOpacity(0.15)
                            : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isActive ? color.withOpacity(0.5) : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          keys[i][0].toUpperCase() + keys[i].substring(1),
                          style: TextStyle(
                            color: isActive ? color : AppColors.textSub,
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${cats[keys[i]]!.length}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  final Color color;
  final String category;
  final int count, total;
  final List<TechStackItem> items;
  final bool isDefault;
  const _InsightBox({
    super.key,
    required this.color,
    required this.category,
    required this.count,
    required this.total,
    required this.items,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (count / total * 100).toStringAsFixed(0);
    final names = items.take(4).map((e) => e.name).join(', ');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isDefault ? '${total}' : '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDefault
                      ? 'Tap a slice to explore'
                      : '$category  ·  $pct% of stack',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDefault
                      ? '${items.map((e) => e.category).toSet().length} categories — tap any segment for details'
                      : names + (items.length > 4 ? '…' : ''),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
