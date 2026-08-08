import 'dart:collection';

import 'package:pdfrx/pdfrx.dart';

import '../../domain/pdf_page_geometry.dart';

abstract interface class PdfPageTextSource {
  int get pageNumber;
  Future<PdfPageText> loadStructuredText();
  Future<PdfPageRawText?> loadRawText();
}

class PdfPageTextStore {
  PdfPageTextStore({this.maxPages = 8}) : assert(maxPages > 0);

  final int maxPages;
  final LinkedHashMap<int, PdfPageGeometry> _pages = LinkedHashMap();
  final Map<int, Future<PdfPageGeometry?>> _inFlight = {};
  var _generation = 0;

  PdfPageGeometry? get(int pageNumber) {
    final page = _pages.remove(pageNumber);
    if (page != null) _pages[pageNumber] = page;
    return page;
  }

  Future<PdfPageGeometry?> load(PdfPageTextSource source) {
    final cached = get(source.pageNumber);
    if (cached != null) return Future.value(cached);

    final existing = _inFlight[source.pageNumber];
    if (existing != null) return existing;

    final generation = _generation;
    late final Future<PdfPageGeometry?> future;
    future = _load(source, generation).whenComplete(() {
      if (identical(_inFlight[source.pageNumber], future)) {
        _inFlight.remove(source.pageNumber);
      }
    });
    _inFlight[source.pageNumber] = future;
    return future;
  }

  void clear() {
    _generation++;
    _pages.clear();
    _inFlight.clear();
  }

  Future<PdfPageGeometry?> _load(
    PdfPageTextSource source,
    int generation,
  ) async {
    try {
      var geometry = PdfPageGeometry.fromStructured(
        await source.loadStructuredText(),
      );
      if (!_hasValidRun(geometry)) {
        final raw = await source.loadRawText();
        if (raw == null) return null;
        geometry = PdfPageGeometry.fromRaw(source.pageNumber, raw);
      }
      if (!_hasValidRun(geometry)) return null;
      if (generation == _generation) _put(geometry);
      return geometry;
    } catch (_) {
      return null;
    }
  }

  void _put(PdfPageGeometry geometry) {
    _pages.remove(geometry.pageNumber);
    _pages[geometry.pageNumber] = geometry;
    while (_pages.length > maxPages) {
      _pages.remove(_pages.keys.first);
    }
  }
}

bool _hasValidRun(PdfPageGeometry geometry) {
  for (final run in geometry.runs) {
    for (var index = 0; index < run.rects.length; index++) {
      if (geometry.rectAt(run.textStart + index) != null) return true;
    }
  }
  return false;
}
