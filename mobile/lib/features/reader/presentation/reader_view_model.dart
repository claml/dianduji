import 'dart:async';

import '../domain/reading_locator.dart';

abstract interface class ReadingProgressStore {
  Future<void> save(ReadingLocator locator, double progress);
}

class ReaderProgressController {
  ReaderProgressController({
    required this.store,
    this.saveDelay = const Duration(milliseconds: 750),
  });

  final ReadingProgressStore store;
  final Duration saveDelay;

  Timer? _timer;
  (ReadingLocator locator, double progress)? _pending;

  void update(ReadingLocator locator, double progress) {
    _pending = (locator, progress.clamp(0, 1));
    _timer?.cancel();
    _timer = Timer(saveDelay, () => unawaited(_persistPending()));
  }

  Future<void> forceSave() async {
    _timer?.cancel();
    _timer = null;
    await _persistPending();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _persistPending() async {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    await store.save(pending.$1, pending.$2);
  }
}
