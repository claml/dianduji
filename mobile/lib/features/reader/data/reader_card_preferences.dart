import 'dart:convert';

import '../../../core/database/app_database.dart';

enum ReaderCardMode { sidePane, floating }

class ReaderCardPreferences {
  factory ReaderCardPreferences({
    ReaderCardMode mode = ReaderCardMode.sidePane,
    double relativeX = 0.72,
    double relativeY = 0.12,
  }) {
    return ReaderCardPreferences._(
      mode: mode,
      relativeX: relativeX.clamp(0, 1).toDouble(),
      relativeY: relativeY.clamp(0, 1).toDouble(),
    );
  }

  const ReaderCardPreferences._({
    required this.mode,
    required this.relativeX,
    required this.relativeY,
  });

  static const defaults = ReaderCardPreferences._(
    mode: ReaderCardMode.sidePane,
    relativeX: 0.72,
    relativeY: 0.12,
  );

  final ReaderCardMode mode;
  final double relativeX;
  final double relativeY;

  ReaderCardPreferences copyWith({
    ReaderCardMode? mode,
    double? relativeX,
    double? relativeY,
  }) {
    return ReaderCardPreferences(
      mode: mode ?? this.mode,
      relativeX: relativeX ?? this.relativeX,
      relativeY: relativeY ?? this.relativeY,
    );
  }

  Map<String, Object> toJson() => {
    'mode': mode.name,
    'relativeX': relativeX,
    'relativeY': relativeY,
  };

  factory ReaderCardPreferences.fromJson(Map<String, Object?> json) {
    final modeName = json['mode'];
    final relativeX = json['relativeX'];
    final relativeY = json['relativeY'];
    if (modeName is! String || relativeX is! num || relativeY is! num) {
      throw const FormatException('Reader card preferences are invalid.');
    }
    final mode = ReaderCardMode.values
        .where((candidate) => candidate.name == modeName)
        .firstOrNull;
    if (mode == null) throw const FormatException('Unknown reader card mode.');
    return ReaderCardPreferences(
      mode: mode,
      relativeX: relativeX.toDouble(),
      relativeY: relativeY.toDouble(),
    );
  }

  static ReaderCardPreferences tryFromJson(Map<String, Object?> json) {
    try {
      return ReaderCardPreferences.fromJson(json);
    } on Object {
      return defaults;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderCardPreferences &&
        other.mode == mode &&
        other.relativeX == relativeX &&
        other.relativeY == relativeY;
  }

  @override
  int get hashCode => Object.hash(mode, relativeX, relativeY);
}

class ReaderCardPreferencesRepository {
  const ReaderCardPreferencesRepository(this._dao);

  static const _key = 'reader-card-preferences-v1';
  final SettingsDao _dao;

  Future<ReaderCardPreferences> load() async {
    final encoded = await _dao.getValue(_key);
    if (encoded == null) return ReaderCardPreferences.defaults;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return ReaderCardPreferences.defaults;
      return ReaderCardPreferences.tryFromJson(
        Map<String, Object?>.from(decoded),
      );
    } on Object {
      return ReaderCardPreferences.defaults;
    }
  }

  Future<void> save(ReaderCardPreferences preferences) {
    return _dao.setValue(_key, jsonEncode(preferences.toJson()));
  }
}
