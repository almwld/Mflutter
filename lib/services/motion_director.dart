import 'dart:math';

/// Visual scene categories. These are presentation hints, never Quranic
/// interpretations; scene metadata must be reviewed and supplied by the app.
enum TopicTemplate { cosmic, nature, human, numeric, narrative, general }

enum MotionTransition { fade, dissolve, pan, orbit, morph }

class QuranicScene {
  const QuranicScene({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.reference,
    required this.tags,
    this.importance = 1,
    this.template = TopicTemplate.general,
    this.baseDuration = 4,
  })  : assert(id != ''),
        assert(importance > 0),
        assert(baseDuration > 0);

  final String id;
  final String title;
  final String arabicText;
  final String reference;
  final List<String> tags;
  final double importance;
  final TopicTemplate template;
  final double baseDuration;

  int get wordCount => arabicText.trim().isEmpty
      ? 0
      : arabicText.trim().split(RegExp(r'\s+')).length;
}

/// Runtime context used to rank already-curated scenes. No location permission
/// or network access is required; callers may pass a local hour and preferences.
class MotionContext {
  const MotionContext({
    this.theme = '',
    this.hour,
    this.preferredTagWeights = const {},
    this.recentTags = const {},
    this.batteryFraction = 1,
    this.motionIntensity = 1,
    this.maxScenes = 5,
  })  : assert(batteryFraction >= 0 && batteryFraction <= 1),
        assert(motionIntensity >= 0 && motionIntensity <= 1),
        assert(maxScenes > 0);

  final String theme;
  final int? hour;
  final Map<String, double> preferredTagWeights;
  final Set<String> recentTags;
  final double batteryFraction;
  final double motionIntensity;
  final int maxScenes;

  bool get isNight => hour != null && (hour! >= 18 || hour! < 6);
  bool get isLowPower => batteryFraction <= 0.20;
}

class PlannedScene {
  const PlannedScene({
    required this.scene,
    required this.duration,
    required this.transition,
    required this.score,
  });

  final QuranicScene scene;
  final Duration duration;
  final MotionTransition transition;
  final double score;
}

/// A local, deterministic-by-input director. It selects from a vetted scene
/// catalog; it does not generate or reinterpret Quranic text.
class MotionDirector {
  MotionDirector({
    required List<QuranicScene> allScenes,
    Random? random,
  })  : allScenes = List.unmodifiable(allScenes),
        _random = random ?? Random();

  final List<QuranicScene> allScenes;
  final Random _random;
  final Set<String> _shownScenes = {};

  Set<String> get shownSceneIds => Set.unmodifiable(_shownScenes);

  void resetCycle() => _shownScenes.clear();

  PlannedScene? nextScene({MotionContext context = const MotionContext()}) {
    final candidates = allScenes
        .where((scene) => !_shownScenes.contains(scene.id))
        .toList(growable: false);
    if (candidates.isEmpty) return null;

    final ranked = candidates
        .map((scene) => (scene: scene, score: _score(scene, context)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Weighted draw among the best candidates preserves variety while
    // ensuring relevance and importance dominate pure randomness.
    final shortlist = ranked.take(min(5, ranked.length)).toList();
    final weights = shortlist.map((item) => max(0.05, item.score)).toList();
    final total = weights.fold<double>(0, (sum, value) => sum + value);
    var ticket = _random.nextDouble() * total;
    var selected = shortlist.last;
    for (var i = 0; i < shortlist.length; i++) {
      ticket -= weights[i];
      if (ticket <= 0) {
        selected = shortlist[i];
        break;
      }
    }

    _shownScenes.add(selected.scene.id);
    return PlannedScene(
      scene: selected.scene,
      duration: calculateDuration(selected.scene),
      transition: _transitionFor(selected.scene.template),
      score: selected.score,
    );
  }

  List<PlannedScene> generatePlaylist({
    MotionContext context = const MotionContext(),
    int? totalScenes,
  }) {
    final count = min(totalScenes ?? context.maxScenes, allScenes.length);
    final playlist = <PlannedScene>[];
    for (var i = 0; i < count; i++) {
      final next = nextScene(context: context);
      if (next == null) break;
      playlist.add(next);
    }
    return List.unmodifiable(playlist);
  }

  Duration calculateDuration(QuranicScene scene) {
    // Estimate reading time by words, not raw character count. Importance
    // adds a modest pause; hard bounds prevent excessively long scenes.
    final seconds = (scene.baseDuration +
            scene.wordCount * 0.38 * scene.importance.clamp(0.8, 1.8))
        .clamp(4.0, 18.0);
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// Lightweight visual quality profile for adaptive rendering.
  double particleBudget({MotionContext context = const MotionContext()}) {
    if (context.isLowPower) return 0.25;
    return (0.35 + context.motionIntensity * 0.65).clamp(0.35, 1.0);
  }

  double _score(QuranicScene scene, MotionContext context) {
    final normalizedTags = scene.tags.map((tag) => tag.toLowerCase()).toSet();
    var score = scene.importance * 2;

    final themeTerms = context.theme
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((term) => term.isNotEmpty)
        .toSet();
    score += normalizedTags.intersection(themeTerms).length * 3;

    for (final entry in context.preferredTagWeights.entries) {
      if (normalizedTags.contains(entry.key.toLowerCase())) {
        score += entry.value;
      }
    }

    if (context.isNight &&
        normalizedTags.intersection({'night', 'moon', 'stars', 'cosmic'}).isNotEmpty) {
      score += 2;
    } else if (context.hour != null &&
        !context.isNight &&
        normalizedTags.intersection({'day', 'sun', 'light', 'nature'}).isNotEmpty) {
      score += 1.5;
    }

    if (normalizedTags.intersection(context.recentTags).isNotEmpty) {
      score *= 0.65;
    }
    return max(0.05, score);
  }

  MotionTransition _transitionFor(TopicTemplate template) {
    switch (template) {
      case TopicTemplate.cosmic:
        return MotionTransition.orbit;
      case TopicTemplate.nature:
        return MotionTransition.pan;
      case TopicTemplate.numeric:
        return MotionTransition.morph;
      case TopicTemplate.narrative:
        return MotionTransition.dissolve;
      case TopicTemplate.human:
      case TopicTemplate.general:
        return MotionTransition.fade;
    }
  }
}
