# Reader Experience Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add PDF reading extras: outline (table of contents) navigation, a page indicator with page jump, and per-document zoom memory — without changing the PDF viewport or the reflow reader.

**Architecture:** pdfrx already exposes `PdfDocument.loadOutline()`, `PdfViewerController.goToPage/setZoom/currentZoom`, and `controller.pageNumber/pageCount`. The reader page owns a `PdfViewerController` plus a pure-Dart `PdfReaderExtras` (ChangeNotifier) holding the flattened outline and page state. The reader screen renders the outline drawer and the page indicator purely from `PdfReaderExtras` and reports jumps through callbacks, so all logic is unit-testable without a real PDF.

## Global Constraints

- The PDF viewport size must not change when the toolbar appears or disappears; outline/page UI are overlays.
- Reflow (TXT/DOCX) readers must not show any PDF-only controls.
- Zoom memory is per document, stored in the existing settings key-value table (`pdf-zoom-<documentId>`), best-effort read/write.
- Outline loading and zoom restore are best-effort and must never block reading.
- TDD per behavior: focused RED, minimal GREEN, full regression, focused commit.

---

### Task 1: Outline model and PDF extras controller

**Files:**
- Create: `mobile/lib/features/reader/domain/pdf_reader_extras.dart`
- Create: `mobile/test/features/reader/pdf_reader_extras_test.dart`

- [x] **Step 1: Write failing tests** (flatten nested outline with depth; skip entries without a destination; updatePage clamps; setOutline notifies)
- [x] **Step 2: Verify RED**
- [x] **Step 3: Implement `PdfOutlineEntry`, `flattenPdfOutline`, `PdfReaderExtras`**
- [x] **Step 4: Verify GREEN, commit**

### Task 2: Document view outline/zoom hooks

**Files:**
- Modify: `mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart`

- [x] **Step 1: Add `onOutlineAvailable`, `restoreZoom`, `onZoomChanged` parameters**
- [x] **Step 2: Load the outline and restore zoom in `onViewerReady`, best-effort**
- [x] **Step 3: Report zoom changes on `onInteractionEnd`**
- [x] **Step 4: Analyze clean, commit**

### Task 3: Reader screen outline drawer and page indicator

**Files:**
- Modify: `mobile/lib/features/reader/presentation/widgets/reader_top_bar.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Create: `mobile/test/features/reader/reader_screen_extras_test.dart`

- [x] **Step 1: Write failing widget tests** (outline button opens the drawer and jumps; hidden without outline; page indicator shows progress and jumps via dialog; out-of-range input ignored; reflow docs show no controls)
- [x] **Step 2: Verify RED**
- [x] **Step 3: Add the outline button to `ReaderTopBar`; drawer and page indicator to `ReaderScreen`**
- [x] **Step 4: Verify GREEN, commit**

### Task 4: Reader page wiring and zoom memory

**Files:**
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`

- [x] **Step 1: Own a `PdfViewerController` + `PdfReaderExtras`; wire outline/page/zoom callbacks**
- [x] **Step 2: Persist zoom via the settings key-value table (`pdf-zoom-<documentId>`), restore on open**
- [x] **Step 3: Full regression, commit**

### Task 5: Verification and documentation

- [x] **Step 1: `flutter analyze` clean and full test suite green (301 tests)**
- [ ] **Step 2: Device check on BTK-W00 (outline drawer + page jump + zoom restore on a real PDF)**
- [x] **Step 3: Update README feature list**
- [x] **Step 4: Final commit**
