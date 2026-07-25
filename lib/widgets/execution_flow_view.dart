import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';

/// Duolingo-style winding path execution flow.
/// Uses AnimatedScale + explicit rebuild instead of AnimatedContainer
/// to avoid DecorationTween / BoxShadow lerp crashes.
class ExecutionFlowView extends StatefulWidget {
  final List<RuntimeFlowStep> steps;
  const ExecutionFlowView({super.key, required this.steps});
  @override
  State<ExecutionFlowView> createState() => _ExecutionFlowViewState();
}

class _ExecutionFlowViewState extends State<ExecutionFlowView> {
  int? _active;

  static const _laneConfig = <String, _LaneCfg>{
    'user': _LaneCfg(
      color: AppColors.laneUser,
      icon: Icons.person_rounded,
      label: 'User',
    ),
    'frontend': _LaneCfg(
      color: AppColors.laneFront,
      icon: Icons.phone_android,
      label: 'Frontend',
    ),
    'backend': _LaneCfg(
      color: AppColors.laneBack,
      icon: Icons.settings_rounded,
      label: 'Backend',
    ),
    'ai': _LaneCfg(
      color: AppColors.laneAI,
      icon: Icons.smart_toy_rounded,
      label: 'AI / LLM',
    ),
    'database': _LaneCfg(
      color: AppColors.laneDB,
      icon: Icons.storage_rounded,
      label: 'Database',
    ),
    'output': _LaneCfg(
      color: AppColors.laneOutput,
      icon: Icons.check_circle_rounded,
      label: 'Output',
    ),
  };

  // Winding x-positions (fraction of screen width)
  static const _xFracs = [
    0.5,
    0.76,
    0.5,
    0.24,
    0.5,
    0.76,
    0.5,
    0.24,
    0.5,
    0.76,
    0.5,
    0.24,
    0.5,
    0.76,
  ];

  static const double _nodeR = 30.0;
  static const double _rowH = 108.0;
  static const double _topOff = 44.0;

  _LaneCfg _cfg(String lane) => _laneConfig[lane] ?? _laneConfig['backend']!;

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final width = MediaQuery.of(context).size.width;
    final totalH = _topOff + steps.length * _rowH + 32.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Legend ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children:
                  _laneConfig.entries
                      .where((e) => steps.any((s) => s.lane == e.key))
                      .map(
                        (e) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(e.value.icon, color: e.value.color, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              e.value.label,
                              style: TextStyle(
                                color: e.value.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),

          // ── Path canvas ──────────────────────────────────────────────────
          SizedBox(
            width: width,
            height: totalH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dashed path lines
                CustomPaint(
                  size: Size(width, totalH),
                  painter: _PathPainter(
                    steps: steps,
                    xFracs: _xFracs,
                    width: width,
                    rowH: _rowH,
                    topOff: _topOff,
                    nodeR: _nodeR,
                    laneCfg: _laneConfig,
                  ),
                ),

                // Step nodes — NO AnimatedContainer, no DecorationTween
                ...steps.asMap().entries.map((e) {
                  final idx = e.key;
                  final step = e.value;
                  final cfg = _cfg(step.lane);
                  final xFrac = _xFracs[idx % _xFracs.length];
                  final cx = width * xFrac;
                  final cy = _topOff + idx * _rowH;
                  final isActive = _active == idx;
                  final isDone = _active != null && idx < _active!;

                  return Positioned(
                    left: cx - _nodeR,
                    top: cy - _nodeR,
                    child: GestureDetector(
                      onTap:
                          () => setState(() => _active = isActive ? null : idx),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Node — plain DecoratedBox, no lerp ──
                          AnimatedScale(
                            scale: isActive ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutBack,
                            child: _NodeCircle(
                              cfg: cfg,
                              isActive: isActive,
                              isDone: isDone,
                              radius: _nodeR,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // ── Label ──
                          SizedBox(
                            width: 88,
                            child: Text(
                              step.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isActive ? cfg.color : AppColors.textSub,
                                fontSize: 9,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(
                      delay: Duration(milliseconds: 60 + idx * 55),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                    ),
                  );
                }),

                // ── Detail card ──
                if (_active != null && _active! < steps.length)
                  _DetailCard(
                    step: steps[_active!],
                    idx: _active!,
                    width: width,
                    rowH: _rowH,
                    topOff: _topOff,
                    nodeR: _nodeR,
                    xFracs: _xFracs,
                    cfg: _cfg(steps[_active!].lane),
                    onClose: () => setState(() => _active = null),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plain circle node — NO AnimatedContainer, no BoxDecoration lerp.
// AnimatedScale handles the size change; DecoratedBox is rebuilt directly.
// ─────────────────────────────────────────────────────────────────────────────
class _NodeCircle extends StatelessWidget {
  final _LaneCfg cfg;
  final bool isActive, isDone;
  final double radius;

  const _NodeCircle({
    required this.cfg,
    required this.isActive,
    required this.isDone,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg =
        isDone
            ? cfg.color.withOpacity(0.22)
            : isActive
            ? cfg.color
            : AppColors.surface;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring — separate widget, opacity animated safely
        if (isActive)
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: radius * 2 + 14,
              height: radius * 2 + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cfg.color.withOpacity(0.18),
              ),
            ),
          ),

        // Main circle — completely static decoration, rebuilt on setState
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: cfg.color, width: isActive ? 2.5 : 1.8),
          ),
          child: Center(
            child:
                isDone
                    ? Icon(Icons.check_rounded, color: cfg.color, size: 18)
                    : Icon(
                      cfg.icon,
                      color: isActive ? Colors.black : cfg.color,
                      size: isActive ? 20 : 17,
                    ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail card — floats near the tapped node
// ─────────────────────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final RuntimeFlowStep step;
  final int idx;
  final double width, rowH, topOff, nodeR;
  final List<double> xFracs;
  final _LaneCfg cfg;
  final VoidCallback onClose;

  const _DetailCard({
    required this.step,
    required this.idx,
    required this.width,
    required this.rowH,
    required this.topOff,
    required this.nodeR,
    required this.xFracs,
    required this.cfg,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cx = width * xFracs[idx % xFracs.length];
    final cy = topOff + idx * rowH;
    const cardW = 280.0;
    final left = (cx - cardW / 2).clamp(8.0, width - cardW - 8);
    final placeTop = cy > 180;
    final top = placeTop ? cy - nodeR - 130.0 : cy + nodeR + 12.0;

    return Positioned(
      left: left,
      top: top,
      width: cardW,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cfg.color.withOpacity(0.5), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cfg.icon, color: cfg.color, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          cfg.label,
                          style: TextStyle(
                            color: cfg.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Step ${idx + 1}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                step.title,
                style: TextStyle(
                  color: cfg.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),

              // Detail
              Text(
                step.detail,
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),

              // Arrow label
              if (step.arrowTo != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: cfg.color,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        step.arrowLabel ?? step.arrowTo!,
                        style: TextStyle(
                          color: cfg.color,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.06, end: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed cubic bezier path between consecutive nodes
// ─────────────────────────────────────────────────────────────────────────────
class _PathPainter extends CustomPainter {
  final List<RuntimeFlowStep> steps;
  final List<double> xFracs;
  final double width, rowH, topOff, nodeR;
  final Map<String, _LaneCfg> laneCfg;

  const _PathPainter({
    required this.steps,
    required this.xFracs,
    required this.width,
    required this.rowH,
    required this.topOff,
    required this.nodeR,
    required this.laneCfg,
  });

  _LaneCfg _cfg(String lane) => laneCfg[lane] ?? laneCfg['backend']!;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < steps.length - 1; i++) {
      final fromCfg = _cfg(steps[i].lane);
      final toCfg = _cfg(steps[i + 1].lane);

      final x1 = width * xFracs[i % xFracs.length];
      final y1 = topOff + i * rowH + nodeR;
      final x2 = width * xFracs[(i + 1) % xFracs.length];
      final y2 = topOff + (i + 1) * rowH - nodeR;

      final paint =
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                fromCfg.color.withOpacity(0.45),
                toCfg.color.withOpacity(0.45),
              ],
            ).createShader(
              Rect.fromLTWH(x1 < x2 ? x1 : x2, y1, (x2 - x1).abs(), y2 - y1),
            )
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      final path =
          Path()
            ..moveTo(x1, y1)
            ..cubicTo(x1, y1 + rowH * 0.38, x2, y2 - rowH * 0.38, x2, y2);

      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dash = 6,
    double gap = 5,
  }) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final end = (d + (draw ? dash : gap)).clamp(0.0, m.length);
        if (draw) canvas.drawPath(m.extractPath(d, end), paint);
        d = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.steps.length != steps.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Lane config record
// ─────────────────────────────────────────────────────────────────────────────
class _LaneCfg {
  final Color color;
  final IconData icon;
  final String label;
  const _LaneCfg({
    required this.color,
    required this.icon,
    required this.label,
  });
}
