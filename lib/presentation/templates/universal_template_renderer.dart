import 'package:flutter/material.dart';

import '../../core/themes/mudabbir_design_tokens.dart';

/// Versioned payload contract shared by domain services and UI templates.
/// Invalid envelopes fail closed; malformed blocks are excluded and reported.
class TemplatePayloadSchema {
  const TemplatePayloadSchema({
    required this.templateId,
    required this.version,
    required this.title,
    required this.blocks,
    this.domain,
    this.source,
    this.emptyMessage = 'لا توجد بيانات موثوقة لعرضها بعد.',
    this.validationErrors = const <String>[],
    this.envelopeValid = true,
  });

  final String templateId;
  final int version;
  final String title;
  final String? domain;
  final String? source;
  final List<Map<String, dynamic>> blocks;
  final String emptyMessage;
  final List<String> validationErrors;
  final bool envelopeValid;

  bool get isValid => envelopeValid && validationErrors.isEmpty;

  factory TemplatePayloadSchema.fromMap(Map<String, dynamic> payload) {
    final errors = <String>[];
    final rawTemplateId = payload['ui_template'] ?? payload['template_id'];
    final templateId = rawTemplateId is String ? rawTemplateId.trim() : '';
    if (templateId.isEmpty) errors.add('معرّف القالب مفقود أو غير نصي.');

    final rawVersion = payload['schema_version'];
    final version = rawVersion is int ? rawVersion : -1;
    if (rawVersion is! int) {
      errors.add('إصدار المخطط schema_version يجب أن يكون عددًا صحيحًا.');
    } else if (version != 1) {
      errors.add('إصدار المخطط غير مدعوم: $version.');
    }

    final rawTitle = payload['title'];
    final title = rawTitle is String ? rawTitle : '';
    if (rawTitle != null && rawTitle is! String) {
      errors.add('حقل title يجب أن يكون نصًا.');
    }
    final rawDomain = payload['domain'];
    final domain = rawDomain is String ? rawDomain : null;
    if (rawDomain != null && rawDomain is! String) {
      errors.add('حقل domain يجب أن يكون نصًا.');
    }
    final rawSource = payload['source'];
    final source = rawSource is String && rawSource.trim().isNotEmpty
        ? rawSource.trim()
        : null;
    if (rawSource != null && rawSource is! String) {
      errors.add('حقل source يجب أن يكون نصًا.');
    } else if (rawSource is String && rawSource.trim().isEmpty) {
      errors.add('حقل source لا يجوز أن يكون نصًا فارغًا عند توفيره.');
    }

    final rawEmptyMessage = payload['empty_message'];
    final emptyMessage = rawEmptyMessage is String && rawEmptyMessage.trim().isNotEmpty
        ? rawEmptyMessage
        : 'لا توجد بيانات موثوقة لعرضها بعد.';
    if (rawEmptyMessage != null && rawEmptyMessage is! String) {
      errors.add('حقل empty_message يجب أن يكون نصًا.');
    }

    final rawBlocks = payload['blocks'];
    final blocks = <Map<String, dynamic>>[];
    if (rawBlocks is! List) {
      errors.add('حقل blocks مطلوب ويجب أن يكون قائمة.');
    } else {
      for (var index = 0; index < rawBlocks.length; index++) {
        final item = rawBlocks[index];
        if (item is! Map) {
          errors.add('الكتلة رقم ${index + 1} ليست كائنًا.');
          continue;
        }
        if (item.keys.any((key) => key is! String)) {
          errors.add('الكتلة رقم ${index + 1} تحتوي مفاتيح غير نصية.');
          continue;
        }
        final block = Map<String, dynamic>.from(item);
        final blockErrors = TemplateBlockSchema.validate(block);
        if (blockErrors.isEmpty) {
          blocks.add(block);
        } else {
          errors.addAll(blockErrors.map((error) => 'الكتلة رقم ${index + 1}: $error'));
        }
      }
    }

    final envelopeValid = templateId.isNotEmpty &&
        version == 1 &&
        rawVersion is int &&
        rawBlocks is List &&
        (rawTitle == null || rawTitle is String) &&
        (rawDomain == null || rawDomain is String) &&
        (rawSource == null || (rawSource is String && rawSource.trim().isNotEmpty)) &&
        (rawEmptyMessage == null || rawEmptyMessage is String);
    return TemplatePayloadSchema(
      templateId: templateId.isEmpty ? 'generic_template' : templateId,
      version: version < 0 ? 0 : version,
      title: title,
      domain: domain,
      source: source,
      blocks: List<Map<String, dynamic>>.unmodifiable(blocks),
      emptyMessage: emptyMessage,
      validationErrors: List<String>.unmodifiable(errors),
      envelopeValid: envelopeValid,
    );
  }

  bool get hasRenderableBlocks =>
      envelopeValid && blocks.isNotEmpty && blocks.any(TemplateBlockSchema.isSupported);
}

/// Strict field-level validation for the renderer's atomic block contract.
abstract final class TemplateBlockSchema {
  static const supportedTypes = <String>{
    'text', 'metric', 'section', 'list', 'table',
    'quran_verse', 'bar_chart', 'status',
  };

  static bool isSupported(Map<String, dynamic> block) =>
      block['type'] is String && supportedTypes.contains(block['type']);

  static List<String> validate(Map<String, dynamic> block, {int depth = 0}) {
    final errors = <String>[];
    final type = block['type'];
    if (type is! String || !supportedTypes.contains(type)) {
      return <String>['نوع الكتلة غير مدعوم.'];
    }
    if (block['title'] != null && block['title'] is! String) {
      errors.add('title يجب أن يكون نصًا.');
    }
    switch (type) {
      case 'text':
      case 'quran_verse':
        if (block['text'] is! String || (block['text'] as String).trim().isEmpty) {
          errors.add('text مطلوب ويجب ألا يكون فارغًا.');
        }
        break;
      case 'metric':
        final value = block['value'];
        if (value == null || !(value is String || value is num || value is bool)) {
          errors.add('value مطلوب ويجب أن يكون قيمة بسيطة (نصًا أو رقمًا أو منطقيًا).');
        }
        break;
      case 'section':
        if (block['text'] != null && block['text'] is! String) {
          errors.add('text يجب أن يكون نصًا.');
        }
        final children = block['children'];
        if (children != null && children is! List) {
          errors.add('children يجب أن تكون قائمة.');
        } else if (children is List) {
          if (depth >= 5 && children.isNotEmpty) {
            errors.add('تجاوزت الأقسام الحد الأقصى للتداخل.');
          } else {
            for (var i = 0; i < children.length; i++) {
              final child = children[i];
              if (child is! Map) {
                errors.add('العنصر الفرعي رقم ${i + 1} ليس كائنًا.');
              } else if (child.keys.any((key) => key is! String)) {
                errors.add('العنصر الفرعي رقم ${i + 1} يحتوي مفاتيح غير نصية.');
              } else {
                errors.addAll(validate(Map<String, dynamic>.from(child), depth: depth + 1)
                    .map((error) => 'العنصر الفرعي رقم ${i + 1}: $error'));
              }
            }
          }
        }
        break;
      case 'list':
        final items = block['items'];
        if (items is! List || items.any((item) => item is! String)) {
          errors.add('items يجب أن تكون قائمة من النصوص.');
        }
        break;
      case 'table':
        final columns = block['columns'];
        final rows = block['rows'];
        if (columns is! List || columns.isEmpty || columns.any((item) => item is! String)) {
          errors.add('columns يجب أن تكون قائمة غير فارغة من النصوص.');
        }
        if (rows is! List || rows.any((row) =>
            row is! List || row.any((cell) =>
                !(cell == null || cell is String || cell is num || cell is bool)))) {
          errors.add('rows يجب أن تكون قائمة صفوف بخلايا بسيطة.');
        } else if (columns is List && rows is List &&
            rows.whereType<List>().any((row) => row.length != columns.length)) {
          errors.add('عدد خلايا كل صف يجب أن يطابق عدد الأعمدة.');
        }
        break;
      case 'bar_chart':
        final items = block['items'];
        if (items is! List || items.isEmpty || items.any((item) =>
            item is! Map || item['label'] is! String || item['value'] is! num)) {
          errors.add('items يجب أن تحتوي عناصر لها label نصي وvalue رقمي.');
        }
        break;
      case 'status':
        if (block['status'] != null && block['status'] is! String) {
          errors.add('status يجب أن يكون نصًا.');
        }
        if (block['message'] != null && block['message'] is! String) {
          errors.add('message يجب أن يكون نصًا.');
        }
        break;
    }
    return errors;
  }
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
    if (!schema.envelopeValid) {
      final details = schema.validationErrors.isEmpty
          ? 'راجع إصدار المخطط والحقول المطلوبة.'
          : schema.validationErrors.join('\n');
      return TemplateEmptyState(
        message: 'تعذر عرض البيانات لأن مخطط القالب غير صالح.\n$details',
      );
    }
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
      source: schema.source,
      blocks: schema.blocks,
      emptyMessage: schema.emptyMessage,
      validationErrors: schema.validationErrors,
      envelopeValid: schema.envelopeValid,
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
              _GlassHeader(
                title: schema.title,
                subtitle: schema.domain,
                source: schema.source,
              ),
            if (schema.validationErrors.isNotEmpty)
              TemplateEmptyState(
                message: 'تم استبعاد بيانات غير صالحة من العرض:\n${schema.validationErrors.join('\n')}',
              ),
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
  const _GlassHeader({required this.title, this.subtitle, this.source});

  final String title;
  final String? subtitle;
  final String? source;

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
            if (source != null && source!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified_outlined,
                      size: 14, color: MudabbirDesignTokens.textMuted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'المصدر: $source',
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: MudabbirDesignTokens.textMuted,
                          ),
                    ),
                  ),
                ],
              ),
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
