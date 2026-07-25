import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';

class LearningHubView extends StatefulWidget {
  final List<LearningReference> references;
  const LearningHubView({super.key, required this.references});
  @override
  State<LearningHubView> createState() => _LearningHubViewState();
}

class _LearningHubViewState extends State<LearningHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _docFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<LearningReference> get _docs => widget.references;

  List<String> get _docTypes {
    final types = {'All', ..._docs.map((r) => r.type)};
    return types.toList();
  }

  List<LearningReference> get _filteredDocs =>
      _docFilter == 'All'
          ? _docs
          : _docs.where((r) => r.type == _docFilter).toList();

  static const _diffColors = {
    'Beginner': AppColors.laneDB,
    'Intermediate': AppColors.laneBack,
    'Advanced': AppColors.error,
  };

  static var _typeIcons = {
    'Research Paper': Icons.science_outlined,
    'Documentation': Icons.description_outlined,
    'Tutorial': Icons.play_lesson_outlined,
    'Guide': Icons.map_outlined,
    'Course': Icons.school_outlined,
    'Blog': Icons.article_outlined,
    'Guide': Icons.explore_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabs,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.accent,
            dividerColor: AppColors.border,
            tabs: const [
              Tab(
                icon: Icon(Icons.book_outlined, size: 16),
                text: 'References',
              ),
              Tab(
                icon: Icon(Icons.play_circle_outline, size: 16),
                text: 'YouTube',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [_docsTab(), _youtubeTab()],
          ),
        ),
      ],
    );
  }

  Widget _docsTab() {
    return Column(
      children: [
        // Filter pills
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _docTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = _docTypes[i];
              final active = _docFilter == t;
              return GestureDetector(
                onTap: () => setState(() => _docFilter = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accentGlow : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          active
                              ? AppColors.accent.withOpacity(0.5)
                              : AppColors.border,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: active ? AppColors.accent : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child:
              _filteredDocs.isEmpty
                  ? const Center(
                    child: Text(
                      'No references found.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredDocs.length,
                    itemBuilder: (_, i) {
                      final ref = _filteredDocs[i];
                      final diffC =
                          _diffColors[ref.difficulty] ?? AppColors.textSub;
                      final icon = _typeIcons[ref.type] ?? Icons.link;
                      return GestureDetector(
                            onTap:
                                () => launchUrl(
                                  Uri.parse(ref.url),
                                  mode: LaunchMode.externalApplication,
                                ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: AppColors.accent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ref.title,
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              ref.type,
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const Text(
                                              '  •  ',
                                              style: TextStyle(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            Text(
                                              ref.difficulty,
                                              style: TextStyle(
                                                color: diffC,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.open_in_new,
                                    color: AppColors.textMuted,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: i * 40))
                          .slideX(begin: 0.04, end: 0);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _youtubeTab() {
    // Generate YouTube search links from tech stack names in references
    final techItems =
        widget.references
            .where(
              (r) =>
                  r.type == 'Research Paper' ||
                  r.type == 'Documentation' ||
                  r.type == 'Guide',
            )
            .take(12)
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: techItems.length + 1,
      itemBuilder: (_, i) {
        if (i == techItems.length) {
          // Full project search banner
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.youtube.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.youtube.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'Full project walkthrough',
                  style: TextStyle(color: AppColors.textSub, fontSize: 12),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap:
                      () => launchUrl(
                        Uri.parse(
                          'https://www.youtube.com/results?search_query=${Uri.encodeComponent('full project tutorial')}',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.youtube.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.youtube.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle,
                          color: AppColors.youtube,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Search Full Tutorial',
                          style: TextStyle(
                            color: AppColors.youtube,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final ref = techItems[i];
        final title = ref.title.split('(').first.trim();
        final ytUrl =
            'https://www.youtube.com/results?search_query=${Uri.encodeComponent('$title tutorial')}';

        return GestureDetector(
          onTap:
              () => launchUrl(
                Uri.parse(ytUrl),
                mode: LaunchMode.externalApplication,
              ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.youtube.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.youtube.withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.youtube,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${ref.type}  •  ${ref.difficulty}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Search →',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
      },
    );
  }
}
