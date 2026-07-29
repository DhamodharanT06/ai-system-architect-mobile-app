import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adService = context.watch<AdService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Information')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/app_icon_only_dark.png'),
            fit: BoxFit.fitWidth,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // const _SectionHeader(title: 'Usage Stats'),
            // const SizedBox(height: 12),
            // Row(
            //   children: [
                // Expanded(
                //   child: _StatCard(
                //     icon: Icons.generating_tokens_outlined,
                //     label: 'Blueprints\nGenerated',
                //     value: '${adService.generationCount}',
                //     color: AppColors.accent,
                //     alignment: Alignment.center,
                //   ),
                // ),
                // const SizedBox(width: 12),
                // Expanded(
                //   child: _StatCard(
                //     icon: Icons.play_circle_outline,
                //     label: 'Ads\nWatched',
                //     value: '${adService.generationCount ~/ 3}',
                //     color: AppColors.laneAI,
                //   ),
                // ),
            //   ],
            // ),
            const SizedBox(height: 28),
            const _SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.accent.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/app_icon.png'),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      // Container(
                      //   width: 44,
                      //   height: 44,
                      //   decoration: BoxDecoration(
                      //     gradient: const LinearGradient(
                      //       colors: [AppColors.accent, AppColors.laneAI],
                      //     ),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: const Icon(
                      //     Icons.architecture,
                      //     color: Colors.black,
                      //     size: 22,
                      //   ),
                      // ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ArchiMind',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'AI System Architect',
                            style: TextStyle(
                              color: AppColors.textSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Version 2.0.0',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '\n\tGenerate comprehensive project blueprints powered by AI. '
                    '\n\n'
                    '\tIncludes: \n\t- Architecture diagrams, \n\t- Tech stack recommendations, '
                    '\n\t- Workflow steps, \n\t- Runtime execution flows, \n\t- Interactive UI previews, '
                    'and \n\t- Curated learning references.',
                    style: TextStyle(
                      color: AppColors.textSub,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // _SectionHeader(title: 'How Ads Work'),
            // const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.surface,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: AppColors.border),
            //   ),
            //   child: const Column(
            //     children: [
            //       _AdInfoRow(
            //         icon: Icons.ondemand_video_outlined,
            //         color: AppColors.laneAI,
            //         title: 'Rewarded Ads',
            //         sub:
            //             'A short ad plays every 3rd generation. Watch to unlock your blueprint.',
            //       ),
            //       SizedBox(height: 12),
            //       _AdInfoRow(
            //         icon: Icons.view_stream_outlined,
            //         color: AppColors.accent,
            //         title: 'Banner Ads',
            //         sub:
            //             'Small banners placed unobtrusively at screen edges — never blocking content.',
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final Alignment alignment;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.alignment,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    alignment: alignment,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

// class _AdInfoRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title, sub;
//   const _AdInfoRow({
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.sub,
//   });
//   @override
//   Widget build(BuildContext context) => Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: color, size: 18),
//       ),
//       const SizedBox(width: 12),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: AppColors.text,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 3),
//             Text(
//               sub,
//               style: const TextStyle(
//                 color: AppColors.textMuted,
//                 fontSize: 12,
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// -----------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../services/ad_service.dart';
// import '../theme/app_theme.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   late TextEditingController _urlCtrl;
//   bool _checking = false;
//   bool? _healthy;
//
//   @override
//   void initState() {
//     super.initState();
//     final api = context.read<ApiService>();
//     _urlCtrl = TextEditingController(text: api.currentUrl);
//   }
//
//   @override
//   void dispose() {
//     _urlCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveUrl() async {
//     final api = context.read<ApiService>();
//     await api.setBaseUrl(_urlCtrl.text.trim());
//     setState(() {
//       _checking = true;
//       _healthy = null;
//     });
//     final ok = await api.checkHealth();
//     setState(() {
//       _checking = false;
//       _healthy = ok;
//     });
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             ok ? '✓ Connected successfully' : '✗ Could not connect',
//           ),
//           backgroundColor: ok ? AppColors.success : AppColors.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final adService = context.watch<AdService>();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // Backend URL section
//           _SectionHeader(title: 'Backend Configuration'),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _urlCtrl,
//             decoration: InputDecoration(
//               labelText: 'Backend URL',
//               hintText: 'https://your-backend.onrender.com',
//               prefixIcon: const Icon(
//                 Icons.link,
//                 color: AppColors.accent,
//                 size: 18,
//               ),
//               suffixIcon:
//                   _checking
//                       ? const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.accent,
//                           ),
//                         ),
//                       )
//                       : _healthy == null
//                       ? null
//                       : Icon(
//                         _healthy! ? Icons.check_circle : Icons.error,
//                         color: _healthy! ? AppColors.success : AppColors.error,
//                         size: 18,
//                       ),
//             ),
//             style: const TextStyle(color: AppColors.text),
//             keyboardType: TextInputType.url,
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _saveUrl,
//               child: const Text('Save & Test Connection'),
//             ),
//           ),
//
//           const SizedBox(height: 28),
//           _SectionHeader(title: 'Usage Stats'),
//           const SizedBox(height: 12),
//           _StatCard(
//             icon: Icons.generating_tokens_outlined,
//             label: 'Total Generations',
//             value: '${adService.generationCount}',
//             color: AppColors.accent,
//           ),
//           const SizedBox(height: 10),
//           _StatCard(
//             icon: Icons.play_circle_outline,
//             label: 'Ads Watched',
//             value: '${adService.generationCount ~/ 3}',
//             color: AppColors.laneAI,
//           ),
//
//           const SizedBox(height: 28),
//           _SectionHeader(title: 'About'),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'AI System Architect',
//                   style: TextStyle(
//                     color: AppColors.text,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Version 1.0.0',
//                   style: TextStyle(color: AppColors.textMuted, fontSize: 12),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Generate comprehensive project blueprints with AI. '
//                   'Powered by LangChain + Groq with optional RAG pipeline.',
//                   style: TextStyle(
//                     color: AppColors.textSub,
//                     fontSize: 12,
//                     height: 1.6,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   const _SectionHeader({required this.title});
//   @override
//   Widget build(BuildContext context) => Text(
//     title,
//     style: const TextStyle(
//       color: AppColors.textMuted,
//       fontSize: 11,
//       fontWeight: FontWeight.w700,
//       letterSpacing: 0.8,
//     ),
//   );
// }
//
// class _StatCard extends StatelessWidget {
//   final IconData icon;
//   final String label, value;
//   final Color color;
//   const _StatCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: AppColors.surface,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: AppColors.border),
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(color: AppColors.textSub, fontSize: 13),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ],
//     ),
//   );
// }
