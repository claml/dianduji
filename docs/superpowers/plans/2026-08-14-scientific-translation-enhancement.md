# Scientific Translation Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the reader card scientific-grade content: a four-domain offline specialized dictionary (computer science, medicine, biology, chemistry), multi-word term recognition, a layered lookup chain (general → specialized → optional online translation), an online translation gateway with minimal disclosure, first-use consent, a settings switch, cancellation, timeouts, and local caching — without breaking any existing learning data.

**Architecture:** Keep the approved feature-oriented MVVM boundaries. Specialized dictionary data ships as a bundled JSON term table with per-entry domain/source/version/license metadata and is loaded into an in-memory index at startup (read-only, no Drift writes). The layered query runs general and specialized lookups in parallel and merges their results. `OnlineTranslationGateway` is a narrow interface implemented over `dart:io` HttpClient; requests contain only the tapped term, its single sentence (≤1000 chars, centered on the term), target language, and domain tag. Online results persist in a Drift `online_translation_cache` table (schema v2 forward migration). The translation card renders local results immediately, then supplements online content without rebuilding the PDF viewer. Online translation is off by default and requires first-use consent in settings.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod 2.6, Drift/SQLite, pdfrx 2.4.7 (unchanged), `dart:io` HttpClient (no new runtime dependency).

## Global Constraints

- No OCR, no pixel-perfect Word, no hard-coded third-party keys in the install package (keys arrive via `--dart-define` at build time), no uploading of PDFs, page images, full-page text, document titles, authors, file paths, device identifiers, or reading history.
- Online requests are off by default; the settings page has a master switch, first-use consent, and a "clear online cache" action.
- Existing documents, vocabulary, phrases, reading progress, and card preferences must survive the schema migration; no re-import.
- The specialized dictionary data must record domain, source, version, and license; only redistributable data is packaged.
- Every interactive target stays ≥48×48dp; reduced motion is respected.
- Use TDD per behavior: focused RED, minimal GREEN, full regression, focused commit.

---

### Task 1: Specialized Dictionary Asset and Lookup

**Files:**
- Create: `mobile/assets/specialized/terms.json`
- Create: `mobile/assets/specialized/LICENSE.md`
- Create: `mobile/lib/features/dictionary/domain/specialized_terms.dart`
- Create: `mobile/lib/features/dictionary/data/specialized_term_catalog.dart`
- Create: `mobile/test/features/dictionary/specialized_term_catalog_test.dart`
- Modify: `mobile/pubspec.yaml`

**Interfaces:**
- Produces: `SpecializedTerm { term, domain, definition, synonyms?, source, version, license }`, `SpecializedTermCatalog.lookup(term)`, `SpecializedTermCatalog.lookupPrefix(term)`, `SpecializedTermCatalog.domains`.
- Consumes: bundled JSON asset.

- [ ] **Step 1: Write failing catalog tests**
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Author the four-domain term table** (≈200–400 entries per domain; MIT-licensed self-curated list; LICENSE.md records sources)
- [ ] **Step 4: Implement the loader and index** (exact match + longest-prefix match; case-insensitive)
- [ ] **Step 5: Verify GREEN, `flutter analyze`, commit**

### Task 2: Multi-Word Term Recognition

**Files:**
- Create: `mobile/lib/features/dictionary/domain/term_candidate_recognizer.dart`
- Create: `mobile/test/features/dictionary/term_candidate_recognizer_test.dart`

**Interfaces:**
- Produces: `List<TermCandidate> { surface, startToken, endToken, domains, score }` from a sentence's tokens plus the tapped token ordinal.
- Ranking: specialized exact hit > contains tapped word > longer term > domain match; the single word remains the final fallback.

- [ ] **Step 1: Write failing recognizer tests** (2–5 word terms, hyphenated compounds, apostrophes, tapped-word containment, ranking)
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Implement**
- [ ] **Step 4: Verify GREEN, commit**

### Task 3: Layered Lookup Chain

**Files:**
- Create: `mobile/lib/features/dictionary/domain/layered_lookup.dart`
- Create: `mobile/test/features/dictionary/layered_lookup_test.dart`
- Modify: `mobile/lib/features/dictionary/presentation/translation_view_model.dart`
- Modify: `mobile/test/features/dictionary/translation_flow_test.dart`

**Interfaces:**
- Produces: `LayeredLookupResult { generalEntry?, specializedTerms[], online? }`; general and specialized lookups run in parallel and merge; a general hit never shadows a specialized multi-word term.
- Consumes: `DictionaryLookup`, `SpecializedTermCatalog`, `TermCandidateRecognizer`.

- [ ] **Step 1: Write failing layered tests** (parallel merge, specialized-only hit, both-hit display order, offline fallback)
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Implement and wire `TranslationViewModel.lookup` to consume candidates and layered results**
- [ ] **Step 4: Verify GREEN + full regression, commit**

### Task 4: Online Translation Gateway and Cache

**Files:**
- Create: `mobile/lib/core/network/online_translation_gateway.dart`
- Create: `mobile/lib/core/network/http_online_translation_gateway.dart`
- Create: `mobile/lib/features/settings/data/online_translation_settings.dart` (extension of `ReadingSettings` or separate repository row)
- Modify: `mobile/lib/core/database/app_database.dart` (schema v2: `online_translation_cache` table)
- Regenerate: `mobile/lib/core/database/app_database.g.dart`
- Test: `mobile/test/core/network/http_online_translation_gateway_test.dart`
- Test: `mobile/test/core/database/online_translation_cache_test.dart`
- Create: `mobile/docs/online-translation-gateway.md` (contract: request/response shape, sentence cap 1000 chars, retention, log redaction)

**Interfaces:**
- Produces: `OnlineTranslationGateway.translate(OnlineTranslationRequest) → OnlineTranslationResult`; request = term, single sentence, targetLanguage, domain; result = term translation, domain gloss, sentence translation, examples, source id, cacheable version.
- Enforces: timeout, cancellation of stale requests, offline error mapping, malformed-response discard (no cache write, no card overwrite), no document metadata in logs.

- [ ] **Step 1: Write failing gateway contract tests** (request shape, timeout, cancellation, offline mapping, malformed response)
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Implement the HTTP gateway** (base URL + key from `--dart-define` `DIANDUJI_TRANSLATE_BASE_URL` / `DIANDUJI_TRANSLATE_API_KEY`; no hard-coded key)
- [ ] **Step 4: Add the cache table with a forward migration and old-data retention test**
- [ ] **Step 5: Verify GREEN + full regression, commit**

### Task 5: Translation Card Information Architecture

**Files:**
- Modify: `mobile/lib/features/dictionary/presentation/translation_detail.dart`
- Modify: `mobile/test/features/dictionary/translation_detail_test.dart`
- Modify: `mobile/test/features/reader/reader_page_test.dart` if needed

**Interfaces:**
- Card order: term + pronunciation → phonetic/POS → general gloss → specialized gloss with domain tags → current sentence → sentence translation → 1–2 examples with translations → source, offline/online badge, save action.
- Local results render first; online supplements without rebuilding the PDF viewer. The card scrolls on phones; tablet pane/floating card keep existing modes and never squeeze the PDF area.
- No blank section titles when data is absent.

- [ ] **Step 1: Write failing card tests** (ordering, domain tags, sentence block, online badge, scrollability)
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Implement**
- [ ] **Step 4: Verify GREEN + goldens regeneration if visuals change, commit**

### Task 6: Settings, Consent, and Cache Control

**Files:**
- Modify: `mobile/lib/features/settings/presentation/persisted_settings_page.dart`
- Modify: `mobile/lib/features/settings/data/settings_repository.dart` (if schema requires)
- Modify: `mobile/test/features/settings/persisted_settings_test.dart`
- Modify: `mobile/lib/features/settings/data/cache_cleanup_service.dart` (include online cache)

**Interfaces:**
- Settings gains: "在线翻译" master switch (default off), first-use consent dialog ("仅发送所点词与所在句子"), "清除在线翻译缓存" action, and privacy copy stating minimal disclosure.
- Offline/no-network: card shows local results + unavailable reason.

- [ ] **Step 1: Write failing settings tests**
- [ ] **Step 2: Verify RED**
- [ ] **Step 3: Implement**
- [ ] **Step 4: Verify GREEN, commit**

### Task 7: Full Verification and Documentation

**Files:**
- Modify: `mobile/README.md`
- Modify: `mobile/docs/third-party-notices.md`
- Create: `mobile/integration_test/scientific_translation_flow_test.dart` (device: specialized hit + consent-off card + settings switch)

- [ ] **Step 1: Run `flutter analyze` and the full test suite**
- [ ] **Step 2: Run the device integration test on BTK-W00**
- [ ] **Step 3: Update README (features, privacy, dart-define keys) and third-party notices**
- [ ] **Step 4: Final commit**

## Requirements Traceability

| Spec requirement | Implemented by |
|---|---|
| Specialized dictionary (CS/med/bio/chem), domain/source/version/license metadata | Task 1 |
| Multi-word term recognition, longest/domain ranking, word fallback | Task 2 |
| Layered chain: general → specialized, parallel merge, no shadowing | Task 3 |
| Online gateway: minimal disclosure, no keys in package, timeout/cancel/offline, cache | Task 4 |
| Card: sentence, sentence translation, examples, domain tags, source badge, scroll | Task 5 |
| Online switch, first-use consent, clear cache, privacy copy | Task 6 |
| Existing data preserved (schema v2 forward migration) | Task 4 |
| No OCR / no hard-coded keys / no document metadata upload | Global constraints + Task 4 audit |
