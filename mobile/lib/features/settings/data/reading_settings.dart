enum ReaderTheme { day, night, eyeCare }

class ReadingSettings {
  factory ReadingSettings({
    ReaderTheme theme = ReaderTheme.day,
    double fontSize = 16,
    double lineHeight = 1.6,
    bool autoSaveVocabulary = true,
    bool onlineTranslationEnabled = false,
    bool onlineTranslationConsented = false,
  }) {
    if (fontSize < 12 || fontSize > 24) {
      throw ArgumentError.value(
        fontSize,
        'fontSize',
        'must be between 12 and 24',
      );
    }
    if (lineHeight < 1.4 || lineHeight > 2) {
      throw ArgumentError.value(
        lineHeight,
        'lineHeight',
        'must be between 1.4 and 2.0',
      );
    }
    return ReadingSettings._(
      theme: theme,
      fontSize: fontSize,
      lineHeight: lineHeight,
      autoSaveVocabulary: autoSaveVocabulary,
      onlineTranslationEnabled: onlineTranslationEnabled,
      onlineTranslationConsented: onlineTranslationConsented,
    );
  }

  const ReadingSettings._({
    required this.theme,
    required this.fontSize,
    required this.lineHeight,
    required this.autoSaveVocabulary,
    required this.onlineTranslationEnabled,
    required this.onlineTranslationConsented,
  });

  final ReaderTheme theme;
  final double fontSize;
  final double lineHeight;
  final bool autoSaveVocabulary;

  /// Master switch for online translation fallback. Off by default.
  final bool onlineTranslationEnabled;

  /// Whether the user acknowledged the minimal-disclosure consent. Without
  /// consent, [onlineTranslationEnabled] alone does not allow network calls.
  final bool onlineTranslationConsented;

  ReadingSettings copyWith({
    ReaderTheme? theme,
    double? fontSize,
    double? lineHeight,
    bool? autoSaveVocabulary,
    bool? onlineTranslationEnabled,
    bool? onlineTranslationConsented,
  }) {
    return ReadingSettings._(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      autoSaveVocabulary: autoSaveVocabulary ?? this.autoSaveVocabulary,
      onlineTranslationEnabled:
          onlineTranslationEnabled ?? this.onlineTranslationEnabled,
      onlineTranslationConsented:
          onlineTranslationConsented ?? this.onlineTranslationConsented,
    );
  }

  Map<String, Object> toJson() => {
    'theme': theme.name,
    'fontSize': fontSize,
    'lineHeight': lineHeight,
    'autoSaveVocabulary': autoSaveVocabulary,
    'onlineTranslationEnabled': onlineTranslationEnabled,
    'onlineTranslationConsented': onlineTranslationConsented,
  };

  factory ReadingSettings.fromJson(Map<String, Object?> json) {
    final themeName = json['theme'];
    final fontSize = json['fontSize'];
    final lineHeight = json['lineHeight'];
    final autoSave = json['autoSaveVocabulary'];
    if (themeName is! String ||
        fontSize is! num ||
        lineHeight is! num ||
        autoSave is! bool) {
      throw const FormatException('Reading settings have invalid fields.');
    }
    final theme = ReaderTheme.values
        .where((candidate) => candidate.name == themeName)
        .firstOrNull;
    if (theme == null) throw const FormatException('Unknown reader theme.');
    return ReadingSettings(
      theme: theme,
      fontSize: fontSize.toDouble(),
      lineHeight: lineHeight.toDouble(),
      autoSaveVocabulary: autoSave,
      onlineTranslationEnabled:
          json['onlineTranslationEnabled'] as bool? ?? false,
      onlineTranslationConsented:
          json['onlineTranslationConsented'] as bool? ?? false,
    );
  }

  static ReadingSettings tryFromJson(Map<String, Object?> json) {
    try {
      return ReadingSettings.fromJson(json);
    } on Object {
      return ReadingSettings();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingSettings &&
      other.theme == theme &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight &&
      other.autoSaveVocabulary == autoSaveVocabulary &&
      other.onlineTranslationEnabled == onlineTranslationEnabled &&
      other.onlineTranslationConsented == onlineTranslationConsented;

  @override
  int get hashCode => Object.hash(
    theme,
    fontSize,
    lineHeight,
    autoSaveVocabulary,
    onlineTranslationEnabled,
    onlineTranslationConsented,
  );
}
