# Document Library Live Refresh Hotfix Design

**Date:** 2026-08-01  
**Status:** Approved by the user after manual Task 5 acceptance failed.

## Problem and Evidence

On the Android tablet emulator, a selected DOCX was copied into the application sandbox and parsed successfully, producing 14 paragraphs, 29 sentences, and 281 tokens. The document did not appear in the live library until the app restarted. After restart, the card appeared and opened the reader normally.

The production page stores the provider-created `DocumentImportController` in a state field. After a rebuild, the page no longer calls `ref.watch(documentImportControllerProvider)`. Because the provider is `autoDispose`, Riverpod disposes the controller and its Drift document subscription, leaving the page with a stale controller reference.

A completed import also displays `parseProgress` as reading progress, so a newly imported document incorrectly says it has been read 100 percent.

PDF extraction remains outside this hotfix. The current resolver intentionally uses an unavailable PDF extractor until Task 6 wires the approved Android PDFBox adapter.

## Chosen Approach

Keep `documentImportControllerProvider` auto-disposed and preserve Riverpod ownership. `DocumentLibraryPage` may cache only explicitly injected controllers (`controller` or the one-time `controllerLoader` result). When it uses the production provider, it must call `ref.watch(documentImportControllerProvider)` on every build so the provider remains subscribed for the page lifetime.

Map the library card's progress to `DocumentSummary.readProgress` after import completes. Queued/parsing cards continue using `DocumentSummary.progress`, which is the parser progress. No database schema or repository interface changes are needed.

## Alternatives Rejected

1. Remove `autoDispose` from the provider. This would mask the page ownership error and keep document controllers alive when the document page is not visible.
2. Manually reload documents after each import. This duplicates Drift's reactive contract and does not fix updates caused by retry, deletion, or other repository writes.
3. Start Task 6 at the same time. PDFBox is a separate native integration with its own fixtures and failure matrix; combining it would make the Word hotfix harder to verify and violate the manual checkpoint.

## Data Flow

1. The production page watches the auto-disposed controller provider on every build.
2. The controller retains its `watchDocuments()` subscription while the page is mounted.
3. Import writes update Drift; Drift emits the full document list; the controller rebuilds the library immediately.
4. Completed cards display persisted reading progress, while in-progress cards display parser progress.
5. Tapping a completed card continues to navigate through the existing `onOpen(documentId)` route.

## Error Handling and Scope

- Preserve existing import error, retry, duplicate, cancellation, and deletion behavior.
- Do not change file picking, DOCX parsing, document storage, reader routing, or PDF behavior.
- Do not add dependencies or database migrations.
- Keep phone and tablet layouts unchanged.

## Tests and Acceptance

- A provider-backed widget regression emits an initial document, rebuilds the page, then emits a newly completed DOCX. The DOCX must appear without restarting and tapping it must call `onOpen` with its ID.
- A controller mapping test proves a completed document with parser progress `1.0` and reading progress `0.0` displays `0%` reading progress.
- Existing injected-controller and loader-once tests remain green.
- Run focused document tests, the full Flutter suite, static analysis, and Android x64 profile build.
- Install the new APK on `emulator-5554` and manually confirm immediate DOCX appearance/opening. PDF remains deferred to Task 6.
