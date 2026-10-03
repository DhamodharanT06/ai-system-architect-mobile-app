import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/blueprint.dart';
import 'review_service.dart';
import 'api_service.dart';

enum GenerationState { idle, generating, success, error }

class BlueprintProvider extends ChangeNotifier {
  final ApiService _api;

  BlueprintProvider(this._api);

  GenerationState _state = GenerationState.idle;
  Blueprint? _current;
  String? _error;
  List<Blueprint> _history = [];
  int _currentStep = 0; // 0-5 for progress indicator steps

  GenerationState get state => _state;
  Blueprint? get current => _current;
  String? get error => _error;
  List<Blueprint> get history => _history;
  int get currentStep => _currentStep;

  final _progressSteps = [
    'Searching research sources…',
    'Fetching & reading documents…',
    'Embedding & indexing knowledge…',
    'Running MMR retrieval…',
    'Generating blueprint with Groq…',
    'Assembling blueprint…',
  ];
  List<String> get progressSteps => _progressSteps;

  Future<void> init() async {
    final box = Hive.box<Blueprint>('blueprints');
    _history =
        box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<Blueprint?> generate(
    String problemStatement, {
    String? context,
  }) async {
    _state = GenerationState.generating;
    _error = null;
    _currentStep = 0;
    notifyListeners();

    // Simulate step progression (mirrors real backend phases)
    final stepDurations = [5500, 5000, 4500, 3000, 9000, 3000];
    _advanceSteps(stepDurations);

    try {
      final blueprint = await _api.generateBlueprint(
        problemStatement: problemStatement,
        context: context,
      );

      _current = blueprint;
      _state = GenerationState.success;
      _currentStep = _progressSteps.length;
      notifyListeners();

      // Request in-app review after successful generation (conditions checked inside)
      final box = Hive.box<Blueprint>('blueprints');
      final totalGenerations =
          box.length + 1; // +1 for the one we're about to add
      ReviewService.instance.onBlueprintGenerated(
        totalGenerations: totalGenerations,
      );

      // Persist to history
      await box.add(blueprint);
      _history =
          box.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();

      return blueprint;
    } on ApiException catch (e) {
      _error = e.message;
      _state = GenerationState.error;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _state = GenerationState.error;
      notifyListeners();
      return null;
    }
  }

  void _advanceSteps(List<int> durations) async {
    for (int i = 0; i < durations.length; i++) {
      await Future.delayed(Duration(milliseconds: durations[i]));
      if (_state == GenerationState.generating) {
        _currentStep = i + 1;
        notifyListeners();
      } else {
        break;
      }
    }
  }

  void setCurrentBlueprint(Blueprint b) {
    _current = b;
    notifyListeners();
  }

  void reset() {
    _state = GenerationState.idle;
    _error = null;
    _currentStep = 0;
    notifyListeners();
  }

  Future<void> renameHistory(
    int index,
    String newTitle,
    String newDescription,
  ) async {
    if (index < 0 || index >= _history.length) return;
    final box = Hive.box<Blueprint>('blueprints');
    final bp = _history[index];

    // Mutate fields
    bp.projectName = newTitle;
    if (newDescription.isNotEmpty) bp.description = newDescription;

    // Persist: find the key for this object in the box and put it back.
    // bp.save() requires the object to have been opened from the box directly;
    // using box.put(key, bp) is always safe regardless of how it was retrieved.
    final key = bp.key;
    if (key != null) {
      await box.put(key, bp);
    } else {
      // Fallback: find by position and overwrite
      final keys = box.keys.toList();
      final values = box.values.toList();
      final pos = values.indexWhere(
        (v) => v.createdAt == bp.createdAt && v.projectName == newTitle,
      );
      if (pos >= 0 && pos < keys.length) {
        await box.put(keys[pos], bp);
      }
    }

    _history =
        box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> deleteFromHistory(int index) async {
    final box = Hive.box<Blueprint>('blueprints');
    final key = box.keyAt(
      box.values.toList().indexWhere((b) => b == _history[index]),
    );
    if (key != null) await box.delete(key);
    _history =
        box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }
}
