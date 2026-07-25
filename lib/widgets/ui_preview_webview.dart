import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

/// Compact mobile-first UI preview — renders the HTML in a phone frame.
class UiPreviewWebView extends StatefulWidget {
  final String html;
  final String projectName;
  const UiPreviewWebView({
    super.key,
    required this.html,
    required this.projectName,
  });
  @override
  State<UiPreviewWebView> createState() => _UiPreviewWebViewState();
}

class _UiPreviewWebViewState extends State<UiPreviewWebView> {
  late WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) => setState(() => _loading = false),
            ),
          )
          ..loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    // Phone frame dimensions — compact, realistic mobile size
    const phoneW = 260.0;
    final phoneH = (screenH * 0.62).clamp(440.0, 560.0);
    const cornerR = 36.0;
    const bezelW = 10.0;
    const notchW = 72.0;
    const notchH = 22.0;
    const btnW = 3.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // URL bar / project label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                // Status dots
                _dot(0xFFFF5F57), _dot(0xFFFEBC2E), _dot(0xFF28C840),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppColors.textMuted,
                          size: 11,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.projectName.toLowerCase().replaceAll(' ', '-')}.app',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.accent,
                    ),
                  )
                else
                  const Icon(
                    Icons.refresh,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Phone frame
          Center(
            child: SizedBox(
              width: phoneW + bezelW * 2 + btnW,
              height: phoneH + bezelW * 2 + 20,
              child: Stack(
                children: [
                  // Power button (right side)
                  Positioned(
                    right: 0,
                    top: 100,
                    width: btnW,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Volume buttons (left side)
                  Positioned(
                    left: 0,
                    top: 80,
                    width: btnW,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 125,
                    width: btnW,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Outer body
                  Positioned(
                    left: btnW,
                    top: 0,
                    width: phoneW + bezelW * 2,
                    height: phoneH + bezelW * 2 + 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(cornerR),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.08),
                            blurRadius: 40,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF2A2A4A),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Notch bar
                          Container(
                            height: notchH + bezelW,
                            padding: EdgeInsets.only(top: bezelW),
                            child: Center(
                              child: Container(
                                width: notchW,
                                height: notchH - 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D0D1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2A2A4A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 32,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A4A),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Screen area
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: bezelW),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Stack(
                                  children: [
                                    WebViewWidget(controller: _ctrl),
                                    if (_loading)
                                      const ColoredBox(
                                        color: AppColors.background,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Home bar
                          Container(
                            height: bezelW + 20,
                            padding: const EdgeInsets.only(top: 4),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.textMuted.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
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
          ),

          const SizedBox(height: 20),
          const Text(
            'Tap & interact — this is a live app mockup',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _dot(int hex) => Container(
    width: 10,
    height: 10,
    margin: const EdgeInsets.only(right: 5),
    decoration: BoxDecoration(color: Color(hex), shape: BoxShape.circle),
  );
}
