import '../../dictionary/domain/user_dictionary_repository.dart';
import '../../learning/data/learning_repository.dart';
import '../../phrases/domain/phrase_type.dart';
import '../../settings/data/reading_settings.dart';
import '../../settings/data/settings_repository.dart';
import 'sync_engine.dart';

/// Version-1 sync payload (mobile side):
/// {
///   "version": 1,
///   "vocabulary": [ {"lemma","definition","proficiency"} ... ],
///   "phrases": [ {"surface","meaning","type"} ... ],
///   "customDefinitions": [ {"surface","phonetic","partOfSpeech",
///                           "definitionEnglish","definitionChinese"} ... ],
///   "settings": { "theme","fontSize","lineHeight","onlineTranslationEnabled" }
/// }
///
/// Field names intentionally match the web edition so one gateway serves
/// both clients; each side applies the fields it understands.
class AppLocalDataProvider implements LocalDataProvider {
  AppLocalDataProvider({
    required LearningRepository learning,
    required SettingsRepository settings,
    required UserDictionaryStore userDictionary,
  })  :
        // ignore: prefer_initializing_formals — private field, public name.
        _learning = learning,
        // ignore: prefer_initializing_formals — private field, public name.
        _settings = settings,
        // ignore: prefer_initializing_formals — private field, public name.
        _userDictionary = userDictionary;

  static const version = 1;

  final LearningRepository _learning;
  final SettingsRepository _settings;
  final UserDictionaryStore _userDictionary;

  @override
  Future<({Map<String, Object?> data, int updatedAt})> collect() async {
    final vocabulary = await _learning
        .watchVocabulary(const VocabularyQuery())
        .first;
    final phrases = await _learning
        .watchSavedPhrases(const SavedPhraseQuery())
        .first;
    final manualEntries = await _userDictionary.listManualEntries();
    final pendingCandidates = await _userDictionary.pendingCandidates();
    final settings = await _settings.load();
    final newestLookup = vocabulary
        .map((item) => item.lastLookupAt.millisecondsSinceEpoch)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final newestPhrase = phrases
        .map((item) => item.createdAt.millisecondsSinceEpoch)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final now = _now().millisecondsSinceEpoch;
    final updatedAt = [now, newestLookup, newestPhrase].reduce(
      (a, b) => a > b ? a : b,
    );

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
        'phrases': [
          for (final item in phrases)
            {
              'surface': item.surface,
              'meaning': item.meaning,
              'type': item.type.storageValue,
            },
        ],
        'customDefinitions': [
          for (final entry in manualEntries)
            {
              'surface': entry.surface,
              'phonetic': entry.phonetic,
              'partOfSpeech': entry.partOfSpeech,
              'definitionEnglish': entry.definitionEnglish,
              'definitionChinese': entry.definitionChinese,
            },
        ],
        // Vocabulary candidates go to the cloud pool for web-admin review.
        'candidates': [
          for (final candidate in pendingCandidates) candidate.surface,
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

    final rawPhrases = data['phrases'];
    if (rawPhrases is List<Object?>) {
      // Rebuild the phrase book from the remote snapshot the same way.
      final remoteKeys = <String>{};
      final drafts = <SavedPhraseDraft>[];
      for (final raw in rawPhrases) {
        if (raw is! Map<Object?, Object?>) continue;
        final surface = raw['surface'];
        final meaning = raw['meaning'];
        final type = raw['type'];
        if (surface is! String || meaning is! String || type is! String) {
          continue;
        }
        final key = _phraseKey(surface);
        remoteKeys.add(key);
        try {
          drafts.add(
            SavedPhraseDraft(
              key: key,
              surface: surface,
              type: PhraseTypeCodec.fromStorage(type),
              meaning: meaning,
              contextSentence: '',
              context: const LearningContext(),
            ),
          );
        } on FormatException {
          continue;
        }
      }

      final local = await _learning
          .watchSavedPhrases(const SavedPhraseQuery())
          .first;
      for (final item in local) {
        if (!remoteKeys.contains(item.phraseKey)) {
          await _learning.deleteSavedPhrase(item.phraseKey);
        }
      }
      for (final draft in drafts) {
        await _learning.savePhrase(draft);
      }
    }

    final rawCustom = data['customDefinitions'];
    if (rawCustom is List<Object?>) {
      // Rebuild user-written definitions from the remote snapshot.
      final remoteSurfaces = <String>{};
      final entries = <ManualDictionaryEntry>[];
      for (final raw in rawCustom) {
        if (raw is! Map<Object?, Object?>) continue;
        final surface = raw['surface'];
        final phonetic = raw['phonetic'];
        final partOfSpeech = raw['partOfSpeech'];
        final definitionEnglish = raw['definitionEnglish'];
        final definitionChinese = raw['definitionChinese'];
        if (surface is! String ||
            phonetic is! String ||
            partOfSpeech is! String ||
            definitionEnglish is! String ||
            definitionChinese is! String) {
          continue;
        }
        final normalized = normalizeUserLemma(surface);
        if (normalized.isEmpty) continue;
        remoteSurfaces.add(normalized);
        entries.add(
          ManualDictionaryEntry(
            surface: surface,
            phonetic: phonetic,
            partOfSpeech: partOfSpeech,
            definitionEnglish: definitionEnglish,
            definitionChinese: definitionChinese,
          ),
        );
      }

      final local = await _userDictionary.listManualEntries();
      for (final entry in local) {
        if (!remoteSurfaces.contains(normalizeUserLemma(entry.surface))) {
          await _userDictionary.deleteManualEntry(entry.surface);
        }
      }
      for (final entry in entries) {
        await _userDictionary.saveManualEntry(entry);
      }
    }

    // Admin-confirmed candidates from the web console fold into the local
    // user dictionary (they take priority in the lookup chain).
    final rawConfirmed = data['confirmedCandidates'];
    if (rawConfirmed is List<Object?>) {
      for (final raw in rawConfirmed) {
        if (raw is! Map<Object?, Object?>) continue;
        final surface = raw['surface'];
        final phonetic = raw['phonetic'];
        final partOfSpeech = raw['partOfSpeech'];
        final definitionEnglish = raw['definitionEnglish'];
        final definitionChinese = raw['definitionChinese'];
        if (surface is! String ||
            phonetic is! String ||
            partOfSpeech is! String ||
            definitionEnglish is! String ||
            definitionChinese is! String) {
          continue;
        }
        await _userDictionary.saveManualEntry(
          ManualDictionaryEntry(
            surface: surface,
            phonetic: phonetic,
            partOfSpeech: partOfSpeech,
            definitionEnglish: definitionEnglish,
            definitionChinese: definitionChinese,
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

  /// Derives a stable phrase key from its surface ("look up" -> "look-up"),
  /// matching the recognizer's key convention for phrase book upserts.
  String _phraseKey(String surface) =>
      surface.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  VocabularyProficiency _parseProficiency(String name) =>
      VocabularyProficiency.values.asNameMap()[name] ??
      VocabularyProficiency.unknown;

  ReaderTheme _parseTheme(String name) =>
      ReaderTheme.values.asNameMap()[name] ?? ReaderTheme.day;
}
