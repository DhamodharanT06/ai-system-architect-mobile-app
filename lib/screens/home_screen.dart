import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/blueprint.dart';
import '../services/ad_service.dart';
import '../services/blueprint_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/generation_progress_overlay.dart';
import '../widgets/app_banner_ad_widget.dart';
import 'blueprint_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showContext = false;

  final _examples = [
    'Build an E-commerce Platform',
    'Real-time Chat Application',
    'Fitness Tracking App',
    'AI Document Summariser',
    'Multi-tenant SaaS Dashboard',
    'Video Streaming Service',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _contextCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final problem = _inputCtrl.text.trim();
    if (problem.isEmpty) {
      _showSnack('Please describe your project idea');
      return;
    }

    FocusScope.of(context).unfocus();

    final adService = context.read<AdService>();
    final provider = context.read<BlueprintProvider>();

    await adService.handlePreGeneration(
      onAdComplete: () => _doGenerate(provider, problem),
      onAdSkipped: () => _doGenerate(provider, problem),
    );
  }

  void _doGenerate(BlueprintProvider provider, String problem) async {
    final blueprint = await provider.generate(
      problem,
      context: _showContext ? _contextCtrl.text.trim() : null,
    );

    if (blueprint != null && mounted) {
      Navigator.push(
        context,
        _slideRoute(BlueprintDetailScreen(blueprint: blueprint)),
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder:
        (_, a, __, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
    transitionDuration: const Duration(milliseconds: 350),
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlueprintProvider>();
    final isGenerating = provider.state == GenerationState.generating;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("assets/images/app_icon.png"),
                    ),
                    // gradient: const LinearGradient(
                    //   colors: [AppColors.accent, AppColors.laneAI],
                    // ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('ArchiMind'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Banner Ad — top, subtle ─────────────────────────────────
              // const AppBannerAdWidget(),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    // Hero input card
                    SliverToBoxAdapter(child: _buildInputCard()),

                    // Examples
                    SliverToBoxAdapter(child: _buildExamples()),

                    // History
                    if (provider.history.isNotEmpty)
                      SliverToBoxAdapter(child: _buildHistoryHeader()),

                    if (provider.history.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildHistoryItem(
                            provider.history[i],
                            i,
                            provider,
                          ),
                          childCount: provider.history.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
              const AppBannerAdWidget(),
            ],
          ),
        ),

        // Generation progress overlay
        if (isGenerating)
          GenerationProgressOverlay(
            currentStep: provider.currentStep,
            steps: provider.progressSteps,
            projectName: _inputCtrl.text.trim(),
          ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated heading
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [AppColors.laneAI, AppColors.laneAI],
                ).createShader(b),
            child: const Text(
              'What are you building?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 6),
          const Text(
            'Describe your project, get a full architecture blueprint',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Main input
          TextField(
            controller: _inputCtrl,
            maxLines: 3,
            minLines: 2,
            decoration: const InputDecoration(
              hintText:
                  'e.g. Build a real-time collaborative code editor with AI suggestions…',
            ),
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            textInputAction: TextInputAction.newline,
          ).animate().fadeIn(delay: 250.ms),

          // Optional context toggle
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _showContext = !_showContext),
            child: Row(
              children: [
                Icon(
                  _showContext ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _showContext
                      ? 'Hide additional details'
                      : 'Add details (optional)',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (_showContext) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _contextCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Target users, tech preferences, scale requirements…',
              ),
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ).animate().fadeIn(),
          ],

          const SizedBox(height: 16),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generate Architect'),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            'Try an example',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _examples.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder:
                (_, i) => GestureDetector(
                  onTap: () => setState(() => _inputCtrl.text = _examples[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _examples[i],
                      style: const TextStyle(
                        color: AppColors.textSub,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Text(
        'Recent Blueprints',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showRenameDialog(Blueprint bp, int i, BlueprintProvider provider) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => _RenameDialog(
            initialTitle: bp.projectName,
            initialSubtitle: bp.description,
            onSave:
                (title, subtitle) => provider.renameHistory(i, title, subtitle),
          ),
    );
  }

  Widget _buildHistoryItem(Blueprint bp, int i, BlueprintProvider provider) {
    return Dismissible(
          key: ValueKey('${bp.projectName}_$i'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.error.withOpacity(0.15),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          onDismissed: (_) => provider.deleteFromHistory(i),
          child: GestureDetector(
            onTap: () {
              provider.setCurrentBlueprint(bp);
              Navigator.push(
                context,
                _slideRoute(BlueprintDetailScreen(blueprint: bp)),
              );
            },
            onLongPress: () => _showRenameDialog(bp, i, provider),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schema_outlined,
                      color: AppColors.laneAI,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bp.projectName,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          bp.description,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'hold to edit',
                        style: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.5),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: i * 60))
        .slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rename dialog — StatefulWidget owns the controllers so they are never
// disposed while the dialog is still open (fixes the "controller disposed"
// crash when pressing Cancel or Save).
// ─────────────────────────────────────────────────────────────────────────────
class _RenameDialog extends StatefulWidget {
  final String initialTitle;
  final String initialSubtitle;
  final void Function(String title, String subtitle) onSave;

  const _RenameDialog({
    required this.initialTitle,
    required this.initialSubtitle,
    required this.onSave,
  });

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _subtitleCtrl = TextEditingController(text: widget.initialSubtitle);
  }

  @override
  void dispose() {
    // dispose() is called AFTER the widget is removed from the tree,
    // i.e. after Navigator.pop — so controllers are always alive while
    // the dialog is visible.
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final subtitle = _subtitleCtrl.text.trim();
    if (title.isNotEmpty) {
      widget.onSave(title, subtitle);
    }
    Navigator.pop(context);
  }

  void _cancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text(
        'Edit Blueprint',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
            style: const TextStyle(color: AppColors.text),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleCtrl,
            decoration: const InputDecoration(labelText: 'Subtitle'),
            style: const TextStyle(color: AppColors.text),
            maxLines: 2,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
