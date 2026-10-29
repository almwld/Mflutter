import 'package:flutter/material.dart';

import '../../core/themes/mudabbir_design_tokens.dart';

/// A small, versioned payload contract shared by agent output and UI templates.
/// Unknown or malformed blocks are ignored rather than filled with fabricated data.
class TemplatePayloadSchema {
  const TemplatePayloadSchema({
    required this.templateId,
    required this.version,
    required this.title,
    required this.blocks,
    this.domain,
    this.emptyMessage = 'لا توجد بيانات موثوقة لعرضها بعد.',
  });

  final String templateId;
  final int version;
  final String title;
  final String? domain;
  final List<Map<String, dynamic>> blocks;
  final String emptyMessage;

  factory TemplatePayloadSchema.fromMap(Map<String, dynamic> payload) {
    final rawBlocks = payload['blocks'];
    final blocks = <Map<String, dynamic>>[];
    if (rawBlocks is List) {
      for (final item in rawBlocks) {
        if (item is Map) {
          blocks.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return TemplatePayloadSchema(
      templateId: payload['ui_template']?.toString() ??
          payload['template_id']?.toString() ??
          'generic_template',
      version: (payload['schema_version'] as num?)?.toInt() ?? 1,
      title: payload['title']?.toString() ?? '',
      domain: payload['domain']?.toString(),
      blocks: List<Map<String, dynamic>>.unmodifiable(blocks),
      emptyMessage: payload['empty_message']?.toString() ??
          'لا توجد بيانات موثوقة لعرضها بعد.',
    );
  }

  bool get hasRenderableBlocks => blocks.any(TemplateBlockSchema.isSupported);
}

/// Strictly recognizes the small set of renderable atomic block types.
/// This is a presentation schema, not a data source.
abstract final class TemplateBlockSchema {
  static const supportedTypes = <String>{
    'text',
    'metric',
    'section',
    'list',
    'table',
    'quran_verse',
    'bar_chart',
    'status',
  };

  static bool isSupported(Map<String, dynamic> block) =>
      supportedTypes.contains(block['type']) &&
      block['type'] is String;
}

typedef TemplateBuilder = Widget Function(
  BuildContext context,
  TemplatePayloadSchema schema,
);

/// Central allowlisted registry. Adding a template does not require a new screen.
class TemplateRegistry {
  TemplateRegistry._();

  static final Map<String, TemplateBuilder> _builders =
      <String, TemplateBuilder>{
    'generic_template': _buildDocument,
    'reader_template': _buildDocument,
    'analytics_template': _buildDocument,
    'comparison_template': _buildDocument,
    'graph_template': _buildDocument,
    'cosmic_template': _buildDocument,
    'abjad_template': _buildDocument,
    'agent_template': _buildDocument,
  };

  static Set<String> get registeredIds =>
      Set<String>.unmodifiable(_builders.keys);

  static bool register(String id, TemplateBuilder builder) {
    final normalized = id.trim();
    if (normalized.isEmpty || _builders.containsKey(normalized)) return false;
    _builders[normalized] = builder;
    return true;
  }

  static TemplateBuilder? lookup(String id) => _builders[id];

  static Widget _buildDocument(
    BuildContext context,
    TemplatePayloadSchema schema,
  ) =>
      _SchemaDocument(schema: schema);
}

/// Factory resolves only registered template ids and fails closed on unknown ids.
abstract final class TemplateFactory {
  static Widget create({
    required BuildContext context,
    required TemplatePayloadSchema schema,
  }) {
    final builder = TemplateRegistry.lookup(schema.templateId);
    if (builder == null) {
      return TemplateEmptyState(
        message: 'نوع القالب غير مسجل: ${schema.templateId}',
      );
    }
    return builder(context, schema);
  }
}

/// Entry point for agent payloads. The canonical source text/data must be
/// supplied by domain services; this widget never computes missing facts.
class UniversalTemplateRenderer extends StatelessWidget {
  const UniversalTemplateRenderer({
    super.key,
    required this.dataPayload,
    this.fallbackTitle,
  });

  final Map<String, dynamic> dataPayload;
  final String? fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final schema = TemplatePayloadSchema.fromMap(dataPayload);
    final resolved = TemplatePayloadSchema(
      templateId: schema.templateId,
      version: schema.version,
      title: schema.title.isEmpty ? (fallbackTitle ?? '') : schema.title,
      domain: schema.domain,
      blocks: schema.blocks,
      emptyMessage: schema.emptyMessage,
    );
    return TemplateFactory.create(context: context, schema: resolved);
  }
}

class _SchemaDocument extends StatelessWidget {
  const _SchemaDocument({required this.schema});

  final TemplatePayloadSchema schema;

  @override
  Widget build(BuildContext context) {
    final blocks = schema.blocks.where(TemplateBlockSchema.isSupported).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return ListView(
          padding: EdgeInsets.all(wide ? 24 : 16),
          children: <Widget>[
            if (schema.title.isNotEmpty || schema.domain != null)
              _GlassHeader(title: schema.title, subtitle: schema.domain),
            if (blocks.isEmpty)
              TemplateEmptyState(message: schema.emptyMessage)
            else
              for (final block in blocks) ...[
                const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
                RepaintBoundary(child: _AtomicBlock(block: block)),
              ],
          ],
        );
      },
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MudabbirDesignTokens.glassSurface,
          borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
          border: Border.all(color: MudabbirDesignTokens.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title.isNotEmpty)
              Text(title,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: MudabbirDesignTokens.goldBright,
                        fontWeight: FontWeight.w700,
                      )),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      );
}

class _AtomicBlock extends StatelessWidget {
  const _AtomicBlock({required this.block});

  final Map<String, dynamic> block;

  String _string(String key, [String fallback = '']) =>
      block[key] is String ? block[key] as String : fallback;

  @override
  Widget build(BuildContext context) {
    final type = _string('type');
    final title = _string('title');
    final theme = Theme.of(context);
    switch (type) {
      case 'text':
      case 'quran_verse':
        final text = _string('text');
        if (text.isEmpty) {
          return TemplateEmptyState(message: 'النص غير متوفر في مصدر البيانات.');
        }
        return _GlassCard(
          title: title,
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: type == 'quran_verse'
                ? theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Amiri',
                    height: 1.9,
                  )
                : theme.textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
        );
      case 'metric':
        final value = block['value'];
        return _GlassCard(
          title: title,
          child: value == null
              ? const TemplateEmptyState(message: 'القيمة غير متوفرة من المصدر.')
              : Text(value.toString(),
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: MudabbirDesignTokens.goldBright,
                    fontWeight: FontWeight.w800,
                  )),
        );
      case 'section':
        final children = block['children'];
        final nested = children is List
            ? children.whereType<Map>().map((m) => Map<String, dynamic>.from(m))
                .where(TemplateBlockSchema.isSupported).toList()
            : <Map<String, dynamic>>[];
        return _GlassCard(
          title: title,
          child: nested.isEmpty
              ? Text(_string('text', 'لا توجد تفاصيل موثقة لهذا القسم.'),
                  textDirection: TextDirection.rtl)
              : Column(
                  children: [
                    for (final item in nested) ...[
                      _AtomicBlock(block: item),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
        );
      case 'list':
        final items = block['items'];
        final validItems = items is List
            ? items.whereType<String>().toList(growable: false)
            : const <String>[];
        return _GlassCard(
          title: title,
          child: validItems.isEmpty
              ? const TemplateEmptyState(message: 'القائمة فارغة أو غير متوفرة.')
              : Column(
                  children: [
                    for (final item in validItems)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.circle,
                            size: 7, color: MudabbirDesignTokens.gold),
                        title: Text(item,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right),
                      ),
                  ],
                ),
        );
      case 'table':
        final columns = (block['columns'] is List)
            ? (block['columns'] as List).whereType<String>().toList()
            : <String>[];
        final rows = (block['rows'] is List)
            ? (block['rows'] as List)
                .whereType<List>()
                .map((row) => row.map((cell) => cell?.toString() ?? '—').toList())
                .toList()
            : <List<String>>[];
        return _GlassCard(
          title: title,
          child: columns.isEmpty || rows.isEmpty
              ? const TemplateEmptyState(message: 'بيانات الجدول غير مكتملة.')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: columns
                        .map((column) => DataColumn(label: Text(column)))
                        .toList(),
                    rows: rows.map((row) {
                      final cells = List<String>.generate(
                        columns.length,
                        (index) => index < row.length ? row[index] : '—',
                      );
                      return DataRow(
                        cells: cells.map((cell) => DataCell(Text(cell))).toList(),
                      );
                    }).toList(),
                  ),
                ),
        );
      case 'bar_chart':
        final entries = block['items'];
        final items = entries is List
            ? entries.whereType<Map>().map((e) => Map<String, dynamic>.from(e))
                .where((e) => e['label'] is String && e['value'] is num).toList()
            : <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return _GlassCard(
            title: title,
            child: const TemplateEmptyState(
                message: 'لا توجد قيم رقمية موثقة للرسم البياني.'),
          );
        }
        final maxValue = items
            .map((e) => (e['value'] as num).toDouble().abs())
            .fold<double>(0, (a, b) => a > b ? a : b);
        return _GlassCard(
          title: title,
          child: Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(item['label'] as String,
                            textDirection: TextDirection.rtl,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: maxValue == 0
                              ? 0
                              : ((item['value'] as num).toDouble().abs() /
                                      maxValue)
                                  .clamp(0.0, 1.0),
                          minHeight: 9,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: MudabbirDesignTokens.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text((item['value'] as num).toString()),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'status':
        final status = _string('status', 'unknown');
        final message = _string('message', 'لم يرد وصف حالة من المصدر.');
        return _GlassCard(
          title: title,
          child: Row(
            children: [
              Icon(
                status == 'healthy' || status == 'ready'
                    ? Icons.check_circle_outline
                    : status == 'error'
                        ? Icons.error_outline
                        : Icons.info_outline,
                color: status == 'error'
                    ? theme.colorScheme.error
                    : MudabbirDesignTokens.teal,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message, textDirection: TextDirection.rtl)),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MudabbirDesignTokens.glassSurface,
          borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
          border: Border.all(color: MudabbirDesignTokens.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(title!,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MudabbirDesignTokens.gold,
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      );
}

class TemplateEmptyState extends StatelessWidget {
  const TemplateEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MudabbirDesignTokens.glassSurface,
          borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
          border: Border.all(color: MudabbirDesignTokens.glassBorder),
        ),
        child: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
}
