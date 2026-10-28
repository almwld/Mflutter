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

## Next implementation order

1. Complete a route/reachability map for `main.dart`, `SplashScreen`, `HomeScreen`, and `MainNavigation`.
2. Establish an explicit mapping from the 23 target screens to existing files, including duplicates, partial implementations, and genuinely missing screens.
3. Add shared design tokens and only the reusable templates justified by real screen needs.
4. Replace unsupported fixed numerical claims with a transparent calculation/data model and tests.
5. Improve the Nucleus graph using registry metadata and actual runtime state, without fabricating active agents.
6. Improve Quran-page interactions while protecting source text.
7. Run format, analyze, tests, and Android CI after each logical change group.

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

The changes have been committed to the audit branch. CI and local Flutter commands have not yet been confirmed for this feature slice; do not treat the tests as passing until the workflow result is inspected.


## Target-screen mapping (verified filename-level mapping)

| # | Target | Current implementation / status |
|---:|---|---|
| 1 | SplashScreen | `lib/presentation/screens/splash_screen.dart` |
| 2 | MainNavigation | `lib/presentation/screens/main_navigation.dart`; now a compatibility adapter to canonical `HomeScreen` |
| 3 | ChatScreen | `lib/presentation/screens/chat/chat_screen.dart` is the main HomeScreen destination; a second legacy `chat_screen.dart` also exists and needs follow-up review |
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
