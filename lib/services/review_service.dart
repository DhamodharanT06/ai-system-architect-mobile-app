import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ReviewService {
  ReviewService._();
  static final instance = ReviewService._();

  // ── Timing constants ──────────────────────────────────────────────────────
  static const _minGenerations = 3; // must have generated ≥3 blueprints
  static const _minDaysSinceInstall = 2; // wait 2 days after first launch
  static const _minDaysBetweenPrompts = 30; // don't re-ask within 30 days
  static const _maxPromptCount = 3; // never ask more than 3 times total

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const _keyFirstLaunch = 'review_first_launch_ms';
  static const _keyLastPrompt = 'review_last_prompt_ms';
  static const _keyPromptCount = 'review_prompt_count';

  final _inAppReview = InAppReview.instance;

  /// Call this on every app launch to record first-launch timestamp.
  Future<void> recordLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyFirstLaunch) == null) {
      await prefs.setInt(
        _keyFirstLaunch,
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('ReviewService: first launch recorded');
    }
  }

  /// Call this after a successful blueprint generation.
  /// Evaluates all conditions and requests the review flow if appropriate.
  Future<void> onBlueprintGenerated({required int totalGenerations}) async {
    // Quick exit — not enough generations yet
    if (totalGenerations < _minGenerations) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final firstLaunch = prefs.getInt(_keyFirstLaunch) ?? now;
    final lastPrompt = prefs.getInt(_keyLastPrompt) ?? 0;
    final promptCount = prefs.getInt(_keyPromptCount) ?? 0;

    final daysSinceInstall = _daysBetween(firstLaunch, now);
    final daysSinceLastPrompt = _daysBetween(lastPrompt, now);

    debugPrint(
      'ReviewService: gens=$totalGenerations, '
      'daysSinceInstall=$daysSinceInstall, '
      'daysSinceLastPrompt=$daysSinceLastPrompt, '
      'promptCount=$promptCount',
    );

    // Check all conditions
    if (promptCount >= _maxPromptCount) return;
    if (daysSinceInstall < _minDaysSinceInstall) return;
    if (lastPrompt != 0 && daysSinceLastPrompt < _minDaysBetweenPrompts) return;

    await _requestReview(prefs, now);
  }

  Future<void> _requestReview(SharedPreferences prefs, int now) async {
    try {
      final available = await _inAppReview.isAvailable();
      if (!available) {
        debugPrint('ReviewService: in-app review not available on this device');
        return;
      }

      debugPrint('ReviewService: requesting in-app review');
      await _inAppReview.requestReview();

      // Record that we showed the prompt (regardless of whether Google
      // actually displayed the dialog — we can't tell either way)
      await prefs.setInt(_keyLastPrompt, now);
      await prefs.setInt(
        _keyPromptCount,
        (prefs.getInt(_keyPromptCount) ?? 0) + 1,
      );
    } catch (e) {
      // Never crash the app over a review prompt failure
      debugPrint('ReviewService: error requesting review — $e');
    }
  }

  /// Open the Play Store listing directly (for a manual "Rate Us" button).
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(appStoreId: '');
    } catch (e) {
      debugPrint('ReviewService: could not open store listing — $e');
    }
  }

  int _daysBetween(int fromMs, int toMs) {
    final from = DateTime.fromMillisecondsSinceEpoch(fromMs);
    final to = DateTime.fromMillisecondsSinceEpoch(toMs);
    return to.difference(from).inDays;
  }
}
