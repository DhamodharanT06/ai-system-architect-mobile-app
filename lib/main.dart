import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/blueprint.dart';
import 'services/ad_service.dart';
import 'services/api_service.dart';
import 'services/blueprint_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BlueprintAdapter());
  Hive.registerAdapter(ArchitectureComponentAdapter());
  Hive.registerAdapter(TechStackItemAdapter());
  Hive.registerAdapter(WorkflowStepAdapter());
  Hive.registerAdapter(PrerequisiteItemAdapter());
  Hive.registerAdapter(SolutionApproachAdapter());
  Hive.registerAdapter(RealWorldExampleAdapter());
  Hive.registerAdapter(LearningReferenceAdapter());
  Hive.registerAdapter(RuntimeFlowStepAdapter());
  await Hive.openBox<Blueprint>('blueprints');

  // AdMob
  final adService = AdService();
  await adService.init();

  final apiService = ApiService();
  await apiService.initialise();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: adService),
        Provider.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => BlueprintProvider(apiService)..init(),
        ),
      ],
      child: const AIArchitectApp(),
    ),
  );
}

class AIArchitectApp extends StatefulWidget {
  const AIArchitectApp({super.key});
  @override
  State<AIArchitectApp> createState() => _AIArchitectAppState();
}

class _AIArchitectAppState extends State<AIArchitectApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates after first frame so the app is fully rendered first
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    try {
      final newVersion = NewVersionPlus(
        // Must match your Play Store package name exactly
        androidId: 'app.dynamicdragon.ai_system_architecture',
      );

      final status = await newVersion.getVersionStatus();
      if (status == null) return;

      // Only show if there is actually a newer version available
      if (status.canUpdate && mounted) {
        _showUpdateDialog(status);
      }
    } catch (e) {
      // Network errors, Play Store unavailable, etc. — silently ignore
      debugPrint('Version check failed: $e');
    }
  }

  void _showUpdateDialog(VersionStatus status) {
    final ctx = navigatorKey.currentContext ?? context;
    showDialog<void>(
      context: ctx,
      barrierDismissible: true, // tap outside = Later
      builder: (_) => _UpdateDialog(status: status),
    );
  }

  // Global navigator key so the dialog can be shown from initState
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI System Architect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Non-blocking update dialog
// ─────────────────────────────────────────────────────────────────────────────
class _UpdateDialog extends StatelessWidget {
  final VersionStatus status;
  const _UpdateDialog({required this.status});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top accent bar ──────────────────────────────────────────
            Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.laneAI],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + title
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.laneAI],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.system_update_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Available',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'A new version is ready on Play Store',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Version row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _VersionBadge(
                            label: 'Current',
                            version: status.localVersion,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: _VersionBadge(
                            label: 'Latest',
                            version: status.storeVersion ?? '—',
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);

                        final uri = Uri.parse(
                          'https://play.google.com/store/apps/details?id=app.dynamicdragon.ai_system_architecture',
                        );

                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Update Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String label, version;
  final Color color;
  const _VersionBadge({
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'v$version',
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
