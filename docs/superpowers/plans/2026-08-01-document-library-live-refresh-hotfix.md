# Document Library Live Refresh Hotfix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make a successfully imported DOCX appear and open immediately without restarting, and show true reading progress on completed document cards.

**Architecture:** Preserve the existing Riverpod/Drift ownership boundaries. The production document page continuously watches its auto-disposed controller provider, while explicitly injected test controllers remain cached once. Choose parser progress only for queued/parsing documents and persisted reading progress for completed documents.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod 2.6, Drift/SQLite, Flutter widget tests.

## Global Constraints

- Work only in `D:\Vibe Coding\点读机\.worktrees\flutter-mvp-remaining` on branch `codex/flutter-mvp-remaining`.
- Do not implement or alter PDF extraction; Android PDFBox remains Task 6.
- Do not add dependencies, migrations, or repository/database writes.
- Keep `file_picker` pinned to `10.3.10` and `kotlin.incremental=false`.
- Preserve TXT/DOCX parsing, duplicate, retry, cancellation, deletion, reader routing, phone/tablet layout, and at least 48×48dp interaction targets.
- Use strict RED → minimal GREEN and keep temporary `T:`/vswhere workarounds out of Git.

---

### Task 1: Keep the document subscription alive and separate parse/read progress

**Files:**
- Modify: `mobile/lib/features/documents/presentation/document_library_page.dart`
- Modify: `mobile/lib/features/documents/presentation/document_import_controller.dart`
- Test: `mobile/test/features/documents/document_library_page_test.dart`
- Test: `mobile/test/features/documents/document_import_controller_test.dart`

**Interfaces:**
- Consumes: `documentImportControllerProvider`, `DocumentImportController`, `DocumentSummary.progress`, and `DocumentSummary.readProgress`.
- Produces: the existing `DocumentLibraryPage` and `LibraryDocument.progress` contracts with corrected lifecycle and progress semantics; no public signature changes.

- [ ] **Step 1: Write the provider-lifecycle widget regression**

Add a test that overrides `documentImportControllerProvider` with a real `DocumentImportController` backed by the existing controllable repository and mounts the production provider path. The first repository emission rebuilds the consumer; an extra pump allows `autoDispose` to run. Then emit the PDF plus a completed DOCX row. Assert the DOCX title is visible without remounting and tapping it records `docx-1` through `onOpen`. The provider owns this controller in the test, so do not dispose it a second time manually.

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      documentImportControllerProvider.overrideWith((ref) => controller),
    ],
    child: MaterialApp(
      home: DocumentLibraryPage(onOpen: (id) => openedId = id),
    ),
  ),
);
repository.emit([_pageSummary('pdf-1', 'Existing PDF')]);
await tester.pump();
await tester.pump();
repository.emit([
  _pageSummary('pdf-1', 'Existing PDF'),
  _pageSummary('docx-1', 'Imported Word'),
]);
await tester.pump();
expect(find.text('Imported Word'), findsOneWidget);
await tester.tap(find.text('Imported Word'));
expect(openedId, 'docx-1');
```

- [ ] **Step 2: Run the lifecycle test and verify RED**

Run from the temporary ASCII worktree mapping:

```powershell
& $flutter test test/features/documents/document_library_page_test.dart --no-pub
```

Expected: the new DOCX assertion fails because the cached provider controller loses its active Riverpod subscription after rebuild.

- [ ] **Step 3: Implement the minimal lifecycle correction**

Cache only injected controllers and watch the production provider on every build:

```dart
late final DocumentImportController? _injectedController =
    widget.controller ?? widget.controllerLoader?.call();

@override
Widget build(BuildContext context) {
  final controller =
      _injectedController ?? ref.watch(documentImportControllerProvider);
  // Existing AnimatedBuilder and callbacks remain unchanged.
}
```

Do not dispose injected controllers inside the page; ownership remains with their creator. Riverpod continues to dispose production controllers.

- [ ] **Step 4: Run the lifecycle test and verify GREEN**

Run the same focused page test. Expected: all tests in the file pass, including loader-called-once and immediate DOCX appearance/opening.

- [ ] **Step 5: Write the completed-document progress regression**

Add a controller test with `progress: 1.0` and `readProgress: 0.0`, emit it through the repository, and assert the mapped library document has `progress == 0.0`. Also keep or add a parsing row assertion proving parsing progress remains unchanged.

```dart
expect(controller.state.documents.single.progress, 0.0);
```

- [ ] **Step 6: Run the progress test and verify RED**

```powershell
& $flutter test test/features/documents/document_import_controller_test.dart --no-pub
```

Expected: the completed-document assertion receives `1.0`, proving parser progress is mislabeled as reading progress.

- [ ] **Step 7: Implement the minimal progress mapping**

In `_libraryDocument`, choose progress by status before building `LibraryDocument`:

```dart
final completed = document.status == 'completed';
return LibraryDocument(
  id: document.id,
  title: document.title,
  sourceName: document.sourceName,
  formatLabel: document.format.toUpperCase(),
  progress: completed ? document.readProgress : document.progress,
  status: switch (document.status) {
    'queued' => LibraryDocumentStatus.queued,
    'parsing' => LibraryDocumentStatus.parsing,
    'completed' => LibraryDocumentStatus.completed,
    'cancelled' => LibraryDocumentStatus.cancelled,
    _ => LibraryDocumentStatus.failed,
  },
  failureMessage: document.failureMessage,
);
```

- [ ] **Step 8: Run focused and regression verification**

```powershell
& $flutter test test/features/documents --no-pub
& $flutter test --no-pub
& $flutter analyze --no-pub
& $flutter build apk --profile --target-platform android-x64 --no-pub
```

Expected: all commands exit 0; analysis says `No issues found!`; the x64 profile APK is produced.

- [ ] **Step 9: Record evidence and commit**

Append RED/GREEN and verification output to the plan-owned SDD report. Confirm `git diff --check`, no temporary shim or `T:` mapping, then commit only the hotfix and its tests:

```powershell
git add mobile/lib/features/documents/presentation/document_library_page.dart mobile/lib/features/documents/presentation/document_import_controller.dart mobile/test/features/documents/document_library_page_test.dart mobile/test/features/documents/document_import_controller_test.dart
git commit -m "fix: refresh imported documents immediately"
```
