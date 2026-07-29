import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reading locator round trips independently of pixel position', () {
    const locator = ReadingLocator(
      documentId: 'doc-1',
      paragraphId: 'paragraph-8',
      sentenceId: 'sentence-21',
      localOffset: 4,
    );

    expect(ReadingLocator.decode(locator.encode()), locator);
    expect(locator.encode(), isNot(contains('scroll')));
  });

  test('coalesces scrolling updates and persists the latest locator', () {
    fakeAsync((async) {
      final store = _RecordingProgressStore();
      final controller = ReaderProgressController(
        store: store,
        saveDelay: const Duration(milliseconds: 500),
      );

      controller.update(_locator('sentence-1'), 0.1);
      async.elapse(const Duration(milliseconds: 300));
      controller.update(_locator('sentence-2'), 0.2);
      async.elapse(const Duration(milliseconds: 499));
      expect(store.saved, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(store.saved, [(_locator('sentence-2'), 0.2)]);
    });
  });

  test('force save on lifecycle pause writes immediately', () async {
    final store = _RecordingProgressStore();
    final controller = ReaderProgressController(
      store: store,
      saveDelay: const Duration(minutes: 1),
    );
    controller.update(_locator('sentence-9'), 0.9);

    await controller.forceSave();

    expect(store.saved, [(_locator('sentence-9'), 0.9)]);
  });
}

ReadingLocator _locator(String sentenceId) => ReadingLocator(
  documentId: 'doc-1',
  paragraphId: 'paragraph-1',
  sentenceId: sentenceId,
  localOffset: 0,
);

class _RecordingProgressStore implements ReadingProgressStore {
  final saved = <(ReadingLocator locator, double progress)>[];

  @override
  Future<void> save(ReadingLocator locator, double progress) async {
    saved.add((locator, progress));
  }
}
