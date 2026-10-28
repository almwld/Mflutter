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

No file named `quran_bookmarks_screen.dart` appears in the inspected candidate list. Before creating a new screen, inspect existing favorites/bookmark/progress services to avoid duplicate storage and overlapping functionality.

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
