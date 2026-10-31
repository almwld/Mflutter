import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/mudabbir_design_tokens.dart';
import 'components/block_registry.dart';
import 'components/block_event_bus.dart';
import 'components/block_event_scope.dart';
import 'adaptive_template_selector.dart';
import 'components/canvas_block_entrance.dart';

/// Versioned payload contract shared by domain services and UI templates.
/// Invalid envelopes fail closed; malformed blocks are excluded and reported.
class TemplatePayloadSchema {
  const TemplatePayloadSchema({
    required this.templateId,
    required this.version,
    required this.title,
    required this.blocks,
    this.domain,
    this.subtitle,
    this.source,
    this.emptyMessage = 'لا توجد بيانات موثوقة لعرضها بعد.',
    this.validationErrors = const <String>[],
    this.envelopeValid = true,
  });

  final String templateId;
  final int version;
  final String title;
  final String? domain;
  final String? subtitle;
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

    final rawMetadata = payload['metadata'];
    final metadata = rawMetadata is Map ? rawMetadata : const <String, dynamic>{};
    if (rawMetadata != null && rawMetadata is! Map) {
      errors.add('حقل metadata يجب أن يكون كائنًا.');
    }
    if (metadata.keys.any((key) => key is! String)) {
      errors.add('حقل metadata يحتوي مفاتيح غير نصية.');
    }
    final rawTitle = payload['title'] ?? metadata['title'];
    final title = rawTitle is String ? rawTitle : '';
    if (rawTitle != null && rawTitle is! String) {
      errors.add('حقل title يجب أن يكون نصًا.');
    }
    final rawDomain = payload['domain'] ?? metadata['topic_category'];
    final domain = rawDomain is String ? rawDomain : null;
    if (rawDomain != null && rawDomain is! String) {
      errors.add('حقل domain/topic_category يجب أن يكون نصًا.');
    }
    final rawSubtitle = payload['subtitle'] ?? metadata['subtitle'];
    final subtitle = rawSubtitle is String ? rawSubtitle : null;
    if (rawSubtitle != null && rawSubtitle is! String) {
      errors.add('حقل subtitle يجب أن يكون نصًا.');
    }
    if (metadata['generated_at'] != null && metadata['generated_at'] is! String) {
      errors.add('metadata.generated_at يجب أن يكون نص ISO-8601 عند توفيره.');
    }
    final rawSource = payload['source'] ?? metadata['source'];
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
    final seenBlockIds = <String>{};
    if (rawBlocks is! List) {
      errors.add('حقل blocks مطلوب ويجب أن يكون قائمة.');
    } else {
      if (rawBlocks.length > 300) {
        errors.add('عدد الكتل تجاوز الحد الأقصى 300 كتلة في الحمولة الواحدة.');
      }
      for (var index = 0; index < rawBlocks.length && index < 300; index++) {
        final item = rawBlocks[index];
        if (item is! Map) {
          errors.add('الكتلة رقم ${index + 1} ليست كائنًا.');
          continue;
        }
        if (item.keys.any((key) => key is! String)) {
          errors.add('الكتلة رقم ${index + 1} تحتوي مفاتيح غير نصية.');
          continue;
        }
        final block = TemplateBlockSchema.normalize(item);
        if (block == null) {
          errors.add('الكتلة رقم ${index + 1}: بيانات الكتلة أو data غير صالحة.');
          continue;
        }
        final blockErrors = TemplateBlockSchema.validate(block);
        if (blockErrors.isNotEmpty) {
          errors.addAll(blockErrors.map((error) => 'الكتلة رقم ${index + 1}: $error'));
          continue;
        }
        final rawId = block['id'];
        final blockId = rawId is String && rawId.trim().isNotEmpty
            ? rawId.trim()
            : '__canvas_generated__${block['type']}-$index';
        if (!seenBlockIds.add(blockId)) {
          errors.add('الكتلة رقم ${index + 1}: معرّف id مكرر داخل اللوحة ($blockId).');
          continue;
        }
        blocks.add(block);
      }
    }

    final envelopeValid = templateId.isNotEmpty &&
        version == 1 &&
        rawVersion is int &&
        rawBlocks is List &&
        rawBlocks.length <= 300 &&
        (rawTitle == null || rawTitle is String) &&
        (rawDomain == null || rawDomain is String) &&
        (rawSubtitle == null || rawSubtitle is String) &&
        (rawMetadata == null || (rawMetadata is Map &&
            !metadata.keys.any((key) => key is! String) &&
            (metadata['generated_at'] == null || metadata['generated_at'] is String))) &&
        (rawSource == null || (rawSource is String && rawSource.trim().isNotEmpty)) &&
        (rawEmptyMessage == null || rawEmptyMessage is String);
    return TemplatePayloadSchema(
      templateId: templateId.isEmpty ? 'generic_template' : templateId,
      version: version < 0 ? 0 : version,
      title: title,
      domain: domain,
      subtitle: subtitle,
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
    'text', 'metric', 'metric_card', 'section', 'list', 'table',
    'bar_chart', 'status',
    'hero_header_block', 'timeline_block', 'relation_graph_block', 'star_tracker_block',
    'code_math_block', 'audio_frequency_block', 'spatial_map_block',
    'star_map_block', 'vector_space_block', 'quantum_particle_block',
    'interactive_card_block', 'particle_matrix_block', 'connected_nodes_path_block',
    'physics_sandbox_block',
  };

  static bool isSupported(Map<String, dynamic> block) =>
      block['type'] is String && supportedTypes.contains(block['type']);

  /// Normalizes the public {type, title, data} form without allowing data to
  /// replace envelope-owned fields. Returns null for malformed map shapes.
  static Map<String, dynamic>? normalize(Map raw) {
    if (raw.keys.any((key) => key is! String)) return null;
    final block = Map<String, dynamic>.from(raw);
    final rawData = block.remove('data');
    block.remove('style_hints');
    if (rawData != null && rawData is! Map) return null;
    if (rawData is Map) {
      if (rawData.keys.any((key) => key is! String)) return null;
      for (final entry in rawData.entries) {
        if (entry.key != 'type' && entry.key != 'title') {
          block.putIfAbsent(entry.key as String, () => entry.value);
        }
      }
    }
    return block;
  }

  static List<String> validate(Map<String, dynamic> block, {int depth = 0}) {
    final errors = <String>[];
    final type = block['type'];
    if (type is! String || !supportedTypes.contains(type)) {
      return <String>['نوع الكتلة غير مدعوم.'];
    }
    if (block['title'] != null && block['title'] is! String) {
      errors.add('title يجب أن يكون نصًا.');
    }
    if (block['id'] != null &&
        (block['id'] is! String ||
            (block['id'] as String).trim().isEmpty ||
            (block['id'] as String).length > 80)) {
      errors.add('id يجب أن يكون معرّفًا نصيًا غير فارغ لا يتجاوز 80 حرفًا.');
    }
    if (block['target_block_id'] != null &&
        (block['target_block_id'] is! String ||
            (block['target_block_id'] as String).trim().isEmpty ||
            (block['target_block_id'] as String).length > 80)) {
      errors.add('target_block_id يجب أن يكون معرّفًا نصيًا صالحًا.');
    }
    switch (type) {
      case 'text':
        if (block['text'] is! String || (block['text'] as String).trim().isEmpty) {
          errors.add('text مطلوب ويجب ألا يكون فارغًا.');
        }
        break;
      case 'metric':
        final value = block['value'];
        if (value == null || !(value is String || value is num || value is bool)) {
          errors.add('value مطلوب ويجب أن يكون قيمة بسيطة (نصًا أو رقمًا أو منطقيًا).');
        } else if (value is num && !value.isFinite) {
          errors.add('value الرقمي يجب أن يكون محدودًا وليس NaN أو Infinity.');
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
          if (children.length > 100) {
            errors.add('عدد الكتل الفرعية تجاوز الحد الأقصى 100.');
          } else if (depth >= 5 && children.isNotEmpty) {
            errors.add('تجاوزت الأقسام الحد الأقصى للتداخل.');
          } else {
            for (var i = 0; i < children.length; i++) {
              final child = children[i];
              if (child is! Map) {
                errors.add('العنصر الفرعي رقم ${i + 1} ليس كائنًا.');
              } else if (child.keys.any((key) => key is! String)) {
                errors.add('العنصر الفرعي رقم ${i + 1} يحتوي مفاتيح غير نصية.');
              } else {
                final normalizedChild = normalize(child);
                if (normalizedChild == null) {
                  errors.add('العنصر الفرعي رقم ${i + 1}: بيانات الكتلة أو data غير صالحة.');
                } else {
                  errors.addAll(validate(normalizedChild, depth: depth + 1)
                      .map((error) => 'العنصر الفرعي رقم ${i + 1}: $error'));
                }
              }
            }
          }
        }
        break;
      case 'list':
        final items = block['items'];
        if (items is! List || items.length > 500 || items.any((item) => item is! String)) {
          errors.add('items يجب أن تكون قائمة من النصوص.');
        }
        break;
      case 'table':
        final columns = block['columns'];
        final rows = block['rows'];
        if (columns is! List || columns.isEmpty || columns.length > 50 ||
            columns.any((item) => item is! String)) {
          errors.add('columns يجب أن تكون قائمة من 1 إلى 50 نصًا.');
        }
        if (rows is! List || rows.length > 500 || rows.any((row) =>
            row is! List || row.length > 50 || row.any((cell) =>
                !(cell == null || cell is String || cell is bool ||
                    (cell is num && cell.isFinite))))) {
          errors.add('rows يجب أن تكون قائمة صفوف بخلايا بسيطة.');
        } else if (columns is List &&
            rows.whereType<List>().any((row) => row.length != columns.length)) {
          errors.add('عدد خلايا كل صف يجب أن يطابق عدد الأعمدة.');
        }
        final rowIds = block['row_ids'];
        if (rowIds != null &&
            (rowIds is! List ||
                rowIds.length != (rows is List ? rows.length : -1) ||
                rowIds.any((id) => id is! String || id.trim().isEmpty))) {
          errors.add('row_ids يجب أن تحتوي معرّفًا نصيًا غير فارغ لكل صف.');
        }
        break;
      case 'bar_chart':
        final items = block['items'];
        if (items is! List || items.isEmpty || items.length > 500 || items.any((item) =>
            item is! Map || item['label'] is! String || item['value'] is! num ||
            (item['value'] is num && !(item['value'] as num).isFinite))) {
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
      case 'hero_header_block':
        if (block['subtitle'] != null && block['subtitle'] is! String) errors.add('subtitle يجب أن يكون نصًا.');
        break;
      case 'timeline_block':
        final events = block['events'];
        if (events is! List || events.isEmpty || events.length > 200 || events.any((event) =>
            event is! Map || event['label'] is! String ||
            (event['date'] != null && event['date'] is! String) ||
            (event['details'] != null && event['details'] is! String))) {
          errors.add('events يجب أن تكون قائمة أحداث موصوفة بنصوص.');
        }
        break;
      case 'relation_graph_block':
        final nodes = block['nodes'];
        final edges = block['edges'];
        if (nodes is! List || nodes.isEmpty || nodes.length > 250 || nodes.any((node) =>
            node is! Map || node['id'] is! String || node['label'] is! String)) {
          errors.add('nodes يجب أن تحتوي معرّفًا واسمًا نصيين لكل عقدة.');
        }
        if (edges is! List || edges.length > 500 || edges.any((edge) =>
            edge is! Map || edge['from'] is! String || edge['to'] is! String)) {
          errors.add('edges يجب أن تربط عقدًا باستخدام from وto نصيين.');
        }
        break;
      case 'star_map_block':
      case 'vector_space_block':
      case 'spatial_map_block':
      case 'quantum_particle_block':
        final points = block['points'] ?? block['particles'] ?? block['stars'];
        if (points is! List || points.isEmpty || points.length > 250 ||
            points.any((point) => point is! Map ||
                point['x'] is! num || point['y'] is! num ||
                (point['label'] != null && point['label'] is! String) ||
                (point['id'] != null && point['id'] is! String) ||
                (point['node_id'] != null && point['node_id'] is! String) ||
                !(point['x'] as num).isFinite || !(point['y'] as num).isFinite ||
                (point['x'] as num) < 0 || (point['x'] as num) > 1 ||
                (point['y'] as num) < 0 || (point['y'] as num) > 1)) {
          errors.add('يجب أن تحتوي النقاط على إحداثيات x/y بين 0 و1، وبحد أقصى 250 نقطة.');
        }
        if (type == 'quantum_particle_block') {
          final links = block['links'];
          final pointCount = points is List ? points.length : 0;
          if (links != null && (links is! List || links.length > 500 || links.any((link) =>
              link is! List || link.length != 2 ||
              link.any((index) => index is! int || index < 0 || index >= pointCount)))) {
            errors.add('links يجب أن تكون أزواج فهارس صحيحة للجسيمات.');
          }
        }
        break;
      case 'particle_matrix_block':
        final count = block['count'];
        final columns = block['columns'];
        final activeRow = block['active_row'];
        final activeNodes = block['active_nodes'];
        final speed = block['speed'];
        final height = block['height'];
        if (count != null && (count is! int || count < 1 || count > 8000)) {
          errors.add('count يجب أن يكون عددًا صحيحًا بين 1 و8000.');
        }
        if (columns != null && (columns is! int || columns < 1 || columns > 500)) {
          errors.add('columns يجب أن يكون عددًا صحيحًا بين 1 و500.');
        }
        final safeCount = count is int ? count : 2400;
        if (activeRow != null && (activeRow is! int || activeRow < 0 ||
            activeRow >= (safeCount / (columns is int && columns > 0 ? columns : 80)).ceil())) {
          errors.add('active_row خارج نطاق صفوف المصفوفة.');
        }
        if (activeNodes != null && (activeNodes is! List || activeNodes.length > 128 ||
            activeNodes.any((index) => index is! int || index < 0 || index >= safeCount))) {
          errors.add('active_nodes يجب أن تكون فهارس صحيحة ضمن عدد الجسيمات وبحد أقصى 128.');
        }
        final nodeIds = block['node_ids'];
        if (nodeIds != null && (nodeIds is! List || nodeIds.length > safeCount ||
            nodeIds.any((id) => id is! String || id.trim().isEmpty) ||
            (nodeIds.whereType<String>().toSet().length != nodeIds.length))) {
          errors.add('node_ids يجب أن تكون معرّفات نصية فريدة وبحد أقصى count.');
        }
        if (speed != null && (speed is! num || !speed.isFinite || speed < .1 || speed > 3)) {
          errors.add('speed يجب أن تكون قيمة رقمية بين 0.1 و3.');
        }
        if (height != null && (height is! num || !height.isFinite || height < 80 || height > 900)) {
          errors.add('height يجب أن تكون قيمة رقمية بين 80 و900.');
        }
        break;
      case 'connected_nodes_path_block':
        final nodes = block['nodes'];
        final edges = block['edges'] ?? const <dynamic>[];
        if (nodes is! List || nodes.length < 2 || nodes.length > 250 ||
            nodes.any((node) => node is! Map ||
                node['id'] is! String || (node['id'] as String).trim().isEmpty ||
                node['label'] is! String ||
                ((node['x'] == null) != (node['y'] == null)) ||
                (node['x'] != null && (node['x'] is! num || !(node['x'] as num).isFinite ||
                    (node['x'] as num) < 0 || (node['x'] as num) > 1)) ||
                (node['y'] != null && (node['y'] is! num || !(node['y'] as num).isFinite ||
                    (node['y'] as num) < 0 || (node['y'] as num) > 1)))) {
          errors.add('nodes يجب أن تحتوي 2 إلى 250 عقدة بمعرّف واسم وإحداثيات اختيارية صحيحة.');
        } else {
          final ids = nodes.map((node) => (node as Map)['id'] as String).toSet();
          if (ids.length != nodes.length) errors.add('معرّفات العقد يجب أن تكون فريدة.');
          if (edges is! List || edges.length > 500 || edges.any((edge) =>
              edge is! Map || edge['from'] is! String || edge['to'] is! String ||
              !ids.contains(edge['from']) || !ids.contains(edge['to']))) {
            errors.add('edges يجب أن تربط معرّفات عقد موجودة وبحد أقصى 500 وصلة.');
          }
        }
        if (block['height'] != null &&
            (block['height'] is! num || !(block['height'] as num).isFinite ||
                (block['height'] as num) < 120 || (block['height'] as num) > 900)) {
          errors.add('height يجب أن تكون قيمة بين 120 و900.');
        }
        break;
      case 'physics_sandbox_block':
        final height = block['height'];
        if (height != null &&
            (height is! num || !height.isFinite || height < 160 || height > 700)) {
          errors.add('height يجب أن تكون قيمة رقمية بين 160 و700.');
        }
        break;
      case 'code_math_block':
        if (block['expression'] is! String || (block['expression'] as String).trim().isEmpty) errors.add('expression مطلوب كنص.');
        if (block['explanation'] != null && block['explanation'] is! String) errors.add('explanation يجب أن يكون نصًا.');
        break;
      case 'audio_frequency_block':
        final samples = block['samples'];
        if (samples is! List || samples.length < 2 || samples.length > 512 ||
            samples.any((sample) => sample is! num || !sample.isFinite || sample < -1 || sample > 1)) {
          errors.add('samples يجب أن تكون بين 2 و512 قيمة رقمية ضمن المجال -1 إلى 1.');
        }
        if (block['frequency_hz'] != null &&
            (block['frequency_hz'] is! num || !(block['frequency_hz'] as num).isFinite)) {
          errors.add('frequency_hz يجب أن يكون رقمًا محدودًا صادرًا عن مصدر موثوق.');
        }
        break;
      case 'interactive_card_block':
        if (block['front'] is! String || block['details'] is! String) errors.add('front وdetails مطلوبان كنصين.');
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
    'universal_dynamic_canvas': _buildDocument,
    'dashboard_template': _buildDocument,
    'chat_template': _buildDocument,
    'library_template': _buildDocument,
    'player_template': _buildDocument,
    'settings_template': _buildDocument,
    'search_template': _buildDocument,
    'profile_template': _buildDocument,
    'lab_template': _buildDocument,
    'service_hub_template': _buildDocument,
    'cosmic_celestial_template': _buildDocument,
    'quantum_mesh_template': _buildDocument,
    'vector_embedding_template': _buildDocument,
    'dream_journal_template': _buildDocument,
    'sovereign_ar_iot_template': _buildDocument,
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
class UniversalTemplateRenderer extends StatefulWidget {
  const UniversalTemplateRenderer({
    super.key,
    required this.dataPayload,
    this.fallbackTitle,
  });

  final Map<String, dynamic> dataPayload;
  final String? fallbackTitle;

  @override
  State<UniversalTemplateRenderer> createState() =>
      _UniversalTemplateRendererState();
}

class _UniversalTemplateRendererState extends State<UniversalTemplateRenderer> {
  late final BlockEventBus _eventBus;

  @override
  void initState() {
    super.initState();
    _eventBus = BlockEventBus();
  }

  @override
  void dispose() {
    unawaited(_eventBus.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schema = TemplatePayloadSchema.fromMap(widget.dataPayload);
    final selectedTemplateId = schema.envelopeValid
        ? AdaptiveTemplateSelector.select(
            requestedTemplateId: schema.templateId,
            domain: schema.domain ?? '',
            query: widget.dataPayload['original_query'] is String
                ? widget.dataPayload['original_query'] as String
                : schema.title,
            blocks: schema.blocks,
          )
        : schema.templateId;
    final resolved = TemplatePayloadSchema(
      templateId: selectedTemplateId,
      version: schema.version,
      title: schema.title.isEmpty ? (widget.fallbackTitle ?? '') : schema.title,
      domain: schema.domain,
      subtitle: schema.subtitle,
      source: schema.source,
      blocks: schema.blocks,
      emptyMessage: schema.emptyMessage,
      validationErrors: schema.validationErrors,
      envelopeValid: schema.envelopeValid,
    );
    return BlockEventScope(
      bus: _eventBus,
      child: TemplateFactory.create(context: context, schema: resolved),
    );
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
            if (schema.title.isNotEmpty || schema.domain != null || schema.subtitle != null || schema.source != null)
              _GlassHeader(
                title: schema.title,
                subtitle: schema.subtitle ?? schema.domain,
                source: schema.source,
              ),
            if (schema.validationErrors.isNotEmpty)
              TemplateEmptyState(
                message: 'تم استبعاد بيانات غير صالحة من العرض:\n${schema.validationErrors.join('\n')}',
              ),
            if (blocks.isEmpty)
              TemplateEmptyState(message: schema.emptyMessage)
            else
              for (var index = 0; index < blocks.length; index++) ...[
                const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
                CanvasBlockEntrance(
                  duration: Duration(
                    milliseconds: 260 + (index > 5 ? 225 : index * 45),
                  ),
                  child: RepaintBoundary(
                    child: _AtomicBlock(
                      block: blocks[index],
                      blockId: _canvasBlockId(blocks[index], index),
                    ),
                  ),
                ),
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
                      size: 14, color: Colors.white54),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'المصدر: $source',
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
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

String _canvasBlockId(Map<String, dynamic> block, int index) {
  final id = block['id'];
  if (id is String && id.trim().isNotEmpty) return id.trim();
  final type = block['type'] is String ? block['type'] as String : 'block';
  return '__canvas_generated__$type-$index';
}

class _AtomicBlock extends StatelessWidget {
  const _AtomicBlock({required this.block, this.blockId = ''});

  final Map<String, dynamic> block;
  final String blockId;

  String _string(String key, [String fallback = '']) =>
      block[key] is String ? block[key] as String : fallback;

  @override
  Widget build(BuildContext context) {
    final type = _string('type');
    final title = _string('title');
    final theme = Theme.of(context);
    final componentData = Map<String, dynamic>.fromEntries(
      block.entries.where(
        (entry) => entry.key != 'type' && entry.key != 'title',
      ),
    );
    componentData['_canvas_block_id'] = blockId.isNotEmpty
        ? blockId
        : _canvasBlockId(block, 0);
    final registeredComponent = BlockRegistry.buildBlock(
      type: type,
      title: title,
      data: componentData,
    );
    if (registeredComponent != null) return registeredComponent;
    switch (type) {
      case 'text':
        final text = _string('text');
        return _GlassCard(
          title: title,
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
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
            ? children.whereType<Map>()
                .map(TemplateBlockSchema.normalize)
                .whereType<Map<String, dynamic>>()
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
                .map<List<String>>((row) => row
                    .map<String>((cell) => cell?.toString() ?? '—')
                    .toList(growable: false))
                .toList(growable: false)
            : <List<String>>[];
        final rowIds = block['row_ids'] is List
            ? (block['row_ids'] as List).whereType<String>().toList(growable: false)
            : const <String>[];
        return columns.isEmpty || rows.isEmpty
            ? _GlassCard(
                title: title,
                child: const TemplateEmptyState(message: 'بيانات الجدول غير مكتملة.'),
              )
            : _InteractiveTableBlock(
                title: title,
                columns: columns,
                rows: rows,
                rowIds: rowIds,
                sourceBlockId: blockId.isNotEmpty ? blockId : _canvasBlockId(block, 0),
                targetBlockId: block['target_block_id'] is String
                    ? block['target_block_id'] as String
                    : null,
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
      case 'hero_header_block':
        return _GlassCard(
          title: title,
          child: Text(_string('subtitle'), textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyLarge),
        );
      case 'timeline_block':
        final events = (block['events'] as List).whereType<Map>().toList();
        return _GlassCard(
          title: title,
          child: Column(children: [
            for (var i = 0; i < events.length; i++)
              ListTile(
                dense: true,
                leading: CircleAvatar(radius: 13, child: Text('${i + 1}')),
                title: Text(events[i]['label'] as String, textDirection: TextDirection.rtl),
                subtitle: Text([
                  if (events[i]['date'] is String) events[i]['date'] as String,
                  if (events[i]['details'] is String) events[i]['details'] as String,
                ].join(' · '), textDirection: TextDirection.rtl),
              ),
          ]),
        );
      case 'relation_graph_block':
        final nodes = (block['nodes'] as List).whereType<Map>().toList();
        final edges = (block['edges'] as List).whereType<Map>().toList();
        return _InteractiveRelationGraph(
          title: title,
          nodes: nodes,
          edges: edges,
          blockId: blockId.isNotEmpty ? blockId : _canvasBlockId(block, 0),
        );
      case 'star_map_block':
      case 'vector_space_block':
      case 'spatial_map_block':
      case 'quantum_particle_block':
        final rawPoints = block['points'] ?? block['particles'] ?? block['stars'];
        final points = (rawPoints as List).whereType<Map>().toList();
        final isStars = type == 'star_map_block';
        final isQuantum = type == 'quantum_particle_block';
        final links = <(int, int)>[];
        if (isQuantum && block['links'] is List) {
          for (final pair in block['links'] as List) {
            if (pair is List && pair.length == 2 && pair[0] is int && pair[1] is int) {
              final a = pair[0] as int, b = pair[1] as int;
              if (a >= 0 && b >= 0 && a < points.length && b < points.length) links.add((a, b));
            }
          }
        }
        return _GlassCard(
          title: title,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(height: 240, child: CustomPaint(
              painter: _CoordinateFieldPainter(points: points, links: links,
                  mode: isStars ? 'stars' : (isQuantum ? 'mesh' : 'points')),
              child: const SizedBox.expand(),
            )),
            const SizedBox(height: 8),
            Text(isStars
                ? 'تمثيل بصري للإحداثيات المقدمة؛ ليس رصدًا فلكيًا حيًا.'
                : isQuantum
                    ? 'رسم توضيحي للروابط المقدمة؛ لا يمثل تشابكًا كميًا حقيقيًا.'
                    : 'إسقاط إحداثي ثنائي الأبعاد للبيانات المقدمة، وليس مشهدًا ثلاثي الأبعاد.',
                textDirection: TextDirection.rtl, style: theme.textTheme.bodySmall),
            for (final point in points.where((p) => p['label'] is String).take(12))
              Text('• ${point['label']}', textDirection: TextDirection.rtl),
          ]),
        );
      case 'code_math_block':
        return _GlassCard(title: title, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SelectableText(_string('expression'), textAlign: TextAlign.left,
                style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'monospace')),
            if (_string('explanation').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_string('explanation'), textDirection: TextDirection.rtl),
            ],
          ],
        ));
      case 'audio_frequency_block':
        final samples = (block['samples'] as List).map((sample) => (sample as num).toDouble()).toList();
        return _GlassCard(title: title, child: Column(children: [
          SizedBox(height: 100, child: CustomPaint(
            painter: _WaveformPainter(samples), child: const SizedBox.expand())),
          if (block['frequency_hz'] is num)
            Text('التردد المقدم من المصدر: ${block['frequency_hz']} Hz', textDirection: TextDirection.rtl),
          const Text('شكل الموجة تمثيل للعينات المرفقة، وليس قياسًا مستقلًا.', textDirection: TextDirection.rtl),
        ]));
      case 'interactive_card_block':
        return _ExpansionCard(title: title, front: _string('front'), details: _string('details'));
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

class _InteractiveTableBlock extends StatefulWidget {
  const _InteractiveTableBlock({
    required this.title,
    required this.columns,
    required this.rows,
    required this.rowIds,
    required this.sourceBlockId,
    this.targetBlockId,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final List<String> rowIds;
  final String sourceBlockId;
  final String? targetBlockId;

  @override
  State<_InteractiveTableBlock> createState() => _InteractiveTableBlockState();
}

class _InteractiveTableBlockState extends State<_InteractiveTableBlock> {
  int? _selectedRow;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: widget.title,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columns: widget.columns.map((column) => DataColumn(label: Text(column))).toList(),
          rows: List<DataRow>.generate(widget.rows.length, (rowIndex) {
            final row = widget.rows[rowIndex];
            final cells = List<String>.generate(
              widget.columns.length,
              (columnIndex) => columnIndex < row.length ? row[columnIndex] : '—',
            );
            final selectionId = rowIndex < widget.rowIds.length
                ? widget.rowIds[rowIndex]
                : (cells.isEmpty ? '$rowIndex' : cells.first);
            return DataRow(
              selected: _selectedRow == rowIndex,
              onSelectChanged: (selected) {
                if (selected != true) return;
                setState(() => _selectedRow = rowIndex);
                HapticFeedback.selectionClick();
                final bus = BlockEventScope.maybeOf(context);
                bus?.publish(BlockEvent(
                  type: 'selection_changed',
                  sourceBlockId: widget.sourceBlockId,
                  targetBlockId: widget.targetBlockId,
                  payload: <String, Object?>{
                    'selection_id': selectionId,
                    'row_index': rowIndex,
                    'label': cells.isEmpty ? selectionId : cells.first,
                  },
                ));
              },
              cells: cells.map((cell) => DataCell(Text(cell))).toList(),
            );
          }),
        ),
      ),
    );
  }
}

class _InteractiveRelationGraph extends StatefulWidget {
  const _InteractiveRelationGraph({
    required this.title,
    required this.nodes,
    required this.edges,
    required this.blockId,
  });

  final String title;
  final List<Map> nodes;
  final List<Map> edges;
  final String blockId;

  @override
  State<_InteractiveRelationGraph> createState() => _InteractiveRelationGraphState();
}

class _InteractiveRelationGraphState extends State<_InteractiveRelationGraph> {
  BlockEventBus? _bus;
  StreamSubscription<BlockEvent>? _subscription;
  String? _selectedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextBus = BlockEventScope.maybeOf(context);
    if (identical(nextBus, _bus)) return;
    unawaited(_subscription?.cancel());
    _bus = nextBus;
    _subscription = nextBus?.events.listen((event) {
      if (event.type != 'selection_changed' ||
          event.targetBlockId != widget.blockId ||
          event.payload['selection_id'] is! String) return;
      if (!mounted) return;
      setState(() => _selectedId = event.payload['selection_id'] as String);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _GlassCard(
    title: widget.title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final node in widget.nodes)
            Builder(builder: (context) {
              final id = node['id'] is String ? node['id'] as String : '';
              final selected = id.isNotEmpty && id == _selectedId;
              return Chip(
                avatar: Icon(
                  selected ? Icons.hub : Icons.hub_outlined,
                  size: 16,
                  color: selected ? MudabbirDesignTokens.cyan : null,
                ),
                backgroundColor: selected
                    ? MudabbirDesignTokens.cyan.withOpacity(0.18)
                    : null,
                side: selected
                    ? BorderSide(color: MudabbirDesignTokens.cyan)
                    : null,
                label: Text(node['label'] as String),
              );
            }),
        ]),
        if (widget.edges.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final edge in widget.edges.take(80))
            Text('${edge['from']}  ↔  ${edge['to']}', textDirection: TextDirection.rtl),
        ],
        if (_selectedId != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('العنصر المحدد: $_selectedId', textDirection: TextDirection.rtl),
          ),
      ],
    ),
  );
}

class _ExpansionCard extends StatelessWidget {
  const _ExpansionCard({required this.title, required this.front, required this.details});
  final String title;
  final String front;
  final String details;
  @override
  Widget build(BuildContext context) => _GlassCard(
    title: title,
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(front, textDirection: TextDirection.rtl),
      children: [Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(details, textDirection: TextDirection.rtl),
      )],
    ),
  );
}

class _CoordinateFieldPainter extends CustomPainter {
  const _CoordinateFieldPainter({required this.points, required this.links, required this.mode});
  final List<Map> points;
  final List<(int, int)> links;
  final String mode;
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = MudabbirDesignTokens.glassBorder..style = PaintingStyle.stroke..strokeWidth = 1;
    final nodePaint = Paint()
      ..color = mode == 'stars' ? MudabbirDesignTokens.goldBright : MudabbirDesignTokens.teal
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), linePaint);
    for (final link in links) {
      final a = points[link.$1], b = points[link.$2];
      canvas.drawLine(
        Offset((a['x'] as num).toDouble() * size.width, (a['y'] as num).toDouble() * size.height),
        Offset((b['x'] as num).toDouble() * size.width, (b['y'] as num).toDouble() * size.height),
        linePaint,
      );
    }
    for (final point in points) {
      canvas.drawCircle(Offset(
        (point['x'] as num).toDouble() * size.width,
        (point['y'] as num).toDouble() * size.height,
      ), mode == 'stars' ? 2.8 : 4.2, nodePaint);
    }
  }
  @override
  bool shouldRepaint(covariant _CoordinateFieldPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.links != links || oldDelegate.mode != mode;
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter(this.samples);
  final List<double> samples;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = MudabbirDesignTokens.teal..style = PaintingStyle.stroke..strokeWidth = 1.8;
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = samples.length <= 1 ? 0.0 : i * size.width / (samples.length - 1);
      final y = size.height / 2 - samples[i] * size.height * .42;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => oldDelegate.samples != samples;
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
