# Universal Dynamic Template Engine

The renderer is a presentation layer. It does not infer missing facts or calculate
metrics. Domain services provide computed values in `data_payload`. The one deliberate
read-only exception is `quran_verse`: it carries only a canonical surah/ayah reference,
and the renderer loads that exact verse from `QuranLoaderService` rather than trusting
payload text. Missing or unsupported data is rendered as an explicit empty/error state.

## Contract

```json
{
  "template_id": "universal_dynamic_canvas",
  "schema_version": 1,
  "metadata": {
    "title": "لوحة ديناميكية",
    "subtitle": "ملخص مجال محدد",
    "topic_category": "Science",
    "source": "VerifiedLocalService",
    "generated_at": "2026-10-29T00:00:00Z"
  },
  "blocks": [
    {"type": "metric", "title": "عدد النتائج", "data": {"value": 12}},
    {"type": "timeline_block", "title": "المراحل", "data": {
      "events": [{"label": "مرحلة موثقة", "date": "2026-10-29"}]
    }}
  ]
}
```

## Supported atomic blocks

- `text`: `title`, `text`
- `quran_verse`: `title`, integer `surah_number`, integer `ayah_number`; the renderer loads the verse text from `QuranLoaderService` and rejects payload-supplied `text`
- `metric`: `title`, `value` supplied by a service
- `section`: `title`, optional `text`, or nested `children`
- `list`: `title`, `items: string[]`
- `table`: `title`, `columns: string[]`, `rows: string[][]`
- `bar_chart`: `title`, `items: [{label: string, value: number}]`
- `status`: `title`, `status`, `message` supplied by the service being monitored
- `hero_header_block`: optional `subtitle`
- `timeline_block`: bounded `events: [{label, date?, details?}]`
- `relation_graph_block`: bounded `nodes: [{id, label}]` and `edges: [{from, to}]`
- `star_map_block`, `vector_space_block`, `spatial_map_block`: up to 250 normalized `points/stars: [{x, y, label?}]`
- `quantum_particle_block`: normalized `particles: [{x, y, label?}]` and optional index-pair `links`
- `code_math_block`: `expression` and optional `explanation`
- `audio_frequency_block`: 2–512 normalized `samples` in [-1, 1], optional source-provided `frequency_hz`
- `interactive_card_block`: `front`, `details`

The renderer accepts either legacy flat block fields or the extensible `{type, title, data}` form. `style_hints` is discarded; the model cannot override app theme colors or widget styling. The payload is bounded to 300 top-level blocks, 200 timeline events, 250 graph nodes/coordinate points, and 500 graph edges/list items. Unknown block types fail closed. Add a new block only by implementing its validator and renderer, then cover it with tests.

## Domain payload examples

These are contract examples, not built-in data or default results. Replace the marked
values only with service results before rendering.

### Quran reader

```json
{
  "ui_template": "reader_template",
  "schema_version": 1,
  "domain": "quran",
  "title": "الآية المطلوبة",
  "blocks": [
    {"type": "quran_verse", "title": "النص العثماني", "surah_number": 2, "ayah_number": 255},
    {"type": "section", "title": "تحليل لغوي", "children": [
      {"type": "text", "title": "الجذر", "text": "<verified root result from a lexical service>"}
    ]}
  ]
}
```

### Numerical analysis

```json
{
  "ui_template": "analytics_template",
  "schema_version": 1,
  "domain": "quran_analytics",
  "title": "نتائج العدّ",
  "blocks": [
    {"type": "metric", "title": "التكرار", "value": "<integer returned by QuranNumericalAnalysisService>"},
    {"type": "table", "title": "المقارنة", "columns": ["المعيار", "القيمة"], "rows": [["<label>", "<service result>"]]}
  ]
}
```

### Cosmic / planetary information

```json
{
  "ui_template": "cosmic_template",
  "schema_version": 1,
  "domain": "astronomy",
  "title": "خصائص جرم سماوي",
  "blocks": [
    {"type": "metric", "title": "نصف القطر", "value": "<verified measurement and unit>"},
    {"type": "list", "title": "مصادر البيانات", "items": ["<source name and version>"]}
  ]
}
```

### Abjad calculation

```json
{
  "ui_template": "abjad_template",
  "schema_version": 1,
  "domain": "abjad",
  "title": "حساب الجُمّل",
  "blocks": [
    {"type": "metric", "title": "المجموع", "value": "<result returned by AbjadCalculator>"},
    {"type": "table", "title": "تفصيل الحروف", "columns": ["الحرف", "القيمة"], "rows": [["<letter>", "<calculated value>"]]}
  ]
}
```

### Nucleus and agents

```json
{
  "ui_template": "graph_template",
  "schema_version": 1,
  "domain": "nucleus",
  "title": "حالة النواة",
  "blocks": [
    {"type": "status", "title": "الخدمة", "status": "<live service status>", "message": "<actual diagnostic message>"},
    {"type": "list", "title": "مسار التنفيذ", "items": ["<real event from the execution log>"]}
  ]
}
```

## Adding a template module

Register a new identifier with `TemplateRegistry.register(id, builder)`. Builders should
compose the shared atomic blocks and use `MudabbirDesignTokens` for styling. Registration
rejects duplicate or blank identifiers. Unknown template ids fail closed into an explicit
empty/error state. Keep calculations and general domain data access in services; the
renderer may only perform the bounded canonical Quran reference lookup described above.

## Current live integrations

The agent provider now creates schema blocks from these local sources for matching
explicit requests:

- **Quran word count**: loads the validated local corpus through `QuranLoaderService`, indexes that corpus in `QuranicSearchEngine`, then uses `countExactWord` to return exact normalized-token occurrences and unique numeric verse references. It supports explicit single-word and paired-word comparisons. Unrecognized numerical requests that would otherwise route to the legacy numerical screen fail closed with a visible error status rather than a numeric guess. This is lexical token counting, not root analysis.
- **Abjad**: uses `AbjadConstants.normalizeArabic`, `calculateTotal`, and
  `abjadSquare` to show the configured arithmetic and per-letter values. It does not
  make astrological, spiritual, or predictive claims.
- **Nucleus status**: reads the live `NucleusService` initialization/error state,
  model runtime state, registered-agent count, indexed document count, and loaded sources.

If the Quran corpus fails to load, the provider surfaces the source error rather than
inventing a count. The existing generic intent routing remains as a fallback for requests
not recognized by these explicit schema handlers.

## Agent integration and remaining domains

`AgentConsoleScreen` sends payloads containing a `blocks` list to
`UniversalTemplateRenderer`. Existing agent intents without this schema keep their
current domain-screen behavior, avoiding a silent migration to blank screens.

Astronomy/planetary measurements, morphological Quran root analysis, deeper live agent
execution traces, and full migration of all legacy domain screens still require their
own real domain services and have not been implemented by these integrations.


## Strict payload contract (schema version 1)

The renderer validates the payload envelope before rendering. A payload must carry
a registered `ui_template` (or `template_id`), integer `schema_version: 1`,
and a `blocks` list. Optional `title`, `domain`, and `empty_message` values
must be strings when present. Unsupported versions and invalid envelope fields
fail closed to an explicit validation state rather than silently rendering.

The agent coordinator requires non-empty `title`, `domain`, and `source` values for service-created intents. The renderer also accepts legacy/direct payloads with omitted `source`, but validates it as a non-empty string when present. It preserves supplied provenance and displays it in the template header. Source labels are descriptive metadata, not independent proof that a claim is true. Block and nested-block maps with non-string keys are rejected safely instead of causing a parser exception.

Atomic blocks are validated by type before they reach widgets:
- `text`: non-empty text.
- `quran_verse`: numeric surah/ayah reference only; arbitrary payload text is rejected, and the widget resolves the displayed text from the canonical local Quran corpus. A failed lookup displays an error state without substitute text.
- `metric`: a non-null primitive value (string, number, or boolean).
- `section`: string text and recursively valid children, with a bounded nesting depth.
- `list`: a list of strings.
- `table`: non-empty string columns and rows with simple cells matching column count.
- `bar_chart`: items with string labels and numeric values.
- `status`: optional string status/message fields.

Malformed blocks are excluded individually, and the UI displays validation details
alongside any remaining valid blocks. The registry includes the actual service
templates used by local integrations: `analytics_template`, `abjad_template`,
and `graph_template`. These checks validate presentation shape only; they do not
establish the truth of the underlying data, which remains the responsibility of
the domain service and its source metadata.


## Integrity and runtime guarantees

### Quran text is reference-based, not model-authored

A `quran_verse` block carries only a surah number and ayah number. The schema rejects a `text` field on that block, and the renderer obtains the displayed verse from `QuranLoaderService.loadAllAyahs()`. If the local corpus fails to load or the reference is absent, the renderer shows a quiet error/empty state and does not display model-provided substitute text. Search normalization is used for matching/counting only; it does not rewrite the stored verse text.

### No fabricated counts

`QuranicSearchEngine.countExactWord` returns a result only when the local index is ready and the query normalizes to one token. A verified zero is represented as zero; an unavailable/invalid query is represented by `null`. The provider converts that unavailable result or a corpus/index exception into an explicit status block. Counts are exact normalized lexical-token counts, not roots or semantic occurrences.

### Local and lightweight by design

The renderer uses local widgets, bounded nested sections, and repaint boundaries rather than video or remote rendering. This architecture reduces avoidable work, but it does not itself prove a sustained 60+ FPS on every device. Frame pacing and memory must be measured on target devices before making a performance guarantee.

These controls provide defined failure behavior; they do not constitute a claim of absolute or mathematically perfect safety. The canonical corpus, loader validation, and device-level verification remain important parts of the trust boundary.


## Universal canvas and specialist template identifiers

The registry now accepts the universal canvas identifier and the requested specialist aliases:

- `universal_dynamic_canvas`
- `dashboard_template`, `reader_template`, `chat_template`, `library_template`
- `analytics_template`, `graph_template`, `player_template`, `settings_template`
- `search_template`, `profile_template`, `lab_template`, `service_hub_template`
- `cosmic_celestial_template`, `quantum_mesh_template`, `vector_embedding_template`
- `dream_journal_template`, `sovereign_ar_iot_template`

These identifiers reuse the same schema renderer and atomic block library; they are not 17 independent screen implementations. New topics can compose existing blocks without a new screen. A genuinely new visual primitive requires a code-reviewed validator/renderer implementation and registration, so the system is extensible rather than literally infinite or able to execute arbitrary model-authored UI code.

The local GGUF runtime now receives a visual-orchestration system instruction. On explicit visual requests, `AgentChatProvider` attempts to parse the model response as JSON, validates it with `TemplatePayloadSchema`, and routes it to the same renderer only if the entire envelope and every block pass validation. Model-generated payloads are restricted to `hero_header_block`, `text`, `section`, `list`, and `interactive_card_block`; numeric, Quranic, status, chart, timeline, graph, spatial, and audio blocks are rejected from this untrusted path and remain reserved for deterministic app handlers. The source label is overwritten by the application to disclose that the layout is model-generated and not independently verified. Invalid JSON stays a normal text response; it is never partially executed as a UI specification.

The current specialist visuals are deliberately honest and lightweight:

- Star and vector fields are normalized **2D coordinate visualizations**, not live astronomical observations or 3D embedding engines.
- Quantum-particle links are **illustrative topology diagrams**, not physical quantum entanglement.
- Audio waveforms depict provided samples; they do not claim to measure audio or generate a frequency.
- Relation graphs currently show labeled nodes and edge pairs in a bounded layout, not a force-directed physics simulation.
- Timeline and expandable reflection cards render only supplied text and metadata.

No astronomical ephemeris, actual P2P transport, AR camera pipeline, IoT control, or local embedding extraction is implied by registering these templates. Those capabilities must be connected to their own real services before the UI labels them as live or operational.

## Advanced component library

Reusable atomic widgets live under `lib/presentation/templates/components/`:

- `BaseUniversalBlock` supplies the shared glass surface, bounded visual styling,
  a repaint boundary, and a synchronous build-error fallback for a single block.
  It does not install global Flutter error hooks or claim to catch asynchronous,
  layout, or paint failures.
- `BlockRegistry` is an explicit allowlist and factory. Duplicate identifiers are
  rejected, and unknown component types return `null` so the caller can keep its
  existing safe renderer path.
- `MetricCardBlock` renders a service-supplied value and optional unit/description;
  it does not calculate or infer values.
- `SpatialMapBlock` uses a lightweight `CustomPainter` and normalized 2D points.
  It is a static projection, not a 3D scene, live map, or astronomical observation.
- `BlockEventBus` is instantiated once per `UniversalTemplateRenderer` and exposed
  through `BlockEventScope`; it is closed when the canvas is disposed.
- Selectable `table` rows publish `selection_changed` with a stable `selection_id`,
  source block ID, optional target block ID, row index, and display label. Use
  `row_ids` to map rows to domain IDs and `target_block_id` to route to a graph/map.
- `relation_graph_block` subscribes only to events targeting its own block ID and
  highlights the matching node. `SpatialMapBlock` similarly highlights the matching
  point by `id`, `node_id`, or `label`. Metric cards can publish the same event when
  supplied both `selection_id` and `target_block_id`.
- Haptic selection feedback is emitted by selectable table rows and metric cards.
  Subscriptions are cancelled when the receiving widget is disposed; separate
  canvases have separate buses, preventing cross-canvas event leakage.

The universal renderer now delegates metric and spatial coordinate block types to
`BlockRegistry` and assigns each top-level block an explicit `id` or deterministic
fallback ID. Event targets must match those IDs. Repaint boundaries and bounded point
counts reduce avoidable repaint work, but do not guarantee 60 FPS on every device.
Measure frame pacing and memory on representative target hardware before claiming a
frame-rate target.


## Local sensor-guided star tracker

The `star_tracker_block` is registered through `BlockRegistry` and uses
`sensors_plus` for device motion, `geolocator` only after the user requests
a location fix, and a bundled small bright-star catalog. `CelestialEngine`
calculates Julian Date, approximate Greenwich/local sidereal time, and
horizontal altitude/azimuth locally. It can publish `selection_changed` to
the canvas-scoped `BlockEventBus` when a star is tapped.

Important accuracy boundaries:

- Catalog coordinates are approximate J2000 values and do not include proper
  motion, atmospheric refraction, precession/nutation, or a precision planetary
  ephemeris.
- Magnetometer heading depends on device calibration and nearby interference;
  orientation-to-screen alignment is approximate.
- The widget is a sensor-guided sky chart, **not** a camera AR overlay and not
  a professional planetarium replacement.
- Location is optional. Without a valid observer latitude/longitude, the widget
  does not invent a location or claim that displayed positions are live.
- Sensor subscriptions and the clock timer are cancelled when the block is
  disposed. No sensor/location data is uploaded by this component.


## Adaptive selection and motion

`AdaptiveTemplateSelector` applies a deterministic presentation policy to the
requested template, domain, query, and already-validated block types. Specialist
content has priority (canonical Quran verse references, Abjad results, star-tracker,
quantum-particle, and vector-space blocks); comparison language, astronomy domains,
relationship graphs, and analytics blocks select their matching layouts. Generic
content retains the service-requested template. This selector changes presentation
only: it does not create data, calculate values, or change source provenance.

`CanvasBlockEntrance` adds a restrained opacity/vertical entrance to each
top-level canvas block. It uses Flutter's built-in animation primitives, isolates
painting with the existing repaint boundary, and renders immediately when the
operating-system reduced-motion preference is enabled. The duration is bounded and
slightly staggered by block position; no blur, shader, or continuously running
ticker is introduced. This is an interaction-quality improvement, not a claim of
measured 60 FPS performance. Device profiling is still required before publishing
frame-rate or memory guarantees.
