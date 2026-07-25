import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';

class WorkflowStepper extends StatefulWidget {
  final List<WorkflowStep> steps;
  const WorkflowStepper({super.key, required this.steps});
  @override
  State<WorkflowStepper> createState() => _WorkflowStepperState();
}

class _WorkflowStepperState extends State<WorkflowStepper> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          widget.steps.asMap().entries.map((e) {
            final step = e.value;
            final idx = e.key;
            final isExpanded = _expanded == idx;
            final isLast = idx == widget.steps.length - 1;
            final colors = AppColors.chartPalette;
            final color = colors[idx % colors.length];

            return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline column
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isExpanded ? color : color.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 1.5),
                            ),
                            child: Text(
                              '${step.stepNumber}',
                              style: TextStyle(
                                color: isExpanded ? Colors.black : color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: isExpanded ? 140 : 40,
                              color: color.withOpacity(0.25),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(
                              () => _expanded = isExpanded ? null : idx,
                            ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                isExpanded
                                    ? color.withOpacity(0.07)
                                    : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isExpanded
                                      ? color.withOpacity(0.4)
                                      : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      step.title,
                                      style: TextStyle(
                                        color:
                                            isExpanded ? color : AppColors.text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: color.withOpacity(0.7),
                                    size: 18,
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                Text(
                                  step.description,
                                  style: const TextStyle(
                                    color: AppColors.textSub,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                                if (step.componentsInvolved.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Components',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 5,
                                    children:
                                        step.componentsInvolved
                                            .map(
                                              (c) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: color.withOpacity(
                                                      0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  c,
                                                  style: TextStyle(
                                                    color: color,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                                if (step.keyActions.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Key Actions',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ...step.keyActions.map(
                                    (a) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_right_alt,
                                            color: color,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              a,
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
                              ] else ...[
                                const SizedBox(height: 4),
                                Text(
                                  step.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: idx * 60))
                .slideX(begin: 0.04, end: 0);
          }).toList(),
    );
  }
}
