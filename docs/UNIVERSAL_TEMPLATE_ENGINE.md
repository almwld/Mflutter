# Universal Dynamic Template Engine

The renderer is a presentation layer. It does not infer missing facts or calculate
metrics. Domain services provide computed values in `data_payload`. The one deliberate
read-only exception is `quran_verse`: it carries only a canonical surah/ayah reference,
and the renderer loads that exact verse from `QuranLoaderService` rather than trusting
payload text. Missing or unsupported data is rendered as an explicit empty/error state.

## Contract

```json
{
  "ui_template": "analytics_template",
  "schema_version": 1,
  "domain": "quran",
  "title": "تحليل موثق",
  "empty_message": "لم تُرجع خدمة التحليل بيانات.",
  "blocks": [
    {"type": "metric", "title": "عدد النتائج", "value": 12},
    {"type": "bar_chart", "title": "التوزيع", "items": [
      {"label": "الفئة أ", "value": 3},
      {"label": "الفئة ب", "value": 9}
    ]}
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
