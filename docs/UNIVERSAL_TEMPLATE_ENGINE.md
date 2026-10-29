# Universal Dynamic Template Engine

The renderer is a presentation layer. It does not query services, infer missing facts,
or manufacture Quran text, astronomical measurements, counts, or agent health values.
The caller must obtain values from the relevant local/domain service and pass them in
`data_payload`. Missing or unsupported data is rendered as an explicit empty state.

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
- `quran_verse`: `title`, `text` supplied by the canonical Quran service
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
    {"type": "quran_verse", "title": "النص العثماني", "text": "<canonical verse text from QuranLoaderService>"},
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
empty/error state. Keep domain computation and data access outside the renderer.

## Current live integrations

The agent provider now creates schema blocks from these local sources for matching
explicit requests:

- **Quran word count**: loads the canonical corpus through `QuranLoaderService`,
  applies `QuranicSearchEngine.normalize`, counts exact normalized word tokens, and
  lists the actual surah/ayah references. This is lexical token counting, not root analysis.
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
