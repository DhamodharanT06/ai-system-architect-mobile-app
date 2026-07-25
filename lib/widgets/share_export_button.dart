import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/blueprint.dart';
import '../theme/app_theme.dart';

/// Global registry for capturable section keys.
/// Sections call [ShareSectionRegistry.register] when they build,
/// and [ShareSectionRegistry.unregister] when they dispose.
class ShareSectionRegistry {
  ShareSectionRegistry._();
  static final instance = ShareSectionRegistry._();

  final _keys = <String, GlobalKey>{};

  void register(String name, GlobalKey key) {
    _keys[name] = key;
  }

  void unregister(String name) {
    _keys.remove(name);
  }

  Map<String, GlobalKey> get all => Map.unmodifiable(_keys);
}

/// Wrap a widget to make it capturable by the share button.
/// The RepaintBoundary key is registered automatically on build
/// and unregistered on dispose.
class ShareableSection extends StatefulWidget {
  final String sectionName;
  final Widget child;
  const ShareableSection({
    super.key,
    required this.sectionName,
    required this.child,
  });
  @override
  State<ShareableSection> createState() => _ShareableSectionState();
}

class _ShareableSectionState extends State<ShareableSection> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShareSectionRegistry.instance.register(widget.sectionName, _key);
  }

  @override
  void dispose() {
    ShareSectionRegistry.instance.unregister(widget.sectionName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: _key, child: widget.child);
}

// ─────────────────────────────────────────────────────────────────────────────

class ShareExportButton extends StatefulWidget {
  final Blueprint blueprint;

  /// Optional extra keys passed directly by the parent screen for sections
  /// that are always mounted (e.g. the overview hero card).
  final Map<String, GlobalKey> extraKeys;

  const ShareExportButton({
    super.key,
    required this.blueprint,
    this.extraKeys = const {},
  });

  @override
  State<ShareExportButton> createState() => _ShareExportButtonState();
}

class _ShareExportButtonState extends State<ShareExportButton> {
  bool _loading = false;

  Future<Uint8List?> _capture(GlobalKey key) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 80),
      ); // let frame settle
      final obj = key.currentContext?.findRenderObject();
      if (obj == null || obj is! RenderRepaintBoundary) return null;
      if (obj.debugNeedsPaint) return null;
      final image = await obj.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error for $key: $e');
      return null;
    }
  }

  String _slug(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  Future<void> _share() async {
    setState(() => _loading = true);
    try {
      final dir = await getTemporaryDirectory();
      final projectSlug = _slug(widget.blueprint.projectName);
      final encoder = ZipFileEncoder();
      final zipPath = '${dir.path}/$projectSlug-blueprint.zip';
      encoder.create(zipPath);

      // Merge registry keys + extra keys
      final allKeys = {
        ...ShareSectionRegistry.instance.all,
        ...widget.extraKeys,
      };

      int captured = 0;
      for (final entry in allKeys.entries) {
        final bytes = await _capture(entry.value);
        if (bytes != null && bytes.isNotEmpty) {
          final file = File('${dir.path}/${_slug(entry.key)}.png');
          await file.writeAsBytes(bytes);
          encoder.addFile(file);
          captured++;
        }
      }

      encoder.close();

      if (!mounted) return;

      if (captured == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Open each tab once so sections are rendered, then share.',
              style: TextStyle(color: AppColors.text),
            ),
            backgroundColor: AppColors.surfaceAlt,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: '${widget.blueprint.projectName} — Blueprint',
        text: 'AI-generated system blueprint ($captured sections captured)',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    icon:
        _loading
            ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            )
            : const Icon(Icons.ios_share_outlined, color: AppColors.accent),
    tooltip: 'Share section images',
    onPressed: _loading ? null : _share,
  );
}
