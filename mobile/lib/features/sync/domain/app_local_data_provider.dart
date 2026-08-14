import '../../learning/data/learning_repository.dart';
import '../../settings/data/reading_settings.dart';
import '../../settings/data/settings_repository.dart';
import 'sync_engine.dart';

/// Version-1 sync payload:
/// {
///   "version": 1,
///   "vocabulary": [ {"lemma","definition","proficiency"} ... ],
///   "settings": { "theme","fontSize","lineHeight","onlineTranslationEnabled" }
/// }
class AppLocalDataProvider implements LocalDataProvider {
  AppLocalDataProvider({
    required LearningRepository learning,
    required SettingsRepository settings,
  })  :
        // ignore: prefer_initializing_formals — private field, public name.
        _learning = learning,
        // ignore: prefer_initializing_formals — private field, public name.
        _settings = settings;

  static const version = 1;

  final LearningRepository _learning;
  final SettingsRepository _settings;

  @override
  Future<({Map<String, Object?> data, int updatedAt})> collect() async {
    final vocabulary = await _learning
        .watchVocabulary(const VocabularyQuery())
        .first;
    final settings = await _settings.load();
    final newestLookup = vocabulary
        .map((item) => item.lastLookupAt.millisecondsSinceEpoch)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final updatedAt = _now().millisecondsSinceEpoch > newestLookup
        ? _now().millisecondsSinceEpoch
        : newestLookup;

    return (
      data: {
        'version': version,
        'vocabulary': [
          for (final item in vocabulary)
            {
              'lemma': item.lemma,
              'definition': item.definition,
              'proficiency': item.proficiency.name,
            },
        ],
        'settings': {
          'theme': settings.theme.name,
          'fontSize': settings.fontSize,
          'lineHeight': settings.lineHeight,
          'onlineTranslationEnabled': settings.onlineTranslationEnabled,
        },
      },
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> apply(Map<String, Object?> data, int updatedAt) async {
    if (data['version'] != version) return;

    final rawVocabulary = data['vocabulary'];
    if (rawVocabulary is List<Object?>) {
      // Rebuild the book from the remote snapshot: drop local entries that
      // are not present remotely, then upsert the remote ones.
      final remoteLemmas = <String>{};
      final entries = <({String lemma, String definition, String proficiency})>[];
      for (final raw in rawVocabulary) {
        if (raw is! Map<Object?, Object?>) continue;
        final lemma = raw['lemma'];
        final definition = raw['definition'];
        final proficiency = raw['proficiency'];
        if (lemma is! String || definition is! String || proficiency is! String) {
          continue;
        }
        remoteLemmas.add(lemma);
        entries.add((lemma: lemma, definition: definition, proficiency: proficiency));
      }

      final local = await _learning
          .watchVocabulary(const VocabularyQuery())
          .first;
      for (final item in local) {
        if (!remoteLemmas.contains(item.lemma)) {
          await _learning.deleteVocabulary(item.lemma);
        }
      }
      for (final entry in entries) {
        await _learning.addManualVocabulary(
          ManualVocabularyDraft(
            word: entry.lemma,
            definition: entry.definition,
            proficiency: _parseProficiency(entry.proficiency),
          ),
        );
      }
    }

    final rawSettings = data['settings'];
    if (rawSettings is Map<Object?, Object?>) {
      final theme = rawSettings['theme'];
      final fontSize = rawSettings['fontSize'];
      final lineHeight = rawSettings['lineHeight'];
      final online = rawSettings['onlineTranslationEnabled'];
      final current = await _settings.load();
      final merged = current.copyWith(
        theme: theme is String ? _parseTheme(theme) : current.theme,
        fontSize: fontSize is num
            ? fontSize.toDouble().clamp(12, 24)
            : current.fontSize,
        lineHeight: lineHeight is num
            ? lineHeight.toDouble().clamp(1.4, 2.0)
            : current.lineHeight,
        onlineTranslationEnabled: online is bool ? online : current.onlineTranslationEnabled,
      );
      await _settings.save(merged);
    }
  }

  DateTime _now() => DateTime.now();

  VocabularyProficiency _parseProficiency(String name) =>
      VocabularyProficiency.values.asNameMap()[name] ??
      VocabularyProficiency.unknown;

  ReaderTheme _parseTheme(String name) =>
      ReaderTheme.values.asNameMap()[name] ?? ReaderTheme.day;
}
