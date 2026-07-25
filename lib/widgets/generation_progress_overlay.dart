import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class GenerationProgressOverlay extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final String projectName;

  const GenerationProgressOverlay({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.projectName,
  });

  static const _stepIcons = [
    Icons.travel_explore,
    Icons.description_outlined,
    Icons.memory_outlined,
    Icons.speed_outlined,
    Icons.auto_awesome,
    Icons.build_outlined,
  ];

  static const _stepColors = [
    AppColors.laneUser,
    AppColors.laneFront,
    AppColors.laneAI,
    AppColors.laneBack,
    AppColors.laneDB,
    AppColors.laneOutput,
  ];

  @override
  Widget build(BuildContext context) {
    final progress = steps.isEmpty ? 0.0 : currentStep / steps.length;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: AppColors.background.withOpacity(0.85),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            AppColors.background.withOpacity(0.7),
            BlendMode.darken,
          ),
          child: Center(
            child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 10),
                          const Text(
                            'Generating Blueprint',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (projectName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '"$projectName"',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Steps
                      ...steps.asMap().entries.map((e) {
                        final idx = e.key;
                        final label = e.value;
                        final state =
                            idx < currentStep
                                ? 'done'
                                : idx == currentStep
                                ? 'active'
                                : 'waiting';
                        final color = _stepColors[idx % _stepColors.length];
                        final icon = _stepIcons[idx % _stepIcons.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Icon
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color:
                                      state == 'active'
                                          ? color.withOpacity(0.2)
                                          : state == 'done'
                                          ? color.withOpacity(0.12)
                                          : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        state == 'waiting'
                                            ? AppColors.border
                                            : color.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child:
                                    state == 'active'
                                        ? Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: color,
                                          ),
                                        )
                                        : Icon(
                                          state == 'done' ? Icons.check : icon,
                                          color:
                                              state == 'waiting'
                                                  ? AppColors.border
                                                  : color,
                                          size: 14,
                                        ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color:
                                        state == 'waiting'
                                            ? AppColors.textMuted
                                            : state == 'active'
                                            ? color
                                            : AppColors.textSub,
                                    fontSize: 12,
                                    fontWeight:
                                        state == 'active'
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.accent,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${currentStep.clamp(1, steps.length)} of ${steps.length}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder:
        (_, __) => Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(_anim.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.5 * _anim.value),
                blurRadius: 8,
              ),
            ],
          ),
        ),
  );
}
