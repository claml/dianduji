import 'package:flutter/foundation.dart';

import '../../../core/network/dictionary_enrichment_gateway.dart';
import '../domain/user_dictionary_repository.dart';

/// Orchestrates the user-dictionary enrichment loop: read candidates, send
/// them to the LLM gateway, apply the results, and report progress.
class DictionaryUpdateCenter extends ChangeNotifier {
  DictionaryUpdateCenter({required this.store, this.gateway});

  final UserDictionaryStore store;
  final DictionaryEnrichmentGateway? gateway;

  int _candidateCount = 0;
  var _busy = false;
  String? _error;
  int _lastConfirmed = 0;
  int _lastDropped = 0;
  int _lastEnriched = 0;

  int get candidateCount => _candidateCount;
  bool get busy => _busy;
  String? get error => _error;
  bool get gatewayConfigured => gateway != null;
  int get lastConfirmed => _lastConfirmed;
  int get lastDropped => _lastDropped;
  int get lastEnriched => _lastEnriched;

  Future<void> refresh() async {
    try {
      _candidateCount = await store.pendingCandidateCount();
    } on Object {
      // Refresh failure keeps the previous count.
    }
    notifyListeners();
  }

  /// Returns true when the enrichment completed; false when it was skipped
  /// (no gateway or no candidates). Errors are exposed via [error].
  Future<bool> runEnrichment() async {
    final gateway = this.gateway;
    if (gateway == null) {
      _error = '未配置整理网关（需设置在线翻译网关地址）';
      notifyListeners();
      return false;
    }
    final candidates = await store.pendingCandidates();
    if (candidates.isEmpty) return false;

    _busy = true;
    _error = null;
    _lastConfirmed = 0;
    _lastDropped = 0;
    _lastEnriched = 0;
    notifyListeners();
    try {
      final result = await gateway.enrich(
        [for (final candidate in candidates) candidate.surface],
      );
      await store.applyEnrichment(result.entries);
      _lastEnriched = result.entries.length;
      _lastConfirmed = result.entries.where((entry) => entry.isValid).length;
      _lastDropped = result.entries.where((entry) => !entry.isValid).length;
      _candidateCount = await store.pendingCandidateCount();
      return true;
    } on Object catch (error) {
      _error = error.toString();
      _candidateCount = await store.pendingCandidateCount();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
