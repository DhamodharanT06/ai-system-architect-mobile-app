import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/blueprint.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_banner_ad_widget.dart';
import '../widgets/section_card.dart';
import '../widgets/tech_stack_chart.dart';
import '../widgets/architecture_chart.dart';
import '../widgets/workflow_stepper.dart';
import '../widgets/execution_flow_view.dart';
import '../widgets/learning_hub_view.dart';
import '../widgets/timeline_chart.dart';
import '../widgets/ui_preview_webview.dart';
import '../widgets/share_export_button.dart';
import '../widgets/section_card.dart';

class BlueprintDetailScreen extends StatefulWidget {
  final Blueprint blueprint;
  const BlueprintDetailScreen({super.key, required this.blueprint});

  @override
  State<BlueprintDetailScreen> createState() => _BlueprintDetailScreenState();
}

class _BlueprintDetailScreenState extends State<BlueprintDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Blueprint get bp => widget.blueprint;

  // Keys for always-visible sections (registered for share capture)
  final _overviewKey = GlobalKey();
  final _archKey = GlobalKey();
  final _techKey = GlobalKey();
  final _workflowKey = GlobalKey();
  final _timelineKey = GlobalKey();

  static const _tabLabels = [
    ('Overview', Icons.dashboard_outlined),
    ('Architecture', Icons.account_tree_outlined),
    ('Tech Stack', Icons.layers_outlined),
    ('Workflow', Icons.linear_scale_outlined),
    ('Flow', Icons.alt_route_outlined),
    ('UI Preview', Icons.phone_android_outlined),
    ('Learn', Icons.school_outlined),
    ('Timeline', Icons.timeline_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          bp.projectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.border,
          tabs:
              _tabLabels
                  .map(
                    (t) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$2, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            t.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
        // actions: [
        //   ShareExportButton(
        //     blueprint: bp,
        //     extraKeys: {
        //       'overview': _overviewKey,
        //       'architecture': _archKey,
        //       'tech-stack': _techKey,
        //       'workflow': _workflowKey,
        //       'timeline': _timelineKey,
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                RepaintBoundary(key: _overviewKey, child: _OverviewTab(bp: bp)),
                RepaintBoundary(key: _archKey, child: _ArchitectureTab(bp: bp)),
                RepaintBoundary(key: _techKey, child: _TechStackTab(bp: bp)),
                RepaintBoundary(key: _workflowKey, child: _WorkflowTab(bp: bp)),
                _FlowTab(bp: bp),
                _UiPreviewTab(bp: bp),
                LearningHubView(references: bp.learningReferences),
                RepaintBoundary(key: _timelineKey, child: _TimelineTab(bp: bp)),
              ],
            ),
          ),
          // Non-intrusive banner at bottom of detail screen
          const AppBannerAdWidget(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ══════════════════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final Blueprint bp;
  const _OverviewTab({required this.bp});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project description card
        _GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      'DEEP DIVE INTO',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  bp.projectName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bp.description,
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 12),

        // Quick stats row
        _StatsRow(bp: bp),

        const SizedBox(height: 12),

        // Budget
        if (bp.estimatedBudget != null)
          SectionCard(
            title: 'Estimated Budget',
            icon: Icons.attach_money,
            child: Text(
              bp.estimatedBudget!,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 12),

        // Next Steps
        SectionCard(
          title: 'Next Steps',
          icon: Icons.rocket_launch_outlined,
          child: Column(
            children:
                bp.nextSteps
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.accentGlow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                e.value,
                                style: const TextStyle(
                                  color: AppColors.textSub,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        // Real world examples
        SectionCard(
          title: 'Real World Examples',
          icon: Icons.public,
          child: Column(
            children:
                bp.realWorldExamples
                    .map(
                      (ex) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ex.title,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.laneAI.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ex.company,
                                    style: const TextStyle(
                                      color: AppColors.laneAI,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ex.description,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            if (ex.lessonsLearned.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...ex.lessonsLearned
                                  .take(3)
                                  .map(
                                    (l) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lightbulb_outline,
                                            color: AppColors.warning,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              l,
                                              style: const TextStyle(
                                                color: AppColors.textSub,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                            if (ex.link != null) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => launchUrl(Uri.parse(ex.link!)),
                                child: const Text(
                                  'View Case Study →',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Blueprint bp;
  const _StatsRow({required this.bp});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Components Count',
        '${bp.systemArchitecture.length}',
        Icons.account_tree_outlined,
        AppColors.accent,
      ),
      (
        'Tech Items',
        '${bp.techStack.length}',
        Icons.layers_outlined,
        AppColors.laneAI,
      ),
      (
        'Workflow Steps',
        '${bp.workflow.length}',
        Icons.linear_scale_outlined,
        AppColors.laneBack,
      ),
      (
        'Total Approach',
        '${bp.solutionApproaches.length}',
        Icons.alt_route_outlined,
        AppColors.laneDB,
      ),
    ];
    return Row(
      children:
          stats
              .map(
                (s) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: s == stats.last ? 0 : 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(s.$3, color: s.$4, size: 20),
                        const SizedBox(height: 6),
                        Text(
                          s.$2,
                          style: TextStyle(
                            color: s.$4,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.$1,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _GlowCard extends StatelessWidget {
  final Widget child;
  const _GlowCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.surface, AppColors.accent.withOpacity(0.04)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ARCHITECTURE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _ArchitectureTab extends StatelessWidget {
  final Blueprint bp;
  const _ArchitectureTab({required this.bp});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArchitectureChart(components: bp.systemArchitecture),
        const SizedBox(height: 16),
        ...bp.systemArchitecture.asMap().entries.map(
          (e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeBadge(type: e.value.type),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.value.description,
                      style: const TextStyle(
                        color: AppColors.textSub,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    if (e.value.technologies.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            e.value.technologies
                                .map(
                                  (t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGlow,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    if (e.value.responsibilities.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...e.value.responsibilities
                          .take(3)
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_right,
                                    color: AppColors.accent,
                                    size: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                        color: AppColors.textSub,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: e.key * 80))
              .slideY(begin: 0.05, end: 0),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  static const _colors = {
    'frontend': AppColors.laneFront,
    'backend': AppColors.laneBack,
    'database': AppColors.laneDB,
    'external_api': AppColors.laneAI,
    'infrastructure': AppColors.laneOutput,
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors[type.toLowerCase()] ?? AppColors.textSub;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        type.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: c,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TECH STACK TAB
// ══════════════════════════════════════════════════════════════════════════════
class _TechStackTab extends StatelessWidget {
  final Blueprint bp;
  const _TechStackTab({required this.bp});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TechStackChart(techStack: bp.techStack),
        const SizedBox(height: 16),
        ...bp.techStack.asMap().entries.map((e) {
          final item = e.value;
          final color =
              AppColors.chartPalette[e.key % AppColors.chartPalette.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.category,
                            style: TextStyle(color: color, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (item.version != null)
                      Text(
                        'v${item.version}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.reason,
                  style: const TextStyle(
                    color: AppColors.textSub,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                if (item.languages.isNotEmpty ||
                    item.frameworks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...item.languages.map(
                        (l) => _Chip(label: l, color: AppColors.laneAI),
                      ),
                      ...item.frameworks.map(
                        (f) => _Chip(label: f, color: AppColors.laneBack),
                      ),
                      ...item.modules
                          .take(2)
                          .map((m) => _Chip(label: m, color: AppColors.laneDB)),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: e.key * 60));
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// WORKFLOW TAB
// ══════════════════════════════════════════════════════════════════════════════
class _WorkflowTab extends StatelessWidget {
  final Blueprint bp;
  const _WorkflowTab({required this.bp});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      WorkflowStepper(steps: bp.workflow),
      const SizedBox(height: 12),
      SectionCard(
        title: 'Prerequisites',
        icon: Icons.checklist_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              bp.prerequisites
                  .map(
                    (p) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.category,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...p.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.laneDB,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: AppColors.textSub,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
      const SizedBox(height: 12),
      // Solution approaches
      ...bp.solutionApproaches.asMap().entries.map((e) {
        final approach = e.value;
        final complexColor =
            approach.complexity == 'Simple'
                ? AppColors.laneDB
                : approach.complexity == 'Complex'
                ? AppColors.error
                : AppColors.laneBack;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      approach.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: complexColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      approach.complexity,
                      style: TextStyle(
                        color: complexColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                approach.description,
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pros',
                          style: TextStyle(
                            color: AppColors.laneDB,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...approach.pros
                            .take(3)
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.laneDB,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        p,
                                        style: const TextStyle(
                                          color: AppColors.textSub,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cons',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...approach.cons
                            .take(3)
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.error,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          color: AppColors.textSub,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '⏱ ${approach.estimatedTime}  •  Best for: ${approach.bestFor}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: e.key * 80));
      }),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// FLOW TAB  (runtime execution flow)
// ══════════════════════════════════════════════════════════════════════════════
class _FlowTab extends StatefulWidget {
  final Blueprint bp;
  const _FlowTab({required this.bp});
  @override
  State<_FlowTab> createState() => _FlowTabState();
}

class _FlowTabState extends State<_FlowTab> {
  List<RuntimeFlowStep>? _steps;
  bool _loading = false;
  String? _error;

  // Called by buttons — gates through rewarded ad every 3rd press
  void _onGenerateTapped() {
    final adService = context.read<AdService>();
    adService.handleFeatureAction(
      featureKey: 'flow',
      onAdComplete: _doGenerate,
      onAdSkipped: _doGenerate, // ad not ready — proceed anyway
    );
  }

  Future<void> _doGenerate() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final steps = await api.generateRuntimeFlow(
        projectName: widget.bp.projectName,
        context: widget.bp.description,
      );
      if (mounted)
        setState(() {
          _steps = steps;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    if (_error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onGenerateTapped,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    if (_steps == null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alt_route, color: AppColors.accent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Runtime Execution Flow',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'See exactly how your app runs at runtime — from user action to final output',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onGenerateTapped,
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Generate Flow'),
            ),
          ],
        ),
      );
    return ExecutionFlowView(steps: _steps!);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// UI PREVIEW TAB
// ══════════════════════════════════════════════════════════════════════════════
class _UiPreviewTab extends StatefulWidget {
  final Blueprint bp;
  const _UiPreviewTab({required this.bp});
  @override
  State<_UiPreviewTab> createState() => _UiPreviewTabState();
}

class _UiPreviewTabState extends State<_UiPreviewTab> {
  String? _html;
  bool _loading = false;
  String? _error;

  // Called by buttons — gates through rewarded ad every 3rd press
  void _onGenerateTapped() {
    final adService = context.read<AdService>();
    adService.handleFeatureAction(
      featureKey: 'preview',
      onAdComplete: _doGenerate,
      onAdSkipped: _doGenerate, // ad not ready — proceed anyway
    );
  }

  Future<void> _doGenerate() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final html = await api.generateUiPreview(
        projectName: widget.bp.projectName,
        context: widget.bp.description,
      );
      if (mounted)
        setState(() {
          _html = html;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Designing your UI…',
              style: TextStyle(color: AppColors.textSub),
            ),
            Text(
              'This takes ~15 seconds',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    if (_error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onGenerateTapped,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    if (_html == null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android, color: AppColors.accent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'UI Preview',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Generate a live interactive mockup of your app',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onGenerateTapped,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Preview'),
            ),
          ],
        ),
      );
    return UiPreviewWebView(html: _html!, projectName: widget.bp.projectName);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TIMELINE TAB
// ══════════════════════════════════════════════════════════════════════════════
class _TimelineTab extends StatelessWidget {
  final Blueprint bp;
  const _TimelineTab({required this.bp});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TimelineChart(timeline: bp.timeline),
      const SizedBox(height: 80),
    ],
  );
}
