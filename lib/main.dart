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
import 'services/review_service.dart';
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

  // Record first launch timestamp for in-app review timing
  await ReviewService.instance.recordLaunch();

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

    // Check for updates after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    try {
      // Google Play Store only
      final newVersion = NewVersionPlus(
        androidId: 'app.dynamicdragon.ai_system_architecture',
      );

      final status = await newVersion.getVersionStatus();

      if (status == null) return;

      // Only show dialog when a newer Play Store version exists
      if (status.canUpdate && mounted) {
        _showUpdateDialog(status);
      }
    } catch (e) {
      // Ignore Play Store/network errors
      debugPrint('Play Store version check failed: $e');
    }
  }

  void _showUpdateDialog(VersionStatus status) {
    final ctx = navigatorKey.currentContext ?? context;

    showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => _UpdateDialog(status: status),
    );
  }

  // Global navigator key
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
// Google Play Store update dialog
// ─────────────────────────────────────────────────────────────────────────────

class _UpdateDialog extends StatelessWidget {
  final VersionStatus status;

  const _UpdateDialog({required this.status});

  // Your Google Play Store application ID
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=app.dynamicdragon.ai_system_architecture';

  Future<void> _openPlayStore(BuildContext context) async {
    final uri = Uri.parse(_playStoreUrl);

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open Google Play Store')),
        );
      }
    } catch (e) {
      debugPrint('Could not open Google Play Store: $e');
    }
  }

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
            // Top accent bar
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
                              'A new version is ready on Google Play',
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

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openPlayStore(context);
                      },
                      icon: const Icon(Icons.shop_rounded, size: 17),
                      label: const Text('Update from Google Play'),
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

                  // Later button
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
  final String label;
  final String version;
  final Color color;

  const _VersionBadge({
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
}
