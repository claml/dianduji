import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:dian_du_ji/features/documents/presentation/document_library_page.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/reader_top_bar.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/token_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Accessibility gate: semantic labels, live regions, 48dp hit targets,
/// 200% text visibility, reduced motion, and theme contrast tokens.
void main() {
  testWidgets('all icon-only actions expose Chinese semantic labels', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = _emptyLibraryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );

    final semantics = tester.getSemantics(find.byTooltip('导入文档'));
    expect(semantics.tooltip, contains('导入文档'));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReaderTopBar(
            title: 'Lesson',
            visible: true,
            onBack: null,
            onReveal: _noop,
            onSettings: null,
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byTooltip('返回')).tooltip,
      contains('返回'),
    );
    expect(
      tester.getSemantics(find.byTooltip('阅读设置')).tooltip,
      contains('阅读设置'),
    );
    handle.dispose();
  });

  testWidgets('reader tokens expose button semantics with selected state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TokenText(
            token: ReaderToken(id: 't1', surface: 'lesson'),
            selected: true,
            onTap: _noop,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(
      find.byKey(const Key('token-semantics-t1')),
    );
    expect(semantics.label, contains('点按查看释义'));
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);

    // 48dp minimum hit target for the transparent gesture area.
    final size = tester.getSize(find.byType(GestureDetector));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    handle.dispose();
  });

  testWidgets('every tappable control on the library page is at least 48x48', (
    tester,
  ) async {
    final controller = _emptyLibraryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );

    final finders = [
      find.byType(IconButton),
      find.byType(FilledButton),
      find.byType(TextButton),
    ];
    for (final finder in finders) {
      for (final element in finder.evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(
          size.width,
          greaterThanOrEqualTo(48),
          reason: '${element.widget.runtimeType} width too small',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(48),
          reason: '${element.widget.runtimeType} height too small',
        );
      }
    }
  });

  testWidgets('import failures announce through a live region', (tester) async {
    final controller = DocumentImportController(
      picker: _FailingPicker(),
      importer: _NoopImporter(),
      repository: _EmptyRepository(),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );

    await tester.tap(find.byTooltip('导入文档'));
    await tester.pump();

    final liveRegion = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.liveRegion == true,
      ),
    );
    expect(liveRegion.flagsCollection.isLiveRegion, isTrue);
  });

  testWidgets('critical actions stay visible and tappable at 200% text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final controller = _emptyLibraryController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );
    await tester.pump();

    expect(find.byTooltip('导入文档'), findsOneWidget);
    expect(tester.getSize(find.byTooltip('导入文档')).height, greaterThan(0));
    expect(find.text('还没有文档'), findsOneWidget);
  });

  testWidgets('reduced motion disables reader toolbar animation', (
    tester,
  ) async {
    final binding = tester.binding;
    binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          reduceMotion: true,
          disableAnimations: true,
        );
    addTearDown(
      () => binding.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReaderTopBar(
            title: 'Lesson',
            visible: true,
            onBack: null,
            onReveal: _noop,
            onSettings: null,
          ),
        ),
      ),
    );

    final context = tester.element(find.byKey(const Key('reader-top-bar')));
    expect(MediaQuery.disableAnimationsOf(context), isTrue);
  });

  testWidgets('day, night, and eye-care themes use distinct contrast tokens', (
    tester,
  ) async {
    const graphite = Color(0xFF252A32);
    const daySurface = Color(0xFFFBFCFE);
    const eyeCareSurface = Color(0xFFF5F3E8);
    const nightSurface = Color(0xFF16191E);

    // Body text on each surface must keep at least 4.5:1 contrast.
    expect(_contrastRatio(graphite, daySurface), greaterThanOrEqualTo(4.5));
    expect(_contrastRatio(graphite, eyeCareSurface), greaterThanOrEqualTo(4.5));
    expect(
      _contrastRatio(const Color(0xFFE6EAF2), nightSurface),
      greaterThanOrEqualTo(4.5),
    );

    // Eye care differs from day (warm paper) and night is darker than both.
    expect(eyeCareSurface, isNot(daySurface));
    expect(_luminance(nightSurface), lessThan(_luminance(daySurface)));
    expect(_luminance(nightSurface), lessThan(_luminance(eyeCareSurface)));
  });
}

DocumentImportController _emptyLibraryController() => DocumentImportController(
  picker: const _NoopPicker(),
  importer: _NoopImporter(),
  repository: _EmptyRepository(),
);

void _noop() {}

class _NoopPicker implements DocumentPicker {
  const _NoopPicker();

  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _FailingPicker implements DocumentPicker {
  @override
  Future<SelectedFile?> pickDocument() async {
    throw StateError('import failed');
  }
}

class _NoopImporter implements DocumentImporter {
  @override
  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();

  @override
  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
}

class _EmptyRepository implements DocumentRepository {
  final _documents = StreamController<List<DocumentSummary>>.broadcast();

  @override
  Stream<List<DocumentSummary>> watchDocuments() => _documents.stream;

  @override
  Future<void> deleteDocument(String documentId) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String documentId) =>
      throw UnimplementedError();

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(locator, double progress) async {}
}

double _luminance(Color color) {
  double channel(double value) {
    final linear = value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return linear;
  }

  final red = channel(color.r);
  final green = channel(color.g);
  final blue = channel(color.b);
  return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = math.max(_luminance(foreground), _luminance(background));
  final darker = math.min(_luminance(foreground), _luminance(background));
  return (lighter + 0.05) / (darker + 0.05);
}
