# Mudabbir Screen & Architecture Audit

**Audit baseline:** `main` at `17ad3b37df29bf6d02355955348c49556aa4e2bc`  
**Date:** 2026-10-28  
**Purpose:** Record verified repository facts before UI and navigation refactoring. This is an inventory, not a claim that every target screen is complete.

## Repository snapshot

- Flutter package: `mudabbir_al_asrar`, version `2.0.0+200`.
- Dart SDK constraint: `>=3.2.0 <4.0.0`.
- CI config currently installs Flutter `3.47.7`.
- Repository tree contains 315 tracked blob files in the inspected recursive tree.
- `lib/` contains 251 Dart files.
- `test/` contains 32 Dart test files.
- A filename-based scan finds 51 screen/page/navigation candidates under `lib/presentation/screens/`. This is a count of candidate files, **not** a count of unique, reachable, or complete screens.
- The latest inspected Actions run was run #909 (`40633271680`) on the baseline commit; GitHub reports it completed successfully. Its listed build job conclusion is `success`.
- Open PR #72 (`ci/cache-android-ndk-r28c`) exists independently and must not be overwritten or conflated with this UI work.

## Verified screen candidates

The current tree contains these screen-like files:

- `lib/presentation/screens/abjad_screen.dart`
- `lib/presentation/screens/about_screen.dart`
- `lib/presentation/screens/advanced_search_screen.dart`
- `lib/presentation/screens/advanced_tech_screen.dart`
- `lib/presentation/screens/agents/agent_console_screen.dart`
- `lib/presentation/screens/agents/agents_screen.dart`
- `lib/presentation/screens/ai_advanced_screen.dart`
- `lib/presentation/screens/challenges_screen.dart`
- `lib/presentation/screens/chat/chat_screen.dart`
- `lib/presentation/screens/chat_screen.dart`
- `lib/presentation/screens/community_screen.dart`
- `lib/presentation/screens/compare_screen.dart`
- `lib/presentation/screens/cosmic_services_screen.dart`
- `lib/presentation/screens/customize_screen.dart`
- `lib/presentation/screens/daily_verse_screen.dart`
- `lib/presentation/screens/device/ar_lens_screen.dart`
- `lib/presentation/screens/device/gaze_tracking_screen.dart`
- `lib/presentation/screens/divine_names_screen.dart`
- `lib/presentation/screens/elements_screen.dart`
- `lib/presentation/screens/favorites_screen.dart`
- `lib/presentation/screens/great_verses_screen.dart`
- `lib/presentation/screens/help_screen.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/insight_screen.dart`
- `lib/presentation/screens/leaderboard_screen.dart`
- `lib/presentation/screens/letters_screen.dart`
- `lib/presentation/screens/main_navigation.dart`
- `lib/presentation/screens/miracles_screen.dart`
- `lib/presentation/screens/nucleus_screen.dart`
- `lib/presentation/screens/numbers_screen.dart`
- `lib/presentation/screens/occult_explorer_screen.dart`
- `lib/presentation/screens/personalization_screen.dart`
- `lib/presentation/screens/planets_screen.dart`
- `lib/presentation/screens/player_profile_screen.dart`
- `lib/presentation/screens/quran/mushaf_screen.dart`
- `lib/presentation/screens/quran/mushaf_variant_screen.dart`
- `lib/presentation/screens/quran/quran_pro_screen.dart`
- `lib/presentation/screens/quran_index_screen.dart`
- `lib/presentation/screens/quran_multimode_screen.dart`
- `lib/presentation/screens/quran_page_screen.dart`
- `lib/presentation/screens/quran_screen.dart`
- `lib/presentation/screens/quran_word_explorer_screen.dart`
- `lib/presentation/screens/recitation_screen.dart`
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/settings_screen.dart`
- `lib/presentation/screens/sovereign_hub_screen.dart`
- `lib/presentation/screens/splash_screen.dart`
- `lib/presentation/screens/stats_screen.dart`
- `lib/presentation/screens/surah_index_screen.dart`
- `lib/presentation/screens/tafsir_screen.dart`
- `lib/presentation/screens/training_screen.dart`
- `lib/presentation/screens/zodiac_screen.dart`

## Initial findings requiring follow-up

### 1. Navigation has two separate implementations

- `lib/main.dart` starts with `SplashScreen`.
- `HomeScreen` provides five primary destinations: Mushaf, search, daily verse, chat, and more.
- `MainNavigation` provides a different four-destination shell: chat, Quran, Abjad, and more.
- Both implementations should be mapped for routes, entry points, back behavior, and reachable destinations before consolidation. Do not delete either path until unique destinations and existing behavior are preserved.

### 2. Miracles screen currently presents fixed claims

`lib/presentation/screens/miracles_screen.dart` is currently a `StatelessWidget` with five hard-coded claim cards. It does not yet demonstrate a calculation engine or a graph whose values are derived from verified runtime calculations. Claims need source/method disclosure and reproducible calculations before being presented as verified results.

### 3. Quran page uses the local Quran asset

`lib/presentation/screens/quran_page_screen.dart` loads `assets/unified_quran.json`, applies `QuranSourceCorrections`, updates the shared Quran context, and records reading activity. Changes must preserve this data path and keep the original verse text immutable. Its error, loading, font-size, and lifecycle behavior should be covered by tests.

### 4. Local model lifecycle already exists

`NucleusService` is a singleton gateway over `LocalGgufRuntimeService` and `AgentKnowledgeService`. The GGUF runtime verifies a file header and only reports inference readiness after native loading succeeds. Prefer improving and integrating these existing services instead of creating a parallel runtime.

### 5. Registry entries are not proof of active agents

`AgentRegistry` defines agent metadata. Registration count must not be presented as the number of agents actively executing. The Nucleus UI should distinguish registration from readiness, execution, completion, failure, and unavailability using real state where supported.

### 6. The target bookmark screen is not obvious in the filename inventory

A dedicated `quran_bookmarks_screen.dart` adapter now reuses `FavoritesScreen` and the existing `BookmarkService`; it does not create a second bookmark store.

## Existing validation assets

The repository has tests covering, among other areas:

- Quran integrity and source corrections.
- Quran search and word indexes.
- Mushaf smoke behavior.
- Quran wave text.
- GGUF runtime.
- Nucleus service and registry identifiers.
- More-screen navigation.
- Recitation screen.
- Local embeddings and training guards.

The presence of these tests does not itself prove that all tests pass on the current working tree; CI status above refers only to the inspected GitHub Actions run.

## Current implementation priorities

1. Continue behavioral review of each reachable screen and route; the 23-target file mapping is established, but the mapping alone does not establish completion.
2. Continue applying the shared design tokens and 12 presentation templates where they fit without replacing real feature logic.
3. The numerical-claim screen has been converted to reproducible local word counts; retain the documented normalization limits.
4. The Nucleus graph uses registry metadata and explicitly avoids claiming that registered agents are active processes.
5. Continue improving Quran interactions while keeping canonical verse text immutable and applying script transformations only to presentation.
6. Continue wiring existing local services to their screens, expose recoverable errors, and do not fabricate model, network, training, sensor, or community capabilities.
7. During the current implementation phase, defer tests, formatting, analysis, and Android builds as explicitly requested; do not report them as run or passed.

## Scope guardrails

- Do not claim all 23 target screens are complete based on filenames alone.
- Do not treat agent registry entries as active processes.
- Do not label TF-IDF as neural embeddings.
- Do not claim model training when only inference is supported.
- Do not modify Quran source text through AI generation.
- Do not change workflow secrets or remove existing CI/build/artifact steps without a verified reason.


## Implementation progress — first feature slice

### Quran numerical analysis

Implemented on the audit branch:

- `lib/services/quran_numerical_analysis_service.dart` parses the bundled `assets/unified_quran.json` data and computes word counts from each verse's `text` field.
- Counts use a documented normalization rule: remove Arabic diacritics and tatweel, normalize common alif forms, map alif maqsura to ya, and tokenize Arabic letters.
- `lib/presentation/screens/miracles_screen.dart` now loads real local data, shows corpus totals, supports single-word exact normalized searches, and draws animated bars whose lengths reflect computed counts.
- The former hard-coded numerical-claim cards were removed from this screen. The UI explicitly explains that literal counts depend on the normalization convention and do not, by themselves, establish a religious claim.
- `test/quran_numerical_analysis_service_test.dart` covers corpus aggregation, word counts, and invalid/empty input.

### Validation status

The initial implementation slice passed GitHub Actions analysis, nucleus core tests, Quran numerical-analysis tests, Android split-APK build, and upload of arm64-v8a, armeabi-v7a, and x86_64 artifacts. Bookmark and template coverage is added in the next change group and must be checked by the next workflow run.


## Target-screen mapping (verified filename-level mapping)

| # | Target | Current implementation / status |
|---:|---|---|
| 1 | SplashScreen | `lib/presentation/screens/splash_screen.dart` |
| 2 | MainNavigation | `lib/presentation/screens/main_navigation.dart`; now a compatibility adapter to canonical `HomeScreen` |
| 3 | ChatScreen | `lib/presentation/screens/chat/chat_screen.dart` is the canonical HomeScreen destination; `lib/presentation/screens/chat_screen.dart` is now a compatibility export to avoid duplicate UI/provider state |
| 4 | QuranScreen | `lib/presentation/screens/quran_screen.dart`; the home reading shortcut also opens `quran/mushaf_screen.dart` |
| 5 | SurahIndexScreen | `lib/presentation/screens/surah_index_screen.dart` |
| 6 | QuranPageScreen | `lib/presentation/screens/quran_page_screen.dart` |
| 7 | RecitationScreen | `lib/presentation/screens/recitation_screen.dart` |
| 8 | QuranBookmarksScreen | `lib/presentation/screens/quran_bookmarks_screen.dart`; presentation adapter over the existing `FavoritesScreen` and `BookmarkService`, so bookmark persistence is shared rather than duplicated |
| 9 | AbjadScreen | `lib/presentation/screens/abjad_screen.dart` |
| 10 | MiraclesScreen | `lib/presentation/screens/miracles_screen.dart`; now backed by local, reproducible word-count calculations |
| 11 | StatsScreen | `lib/presentation/screens/stats_screen.dart` |
| 12 | CompareScreen | `lib/presentation/screens/compare_screen.dart` |
| 13 | NucleusScreen | `lib/presentation/screens/nucleus_screen.dart`; uses the existing nucleus and GGUF runtime services |
| 14 | AIAdvancedScreen | `lib/presentation/screens/ai_advanced_screen.dart` |
| 15 | PersonalizationScreen | `lib/presentation/screens/personalization_screen.dart` |
| 16 | TrainingScreen | `lib/presentation/screens/training_screen.dart`; verify runtime capabilities before describing training as active |
| 17 | SovereignHubScreen | `lib/presentation/screens/sovereign_hub_screen.dart` |
| 18 | CosmicServicesScreen | `lib/presentation/screens/cosmic_services_screen.dart` |
| 19 | PlayerProfileScreen | `lib/presentation/screens/player_profile_screen.dart` |
| 20 | AdvancedSearchScreen | `lib/presentation/screens/advanced_search_screen.dart` |
| 21 | FavoritesScreen | `lib/presentation/screens/favorites_screen.dart` |
| 22 | HelpScreen | `lib/presentation/screens/help_screen.dart` |
| 23 | AboutScreen | `lib/presentation/screens/about_screen.dart` |

This is a file-to-target mapping, not a claim that every target has passed behavioral testing. The dedicated Quran bookmarks route now reuses the existing bookmark storage and is listed in the More screen; behavior is covered by the More screen navigation test.

### Navigation consolidation change

`MainNavigation` no longer owns a separate four-tab shell. It delegates to `HomeScreen`, which is the entry destination after `SplashScreen`, and re-exports the existing `MoreScreen` symbol for legacy import compatibility. This removes the duplicate navigation implementation without deleting the HomeScreen tools directory.


### Nucleus registry graph

`NucleusScreen` now includes a custom-painted, tappable radial map sourced from `AgentRegistry.all`, a selector for all registered definitions, and a details panel for the selected entry. The radial spokes intentionally mean only “this definition belongs to the registry”; they do not claim runtime connections or active execution. The graph draws a bounded subset to keep rendering costs predictable, while the selector can reach the full registry.

### Quran bookmarks interaction

`QuranPageScreen` now reads saved verse references from the existing `BookmarkService`, shows a bookmark control on each verse, and persists add/remove actions through the same store used by `FavoritesScreen`. The dedicated bookmarks route has a widget test for its title and empty state.

### Shared visual foundation

Added `MudabbirDesignTokens` for the cosmic palette, spacing, and motion durations, plus `MudabbirGlassPanel` for restrained translucent surfaces without expensive full-screen blur. The numerical-analysis and Nucleus graph screens now use the shared panel/background tokens for their main interactive surfaces.

### Shared templates

Added 12 reusable layout primitives in `lib/presentation/templates/mudabbir_templates.dart`: Dashboard, Reader, Chat, Library, Analytics, Graph, Player, Settings, Search, Profile, Lab, and Service Hub. They compose presentation only; feature screens retain ownership of state and services. `MiraclesScreen` now uses `AnalyticsTemplate`, and a widget smoke test covers all 12 templates.

## Continued implementation — 2026-10-28

This section records follow-up work added after the initial audit. It describes code changes only; it is not a statement that the application has been built or behaviorally validated.

### Quran reader
- QuranPro search compares normalized text while preserving the canonical verse string; it handles diacritics, Quranic annotation marks, tatweel, common alef/hamza variants, ta marbuta/alef maqsura, and Arabic/Persian digits.
- Selecting a verse updates the existing `NucleusService` context with original source text. Long-press copies that original text rather than transformed display glyphs.
- Double tap toggles reading chrome in QuranPro, the canonical surah reader, and the fixed-layout variant reader.
- The canonical surah reader persists its selected font size locally.
- Removed an unused repeating ticker that rebuilt every QuranPro verse row without changing its appearance.

### Fixed-layout Mushaf performance
- Parsed page layouts are cached by page number.
- Concurrent page requests share a single in-flight layout-asset load; a failed load is not permanently cached.
- Verse word tokenization is cached within each page parse so multiple word-location records from the same verse do not repeatedly resolve and split the same verse text.

### Agent execution and recovery
- Explicit agent selection constrains the route to planning/safety, the selected specialist, and critic/verifier steps instead of silently running the full default pipeline.
- Concurrent screen initialization and task submission share one in-flight Quran/knowledge initialization.
- A deterministic local word-frequency agent reports exact normalized token counts only when a specific indexed word is found. It discloses normalization and does not claim a partial index is the total Quran word count.
- Cancellation has an explicit step status and preserves the latest task snapshot. Pause is described as cooperative and takes effect at a step boundary; the UI does not claim that an in-progress native inference was suspended.
- Failed/cancelled tasks can be retried, task JSON can be copied from the console, and the visible conversation can be cleared without deleting persisted memory runs or vault notes.
- A history persistence error after successful task completion is reported separately and does not rewrite the completed task as failed.

### Navigation follow-up
- Removed a duplicate Quran-bookmarks quick action.
- Added Quran bookmarks to the searchable More directory and normalized Arabic variants during its search.
- The Quran index search now normalizes Arabic/Persian digits and common Arabic orthographic variants.

### Validation policy for this continuation
Per the user's explicit instruction, tests and builds were not run for these follow-up changes. Do not infer buildability, runtime correctness, or release readiness from the existence of commits alone.

### Additional service-screen follow-up
- `CosmicServicesScreen` now has a local-only dream journal and date-based time-capsule storage using application preferences. Quantum/audio/astronomy cards explicitly disclose that they do not run real physical measurements or claim therapeutic effects; eye tracking opens the existing calibration screen.
- `SovereignHubScreen` listens to live P2P discovery callbacks, lists discovered peers, exposes independent advertise/discover/stop controls, and permits sending a connection request. Both endpoints must explicitly accept a connection request; the UI displays the Nearby authentication token for out-of-band comparison and reports request submission rather than assuming that the remote device accepted the connection.
- `P2PMeshService` publishes discovery/connection state changes to listeners, tracks connected peers separately from discovered endpoints, requires explicit approval on both endpoints, and resets activity flags after failed startup.
- `PlayerProfileScreen` labels the current checkpoint action as local-only because `CloudSyncService` persists a timestamp in SharedPreferences and does not have a remote backend configured.

These changes are code-level implementation notes only. No tests/builds were run for this continuation.

### Symbolic knowledge screens
- Planetary, zodiac, elemental, number-symbolism, Abjad, and occult screens now explicitly identify their correspondences as historical/cultural/conventional systems rather than scientifically validated causal claims or predictions.

### Traditional list/data corrections
- `AbjadConstants.divineNames` now contains 99 unique entries in a commonly circulated traditional list, without the prior malformed Unicode item or duplicate names. The UI provides 99 matching concise glosses and discloses that lists/orderings may vary.
- `LettersScreen` now shows traditional Abjad numeric values rather than sequential Arabic alphabet indices and corrects the lunar/solar letter groups and the five qalqalah letters.
- Symbolic number/planet/element mappings use consistent one-based indexing and reject non-positive inputs.

### Additional correctness and lifecycle work
- `StatsScreen` now reuses its local-statistics future and exposes retry on storage errors instead of remaining indefinitely on a spinner.
- The canonical chat provider and agent-console provider guard notifications after disposal and stop active GGUF generation when their screen-owned execution is torn down.
- `AdvancedTechScreen` only shows time-capsule contents after their unlock date, explicitly discloses plaintext local storage, reports audio errors, and requests permission before showing live coordinates/altitude. Geolocation clears cached coordinates when tracking stops or permission is unavailable.
- The shared time-capsule service is used by both capsule entry points; old CosmicServicesScreen capsule records are migrated into the shared store.
- The profile screen describes its checkpoint as local-only and restores its timestamp at startup; no remote cloud sync backend is claimed.
- Abjad calculations now use the shared letter-value table; fake energy/frequency outputs are removed or set to zero, symbolic mappings are labeled as such, and the 99-name list is shared across the UI, service, and datasource.
- P2P advertising/discovery now requests runtime permissions and requires explicit approval on both endpoints with authentication-token comparison.

### More-directory reachability
- Added searchable entries for the Quran word explorer, Advanced Tech, the detailed Abjad screen, and the symbolic elements/numbers/zodiac screens. These routes reuse the canonical widgets and wrap provider-dependent Abjad screens with their required provider.


## UI continuation — 2026-10-29

### Implemented in this continuation

- `lib/presentation/screens/compare_screen.dart`: replaced fixed sample verses and hard-coded numeric/symbolic interpretations with a reference-driven comparison using `QuranLoaderService.loadAllAyahs()`. The screen accepts Latin, Arabic-Indic, and Persian digits; validates references against loaded local data; renders original verse text unchanged; and computes a clearly labelled lexical overlap using normalization only for comparison.
- `lib/presentation/screens/quran_screen.dart`: removed an unused repeating animation and sensor listener from the reader, added a visible loading failure/retry state, made surah changes reset the page, connected previous/next controls to the actual `PageView`, and updates the verse counter as the page changes. Removed the unsupported fixed Jummal/axis label from the verse card.
- `lib/presentation/screens/help_screen.dart`: expanded the short help list into an Arabic guide covering navigation, Quran reading, recitation, bookmarks, search, local agents/GGUF, personalization, training limits, comparison, reading stats, profile tracking, nearby P2P, local persistence, privacy, and About. The guide explicitly distinguishes local persistence from cloud sync and registered agents from active execution.

### Validation status for this continuation

Per the user's current instruction, no tests, formatter, analyzer, or APK build were run. These changes are committed to the audit branch but remain unverified by compilation/runtime checks. Continue the screen-by-screen behavioral audit; do not mark the 23-screen specification complete based on the file mapping alone.


### UI continuation — search recovery and capability disclosures

- `lib/presentation/screens/advanced_search_screen.dart`: added explicit index-loading/error/retry states, query clearing, no-match feedback, and support for Arabic-Indic/Persian digits in verse references. Search normalizes text only for matching; the displayed Quran verse text remains unchanged. Added an explicit search action while typing.
- `lib/presentation/screens/about_screen.dart`: removed unsupported numerical claims about neural networks/features and blanket claims that the complete application works offline. The page now describes the actual feature boundaries, notes that local-model availability depends on importing/loading a compatible GGUF model, and distinguishes local persistence from encryption or cloud synchronization.
- Validation remains intentionally deferred: no tests, analyzer, formatter, or build were run in this continuation, per the user's instruction.

## UI continuation — 2026-10-29 (runtime recovery and metrics)

- Nucleus initialization can be retried after bundled-data fallback or knowledge-index initialization failure; the screen labels fallback/degraded state and exposes a retry action. A loaded GGUF model remains independent of nucleus metadata readiness.
- Reading statistics now labels the seven-day value as pages read, matching the underlying `getPagesReadInLast7Days()` source rather than incorrectly describing it as days.
- Recitation completion handling now refuses to advance when playback has been stopped by the user or is paused, reducing a race between player completion and user controls.
- These changes were committed without running tests or builds, per the current execution instruction. They are not a substitute for runtime verification.


## UI continuation — 2026-10-29 (chat continuity and preferences)

- `lib/presentation/providers/chat_provider.dart`: chat prompts now consume the persisted assistant personality and include a bounded snapshot of recent questions as continuity hints; these hints are explicitly not treated as verified evidence. Successful local answers are saved to context memory.
- `lib/services/context_memory_service.dart`: concurrent restoration is coalesced, failed writes no longer permanently poison the serial persistence queue, and saved question/answer sizes are bounded. Added a bounded recent-exchange summary for the personalization screen.
- `lib/services/ai_personality_service.dart` and `lib/presentation/screens/personalization_screen.dart`: persisted personality selection can be awaited, preference loading is coalesced, and the UI text reflects the actual chat integration and local persistence behavior.
- The personalization screen displays recent saved exchange summaries rather than only a list of questions.
- Validation remains intentionally deferred: no tests, analyzer, formatter, or build were run in this continuation.


## UI continuation — 2026-10-29 (knowledge readiness and conversation context)

- The agent knowledge service now coalesces concurrent requests to load optional script variants, avoiding duplicate concurrent index mutation.
- Initialization now fails explicitly when the required knowledge asset was not actually loaded, rather than silently returning with an unusable index. The nucleus can report this as a degraded knowledge state and retry initialization.
- Chat context now includes a bounded snapshot of recent saved exchanges (question plus a short answer summary), not just prior questions. This context is treated as conversational continuity, not verified evidence.
- No tests, analyzer, formatter, or build were run, per the current instruction.


## UI continuation — 2026-10-29 (agent registry and evidence verdicts)

- `lib/services/agent_registry.dart`: normalized the tilawa agent ID and exposed read-only layer grouping helpers so agent screens can group definitions consistently.
- `lib/services/agent_knowledge_service.dart`: required knowledge initialization now rejects an empty index as well as a missing required source; retry remains possible after failure.
- `lib/presentation/providers/agent_chat_provider.dart`: the independent verifier now distinguishes non-empty outputs from traceable source evidence. An output-only run is explicitly labeled as structurally complete, not verified.
- Achievement persistence is now best-effort after task completion. A failure to update achievements is reported as a warning and does not rewrite an otherwise successful retrieval/inference task as failed.
- Per instruction, tests, analysis, formatting, and APK builds remain unrun.


## UI continuation — 2026-10-29 (agent selection and local training)

- `lib/presentation/providers/agent_chat_provider.dart`: agent selection now resolves IDs through the registry, clears selection errors when the user returns to automatic routing, and rejects stale/unknown IDs instead of silently routing them to generic knowledge search.
- `lib/presentation/screens/agents/agent_console_screen.dart`: displays an inline error when an invalid agent ID is rejected.
- `lib/presentation/screens/training_screen.dart`: connected the labeled JSON dataset import to the existing on-device linear-classifier training service. The start action stays disabled until a dataset is loaded, indicates active training, supports the existing cooperative stop action, and reports the resulting service status. This remains classifier-only; it does not train or merge GGUF/Qwen weights and does not auto-label Quran text.
- Tests, analyzer, formatter, and APK build were not run, per instruction.


## UI continuation — 2026-10-29 (local services resilience)

- `lib/presentation/screens/sovereign_hub_screen.dart`: peer connection, accept, and reject operations now catch service/plugin failures and expose them in the status panel rather than allowing uncaught asynchronous errors to escape the UI.
- `lib/presentation/screens/cosmic_services_screen.dart`: time capsules selected for today's date unlock at the end of that local day instead of midnight; dream journal entries are limited to 5,000 characters and 200 retained entries; capsule content is limited to 10,000 characters before persistence.
- `lib/services/time_capsule_service.dart`: enforces non-empty bounded capsule content and a 200-capsule local storage ceiling at the persistence boundary, including calls outside the screen.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (navigation and profile resilience)

- `lib/presentation/screens/player_profile_screen.dart`: local checkpoint-save exceptions now produce a visible status message rather than an uncaught asynchronous failure.
- `lib/presentation/screens/home_screen.dart`: removed a duplicated quick-action destination and exposed the dedicated letters screen from the quick-access row.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (agent capability transparency)

- `lib/presentation/providers/agent_chat_provider.dart`: each agent step now reports whether its ID has an explicit runtime handler or currently falls back to generic local knowledge retrieval. This prevents registry presence from being mistaken for an independently implemented specialist.
- Tests, analyzer, formatter, and APK build remain intentionally unrun.


## UI continuation — 2026-10-29 (bookmark mutation safety)

- `lib/services/bookmark_service.dart`: bookmark removal now reads the underlying local store directly while already inside the serialized mutation queue. Calling the public queue-aware read from inside the queue awaited the current mutation itself and could deadlock removals.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (search and playback error paths)

- `lib/presentation/screens/ai_advanced_screen.dart`: local Quran index failures now expose a dedicated retry action instead of leaving the user with only a search action that cannot recover the failed index.
- `lib/presentation/screens/recitation_screen.dart`: asynchronous audio release-mode initialization and explicit stop failures are surfaced through the playback error state rather than becoming uncaught or silently swallowed errors.
- Tests, analyzer, formatter, and APK build were not run.


## UI continuation — 2026-10-29 (Quran reader and index recovery)

- `lib/presentation/screens/quran_page_screen.dart`: missing or empty corrected surah data now displays an explicit local-source error rather than a blank reader. Font-size preference restoration/saving failures no longer escape as uncaught asynchronous errors; the screen preserves the in-session font size and reports persistence failure when relevant.
- `lib/presentation/screens/ai_advanced_screen.dart`: the local Quran index now has a dedicated retry control after initialization failure.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local knowledge recovery)

- `lib/presentation/screens/occult_explorer_screen.dart`: the local knowledge list can now retry loading its bundled dataset after an error instead of leaving the screen permanently stuck on an error card.
- `lib/presentation/screens/quran_index_screen.dart`: failure to restore optional last-page metadata no longer prevents browsing the canonical surah/juz/hizb index.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (calculation and achievement resilience)

- `lib/presentation/screens/abjad_screen.dart`: a successful local Abjad calculation remains visible if optional achievement persistence fails; the failure is reported separately.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (Mushaf page navigation)

- `lib/presentation/screens/quran/mushaf_screen.dart`: page-jump input now accepts Arabic-Indic and Persian digits and rejects invalid/out-of-range values with visible feedback instead of silently normalizing them to the first or last page.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (variant reader navigation)

- `lib/presentation/screens/quran/mushaf_variant_screen.dart`: added direct page navigation from the variant-reader header, including Arabic-Indic/Persian digit normalization and strict 1–604 validation. The user can now jump to a page without repeatedly swiping through the fixed-layout Mushaf.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (reader recovery actions)

- `lib/presentation/screens/quran_page_screen.dart`: added an explicit retry action for missing/corrupt surah data and resets loading/error state before retrying.
- `lib/presentation/screens/quran/mushaf_variant_screen.dart`: added a direct page-jump action with Arabic numeral support and range validation.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (startup responsiveness)

- `lib/presentation/screens/splash_screen.dart`: home navigation no longer waits indefinitely for local knowledge indexing. After an eight-second startup budget, the app opens with a clear message while the shared nucleus initialization continues and can still report readiness/failure to listeners.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (Mushaf navigation race)

- `lib/presentation/screens/quran/mushaf_screen.dart`: explicit page jumps now mark the reader as user-navigated before starting the animation, preventing a delayed last-page restore from overriding the user's chosen destination.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (fixed-layout Quran page integrity)

- `lib/services/mushaf_variant_layout_service.dart`: missing/empty page metadata now raises a recoverable data error instead of silently rendering a page of blank line slots. The existing screen error state can offer a retry and does not misrepresent absent layout as a valid page.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (training checkpoint recovery)

- `lib/presentation/providers/training_provider.dart`: concurrent model initialization requests are coalesced; a missing or invalid starter checkpoint remains non-blocking for supervised training and can be explicitly retried later.
- `lib/presentation/screens/training_screen.dart`: added a retry action for local classifier checkpoint loading, separate from the dataset-driven training action.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (classifier output consistency)

- `lib/python/mudabbir_python_engine.dart`: the linear sparse classifier now supports a validated output-class count while preserving the default ten-class compatibility path for existing callers/checkpoints.
- `lib/services/on_device_training_service.dart`: the three supported supervised labels train a three-output classifier instead of a ten-output head with seven unused categories.
- `lib/presentation/screens/training_screen.dart`: prediction results map indices 0–2 to the three supported labels and safely handle missing/non-finite confidence values.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (classifier initialization status)

- `lib/presentation/providers/training_provider.dart` and `lib/presentation/screens/training_screen.dart`: the model checkpoint check now exposes an initialization state, avoids offering a duplicate retry while a check is in flight, and displays a distinct progress message.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (search-to-Mushaf context)

- `lib/presentation/screens/advanced_search_screen.dart`: opening a search result now passes the exact surah and ayah to the canonical Mushaf in addition to the page, so the target verse can be highlighted and shared Quran context updated.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local activity data integrity)

- `lib/services/local_activity_summary_service.dart`: fallback values remain available if a local metric store fails, but the summary now records explicit warnings instead of silently presenting fallback zeroes as complete data.
- `lib/presentation/screens/community_screen.dart`, `challenges_screen.dart`, and `leaderboard_screen.dart`: render a visible partial-data warning when one or more local activity sources could not be read. The leaderboard remains explicitly local-only and does not fabricate community rankings.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (seven-day metric semantic correction)

- Follow-up source inspection found that the legacy `getPagesReadInLast7Days()` method actually counted distinct reading days, not pages. Added the accurately named `getReadingDaysInLast7Days()`, retained the old name as a deprecated compatibility alias, and updated `stats_screen.dart` to display “أيام القراءة آخر 7 أيام” with day units. This supersedes the earlier inventory note that described the metric as pages.
- No tests, analyzer, formatter, or APK build were run.


- Additional correction in `lib/services/reading_progress_service.dart`: total reading days are now counted as distinct dates so duplicate legacy preference entries cannot inflate the summary.


- `ReadingProgressService.getReadingDaysInLast7Days()` now derives the seven-day window from local calendar midnights, avoiding duration-based date drift around daylight-saving transitions.


## UI continuation — 2026-10-29 (achievement persistence integrity)

- `lib/services/achievements_service.dart`: achievement progress is no longer reset from fallback zeros when the corresponding local pages/bookmarks store could not be read. Streak progress is refreshed only after the streak store initializes successfully.
- No tests, analyzer, formatter, or APK build were run.


- `lib/presentation/screens/player_profile_screen.dart`: streak, achievement refresh, and local checkpoint restoration are now attempted independently so a failure in one subsystem does not prevent the others from loading.


## UI continuation — 2026-10-29 (advanced search concurrency)

- `lib/presentation/screens/advanced_search_screen.dart`: generation tokens now prevent an older overlapping search or index load from overwriting a newer request. Clearing the query cancels the relevance of any pending search result, and empty-query handling clears the active searching state.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (reading activity integrity)

- `lib/presentation/screens/quran_page_screen.dart`: reading-streak activity is recorded only after the source-correction step leaves usable verse data, not merely because the raw JSON value was a non-empty list.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (activity-screen recovery)

- `community_screen.dart`, `challenges_screen.dart`, and `leaderboard_screen.dart` now keep their local summary request in state and provide an actual retry action after load failures, instead of asking users to reopen the screen manually.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (bookmark reference validation)

- `lib/services/bookmark_service.dart`: bookmark insertion and restoration now validate verse references against the bundled QCF/Hafs source, rejecting positive-but-out-of-range ayah numbers that could otherwise crash page navigation from Favorites.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (camera lifecycle cleanup)

- `lib/presentation/screens/device/gaze_tracking_screen.dart`: camera/detector release errors are isolated so one native resource cannot prevent cleanup of the other. Initialization now catches failures from pre-initialization cleanup and disposes partially initialized resources on failure or lifecycle cancellation.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (reading statistics integrity)

- `lib/services/reading_progress_service.dart`: reading-day history now filters malformed calendar keys, impossible dates, duplicates, and future dates before counting or recalculating streaks. Writes normalize legacy history to a canonical sorted list so corrupt entries cannot inflate all-time reading-day statistics.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (immersive Quran reading)

- `lib/presentation/screens/quran_page_screen.dart`: double-tap now synchronizes the reader chrome with Android immersive system-bar visibility, and system bars are restored on exit. Platform failures are handled without breaking the reader.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local profile persistence)

- `lib/services/multi_user_service.dart`: the active local profile is restored from persisted preferences rather than always resetting to profile zero. Profile switching now updates in-memory state only after the active index is saved; adding profiles and awarding XP persist candidate state before publishing it, report storage failures, and bound the profile count/name length.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local AI search navigation)

- `lib/presentation/screens/ai_advanced_screen.dart`: local TF-IDF search results are now actionable and open the exact verse in the canonical Mushaf with verse context/highlight, rather than leaving results as read-only snippets.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (classifier dataset correctness)

- `lib/services/labeled_training_dataset_service.dart` and `lib/services/on_device_training_service.dart`: dataset validation now requires at least two samples for each of the classifier's three output classes (`cosmic`, `tranquil`, `calculation`). A dataset missing one class can no longer silently train a three-output classifier without examples for that output.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (numerical occurrence navigation)

- `lib/presentation/screens/miracles_screen.dart`: counted word occurrences are now displayed as tappable reference chips that open the exact surah/ayah in the canonical Mushaf. The displayed counts remain literal, normalized local text counts and are not presented as proof of a theological claim.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (profile checkpoint transparency)

- `lib/services/cloud_sync_service.dart` and `lib/presentation/screens/player_profile_screen.dart`: corrected the misleading “local checkpoint saved” message. The current service records only a timestamp; it does not snapshot app data or synchronize it. The UI now says so explicitly, and a failed SharedPreferences write no longer reports success.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (agent memory persistence)

- `lib/services/agent_memory_service.dart`: recent-run reads now handle non-positive limits safely; malformed legacy JSON/maps are treated as an empty recoverable store; failed writes to run history or the knowledge vault now raise explicit persistence errors instead of being silently reported as success.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (comparison source recovery)

- `lib/presentation/screens/compare_screen.dart`: canonical Quran corpus loading now exposes a retry action and resets loading/error state before a retry, instead of leaving the comparison screen on an unrecoverable error message.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (profile state integrity)

- `lib/services/multi_user_service.dart`: callers now receive an immutable snapshot of the active profile, preventing UI consumers from mutating in-memory profile data without going through the persistence-aware service methods.
- No tests, analyzer, formatter, or APK build were run.


- The comparison screen also distinguishes an empty local corpus from a malformed user reference, avoiding a misleading prompt to correct references when no verses were loaded.


## UI continuation — 2026-10-29 (Arabic search normalization)

- `lib/presentation/screens/advanced_search_screen.dart`: text matching now removes the complete Arabic combining-mark range and tatweel, rather than a partial hard-coded subset, while keeping normalization separate from canonical verse text.
- No tests, analyzer, formatter, or APK build were run.


- `AIAdvancedScreen` now reports an empty local Quran corpus as an indexing failure and exposes the existing retry action rather than presenting a ready-but-empty search index.


## UI continuation — 2026-10-29 (profile recovery)

- `lib/services/multi_user_service.dart`: persisted local profile records are normalized on load, malformed name/avatar/level/XP/date fields receive safe defaults, and legacy profile lists are bounded to 20 entries so a damaged preference cannot crash the profile screen.
- No tests, analyzer, formatter, or APK build were run.


- `QuranIndexScreen` now renders an explicit no-match state when the surah search returns zero results instead of an empty list area.


## UI continuation — 2026-10-29 (P2P advertising failure path)

- `lib/presentation/screens/sovereign_hub_screen.dart`: starting nearby-device advertising now catches plugin/permission exceptions and displays the failure in the hub status area instead of leaking an asynchronous UI error.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (agent console recovery)

- `lib/presentation/screens/agents/agent_console_screen.dart`: added an explicit retry action to the knowledge-readiness panel when local Quran/knowledge initialization fails. The retry invokes the existing provider/runtime path rather than creating a second service instance.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local journal resilience)

- `lib/presentation/screens/cosmic_services_screen.dart`: malformed legacy journal JSON is isolated to its own record set so it does not prevent the other local services from loading; the screen surfaces a recovery warning. Dream-note saves now check the storage API's boolean result before reporting success.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (time capsule storage integrity)

- `lib/services/time_capsule_service.dart`: capsule writes are serialized to prevent concurrent read-modify-write loss; the storage write result is checked; stored records are validated and bounded before being exposed to the UI.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (settings persistence resilience)

- `lib/presentation/providers/theme_provider.dart`: preference loading now falls back to safe defaults with a retained error state, theme/font writes are serialized using state snapshots, and storage failures no longer escape as unhandled asynchronous errors.
- `lib/presentation/screens/settings/settings_screen.dart`: displays the provider's local preference load/save error so an in-memory setting change is not mistaken for a successfully persisted preference.
- No tests, analyzer, formatter, or APK build were run.


- Successful subsequent theme persistence now clears a previously displayed storage warning and notifies settings listeners, so recovered storage state is reflected in the UI.


## UI continuation — 2026-10-29 (gaze calibration persistence)

- `lib/services/gaze_fusion_service.dart`: calibration parameters become active in memory only after all preference writes succeed; partial writes trigger best-effort cleanup and an explicit failure. Reset clears persisted values before resetting active calibration state.
- `lib/presentation/screens/device/gaze_tracking_screen.dart`: calibration-reset persistence failures are shown to the user instead of escaping from the button callback.
- No tests, analyzer, formatter, or APK build were run.


- `customize_screen.dart` also displays the shared theme provider's preference persistence warning, so failures are visible on the screen where palette/font/size changes are made.


## UI continuation — 2026-10-29 (search reload state)

- `lib/presentation/screens/advanced_search_screen.dart`: reloading the local Quran index clears the previous “searched/no results” state along with stale results, so the refreshed screen no longer implies a search was performed when it was not.
- No tests, analyzer, formatter, or APK build were run.


- Settings reset feedback now distinguishes an in-memory reset from a reset whose local persistence succeeded, avoiding a false success claim after storage errors.


## UI continuation — 2026-10-29 (agent cancellation)

- `lib/presentation/providers/agent_chat_provider.dart`: asynchronous native generation-stop failures during explicit task cancellation are now caught and logged, so a plugin/runtime stop error cannot become an unhandled future while the provider marks the task cancelled.
- No tests, analyzer, formatter, or APK build were run.


- Theme preference loading now uses a revision guard so a slow startup read cannot overwrite palette/font changes made by the user before the read completes.


## UI continuation — 2026-10-29 (profile initialization race)

- `lib/services/multi_user_service.dart`: concurrent profile initialization requests now share one in-flight load, preventing competing default-profile writes or partially published active-profile state.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (optional Quran script assets)

- `lib/presentation/screens/quran/quran_pro_screen.dart`: loading the canonical Arabic Quran no longer depends on successful loading of the optional standalone Musnad and hieroglyphic datasets. Each optional dataset failure is disclosed, and the reader falls back to its local display transformation instead of blocking all Quran reading or rendering empty verses.
- No tests, analyzer, formatter, or APK build were run.


- Follow-up performance refinement: `QuranProScreen` now opens the canonical Quran immediately after its required asset loads and parses the optional script datasets in the background, so a slow variant parse does not delay ordinary reading.


## UI continuation — 2026-10-29 (Mushaf theme persistence)

- `lib/services/quran_page_theme_service.dart` now propagates rejected local writes rather than silently ignoring them. `lib/presentation/screens/quran/mushaf_screen.dart` restores the previous selected theme and reports the error if persistence fails, instead of closing the picker as though the change were saved.
- No tests, analyzer, formatter, or APK build were run.


- `QuranProScreen` now retains canonical-load failures as an explicit recoverable UI state with a retry action instead of showing a snackbar over an empty reader.


- `QuranWordExplorerScreen` now offers a retry action when local word/letter index loading fails and resets the loading/error state before retrying.


## UI continuation — 2026-10-29 (word/letter explorer navigation)

- `lib/presentation/screens/quran_word_explorer_screen.dart`: each indexed word can open its exact verse in the canonical Mushaf; matching occurrences in the word-location sheet are also directly navigable, preserving the verse reference and page.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (knowledge exploration achievement)

- `lib/presentation/screens/occult_explorer_screen.dart` now records a knowledge topic when its detail panel is opened. `lib/services/achievements_service.dart` labels the milestone as seven distinct knowledge topics rather than claiming seven scientific disciplines; progress comes from distinct saved topic identifiers.
- No tests, analyzer, formatter, or APK build were run.


- The word-location sheet now caps eager result rendering at 100 occurrences and reports the total number of matches, preventing common words from creating thousands of widgets at once.


- `QuranProScreen` now rejects an empty/missing Fatiha verse list as invalid canonical data and routes the failure to its retryable error state rather than opening a blank reader.


## UI continuation — 2026-10-29 (numerical analysis corpus validation)

- `lib/services/quran_numerical_analysis_service.dart`: numerical word-count analysis now validates that the local source contains all 114 surahs with canonical verse counts and non-empty text for every verse before publishing statistics. A partial/corrupt corpus fails explicitly rather than yielding plausible-looking partial counts.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local audio stop failures)

- `lib/presentation/screens/occult_explorer_screen.dart`: explicit audio-stop actions now report plugin failures, and dispose-time stop futures are caught to avoid unhandled asynchronous errors while leaving the screen.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (conversation-memory recovery)

- `lib/services/context_memory_service.dart`: persisted conversation rows are validated and bounded when loaded, malformed legacy records no longer poison the memory index, and rejected local writes raise an explicit persistence error while the existing queue remains recoverable.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (profile mutation ordering)

- `lib/services/multi_user_service.dart`: profile creation, switching, and XP updates now share a serial mutation queue. Concurrent UI actions no longer race through read-modify-write cycles and overwrite one another; avatar input is bounded and XP arithmetic is capped to the supported persisted range.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (Quran bookmarks integrity)

- `lib/services/bookmark_service.dart`: bookmark storage is capped at 500 entries, and saved verse previews are now sourced from the bundled Quran verse lookup rather than trusting caller-provided display text. Duplicate references remain replaceable at the limit.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (achievement event concurrency)

- `lib/services/achievements_service.dart`: Abjad calculations, distinct knowledge-topic visits, and completed insight counters now serialize their local read-modify-write events to avoid dropped increments or overwritten topic sets during rapid/concurrent UI actions.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (reading progress source recovery)

- `lib/services/reading_progress_service.dart` contained a truncated regular-expression line and duplicated method bodies inside `_readValidDays`, leaving the source syntactically malformed. The service was reconstructed with one valid implementation for bounded page positions, unique page/day sets, calendar-date validation, current streak, and seven-day reading counts. Future dates and impossible date strings are excluded.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local classifier diagnostics)

- `lib/presentation/providers/training_provider.dart` exposes the underlying local model initialization error without replacing it with a fabricated success state. `lib/presentation/screens/training_screen.dart` displays that diagnostic next to the classifier status and retains the explicit retry action.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (streak metric source alignment)

- `lib/services/achievements_service.dart` now derives the three-day streak achievement from `LocalActivitySummaryService`, which reads the same persisted reading-day ledger as the reading statistics. This removes the previous mismatch where the achievement depended on a separate streak store that was not necessarily updated by page navigation.
- No tests, analyzer, formatter, or APK build were run.


## UI continuation — 2026-10-29 (local profile management UI)

- `lib/presentation/screens/player_profile_screen.dart` now initializes local profile storage before rendering and exposes actual profile creation and switching backed by `MultiUserService`. The screen explains that these are device-local profiles, not authenticated accounts or cloud sync; storage failures are surfaced to the user.
- No tests, analyzer, formatter, or APK build were run.


- Profile selection now uses the persisted active index rather than comparing profile names/timestamps, so duplicate names cannot cause the wrong row to appear selected.


- `PlayerProfileScreen` now reads its streak and seven-day dots from the same canonical reading-progress ledger used by statistics and achievements, rather than a separate store that could remain empty while page reads were recorded.


## UI continuation — 2026-10-29 (canonical Quran source immutability)

- `lib/services/quran_service.dart` now checks all 114 surah keys and each canonical verse count, not only the aggregate 6,236 total. After source corrections, the cached Quran map, each surah list, and each verse record are exposed as immutable snapshots to prevent one screen from mutating shared scripture data.
- No tests, analyzer, formatter, or APK build were run.


- `QuranService.loadQuran()` now shares a single in-flight parse/validation across concurrent screens and clears the failed in-flight future so a later retry can recover from asset-read or validation errors.


- `ReadingProgressService.recordReadingDay()` now records a calendar-day event without fabricating a page number, and `DailyStreakService` synchronizes activity into that canonical ledger. Surah-based reading, profile streaks, statistics, and achievements can therefore share real day activity even when a reader does not track a page position.


## UI continuation — 2026-10-29 (shared dream journal integration)

- `lib/services/dream_journal_service.dart` and `lib/presentation/screens/cosmic_services_screen.dart` now share one schema and storage key for the local dream journal. The screen delegates loading and writes to the service; records remain bounded and validated, and no guessed Quran verse or dream interpretation is attached.
- No tests, analyzer, formatter, or APK build were run.


- `TimeCapsuleService.sealCapsule` rejects unlock timestamps that are not in the future, so callers cannot create a capsule that is already unlocked by construction.


- Time-capsule migration now uses a dedicated legacy-import path that retains previously saved capsules whose unlock date has already passed, while the normal creation path still requires a future unlock date. Migration remains idempotent and preserves the old key if import fails.


- `DailyStreakService` now prunes malformed date strings, timestamps that are not canonical calendar-day keys, future activity, and records older than its retention window before calculating streaks.


- Follow-up source-integrity repair: `lib/services/daily_streak_service.dart` was reconstructed after a malformed date-pattern edit had split the method body. Date validation now uses canonical parse-and-round-trip checks without a fragile inline regex; the service retains serialized activity writes and shared reading-ledger synchronization.


- The local dream journal now supports deleting an individual saved note through `DreamJournalService.removeDream`; the UI reloads persisted entries after deletion and reports storage failures rather than removing only the visible row.


- Time capsules now have a persisted deletion path in `TimeCapsuleService.removeCapsule` and a delete control in the capsule list. Users can free local capacity without clearing the entire store.


- Legacy capsules without IDs now receive deterministic IDs derived from their content and unlock timestamp, so their delete controls continue to target the same record after a reload.


- Local profile avatar values are trimmed and bounded before persistence, matching the validation already applied to profile names and numeric progress.


- `QuranPageScreen` now validates the selected surah number, canonical expected verse count, every source verse text, and the post-correction count before displaying it. An incomplete asset enters the existing retryable error state rather than being presented as a complete surah.


- `QuranMultiModeScreen` now applies the same canonical per-surah count/text validation as the standard surah reader, verifies that correction preserves the verse count, and exposes retry when the local asset is missing or incomplete.


- Persisted profile normalization now rejects non-finite level/XP values before integer conversion, preventing malformed numeric JSON from discarding the entire local profile list.


- Advanced Quran search normalization now strips both Arabic combining diacritics and the extended Quranic annotation-mark range in addition to tatweel, while leaving displayed/canonical verse text untouched.


- The shared `QuranService` search normalization now uses the same extended Arabic/Quranic combining-mark ranges as the advanced search screen, keeping single-token and phrase-search normalization consistent.


- `QuranService.getSurahs()` now uses the canonical verse-count table from `QuranLoaderService` instead of maintaining a second hard-coded 114-entry list.


- Numerical corpus validation is now scoped to `analyzeAsset()`, which validates the actual bundled 114-surah asset before calculating. The reusable `analyzeJson()` entry point continues to support small supplied datasets for reproducible unit-level calculations instead of incorrectly requiring every caller to provide a full Mushaf.


- Numerical analysis results now label their source accurately: bundled-asset calculations identify `assets/unified_quran.json`, while caller-supplied JSON defaults to `provided JSON`.


- Legacy capsule migration now isolates capacity/storage failures, still loads the already-migrated capsule list, surfaces a warning, and keeps the legacy source for an idempotent retry rather than blocking the entire services screen.


- The searchable More directory now strips the extended Arabic combining-mark range as well as tatweel, aligning its Arabic query normalization with the Quran search surfaces.


- Surah-index search now removes the same extended Quranic mark range while retaining Arabic/Persian digit normalization and canonical surah names.


## Knowledge interface continuation — 2026-10-29

- `AIAdvancedScreen`: search scores are now labeled as relative lexical similarity scores, not percentages of correctness. Its limited local notes are explicitly described as fixed summaries rather than sourced tafsir text or AI-generated interpretation.
- `TafsirGeneratorService`: missing-entry errors no longer call the limited local dataset “verified”.
- `AgentConsoleScreen`: registry count is labeled as registered definitions, not a count of independent running agents; the UI explains this distinction and describes local retrieval as an indexed knowledge source rather than “verified” search.
- No tests, analyzer, formatter, or APK build were run.


- `AbjadCalculatorScreen` no longer records a calculation achievement when input contains Arabic-block characters but no letters recognized by the Abjad table.
- `StatsScreen` now labels the numerator as distinct pages visited and the percentage as page coverage. It no longer declares a khatmah complete merely because 604 unique page numbers were stored; sequential completion is not represented by this ledger.


- Arabic search consistency: `NucleusScreen` now uses the shared agent-knowledge normalizer for agent name/ID/layer/description queries, and `CompareScreen` removes the extended Quranic annotation marks before lexical-overlap comparison. Neither operation mutates canonical verse text.


- Opening a knowledge-domain detail in `NucleusScreen` remains successful even if the optional local achievement write fails; the screen now reports the persistence failure instead of leaving an unhandled asynchronous error.


- `AIAdvancedScreen` clears stale results when rebuilding its Quran index and refuses to run a search when the latest index load failed, rather than silently searching an old in-memory index.


- `LocalEmbeddingsService` lexical normalization now strips extended Arabic/Quranic combining marks, matching the other knowledge-search surfaces without changing the source text displayed in results.


- `DivineNamesScreen` search now strips the extended Arabic/Quranic annotation range. `ElementsScreen` presents the four classical elements as historical classifications and identifies “spirit” as an additional symbolic/philosophical idea rather than a fifth scientifically established element.


- `DailyVerseScreen` now guards an empty local corpus before computing the daily index, and bookmark reads/writes verify the currently displayed verse before changing its visual state. Rapidly advancing to another verse can no longer apply a stale bookmark result to the new verse.


- `DivineNamesScreen` now displays an explicit empty-search state rather than an unexplained blank grid. Reading statistics also identify page coverage against the total Mushaf page count.


- `TrainingScreen` loss-chart rendering now skips non-numeric and non-finite persisted history entries instead of casting malformed local values during paint.


- The training import instructions now explicitly require examples for all three classifier classes, with at least two samples per class, matching the trainer's actual validation rather than implying absent classes are acceptable.


- `GreatVersesScreen` now passes the selected surah and ayah as well as the page to the Mushaf, so opening a featured verse targets its exact reference instead of only its containing page.
- `TrainingScreen` displays all three required classifier labels, including zero counts for missing classes, so dataset deficiencies are visible before training.


- `AbjadCalculatorScreen` now bounds input length and shows the value assigned to each recognized letter alongside the total, rounded mean, and half-total. This makes the arithmetic traceable instead of presenting only the final numbers.


- `GreatVersesScreen` now treats an empty Quran index as a recoverable load error instead of rendering a list of unavailable featured references.


- `DailyVerseScreen` now derives its stable daily selection from UTC calendar days since a fixed epoch, cycling through the full local Quran corpus instead of repeating only the first ~365 entries each year.


- The last-reading-position card in `StatsScreen` is now actionable and opens the Mushaf at the stored page without overriding it with the previous session's restored page.


- `AIAdvancedScreen` now distinguishes unsupported GGUF/Qwen fine-tuning from the separate, available local linear-classifier training workflow, avoiding the impression that no local training path exists.


- The elements screen now labels its relation table as tradition-dependent conceptual symbolism and replaces the unsupported “spirit animates everything” statement with a bounded symbolic association to life.


- Daily-verse rotation now derives the date from the actual UTC instant before day arithmetic, making the same calendar-day selection independent of the device time zone.


- The shared `QuranicSearchEngine` now strips the same extended Arabic/Quranic mark range as the other local search services, improving query consistency across agent retrieval and Quran search without altering stored verses.


- `QuranicSearchEngine` now resolves equal-score matches by original canonical corpus order, making local retrieval ordering deterministic rather than dependent on sort behavior for ties.


- Training prediction output now labels the softmax value as an uncalibrated score rather than calibrated confidence, avoiding overstating what the local classifier's numeric output establishes.


- `TafsirGeneratorService` now documents at the service boundary that its small fixed text set is not a sourced tafsir database and must not be presented as quoted or verified exegesis.


- The agent-console Abjad handler now uses `AbjadConstants`, the same table as `AbjadCalculatorScreen`, removing a duplicate mapping that disagreed on values such as ta marbuta and could produce different totals for the same text.


- `AgentKnowledgeService.normalize` now normalizes hamza-on-waw/yaa consistently with the Quran search index and local lexical retrieval, reducing mismatches between the same Arabic query across knowledge sources.


- The daily-verse bookmark indicator resets when the selected verse changes, preventing the previous verse's saved state from being shown while the new reference is checked.


- `AgentKnowledgeService` now rolls back documents added during an asset load if decoding or schema collection fails, and does not list that asset as loaded. Malformed optional sources therefore cannot leak partial records into later searches; the required knowledge asset still fails initialization when unavailable or unusable.


- `AgentKnowledgeService.search` now uses deterministic tie-breakers (source, title, then content) after its lexical score, so repeated identical queries return a stable ordering when several documents score equally.


- `AgentKnowledgeService.search` now returns an empty immutable result immediately for blank queries or nonpositive limits, avoiding unnecessary initialization and invalid take limits.


- `AgentKnowledgeService.initialize` now reuses a successfully initialized index and preserves single-flight ordering for concurrent callers. Repeated searches no longer append another full Quran corpus to the in-memory knowledge list each time.


- `CompareScreen` now normalizes hamza-on-waw/yaa like the shared lexical search services before computing unique-word overlap, so comparisons and searches apply the same variant handling.
