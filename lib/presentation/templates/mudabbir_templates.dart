import 'package:flutter/material.dart';

import '../../core/themes/mudabbir_design_tokens.dart';

/// Reusable layout primitives. Feature screens continue to own their data,
/// state, services, and actions; these templates only compose presentation.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    this.header,
    this.quickActions = const <Widget>[],
    this.sections = const <Widget>[],
    this.padding = const EdgeInsets.all(16),
  });

  final Widget? header;
  final List<Widget> quickActions;
  final List<Widget> sections;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: [
          if (header != null) header!,
          if (quickActions.isNotEmpty) ...[
            const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
            Wrap(spacing: 10, runSpacing: 10, children: quickActions),
          ],
          for (final section in sections) ...[
            const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
            section,
          ],
        ],
      );
}

class ReaderTemplate extends StatelessWidget {
  const ReaderTemplate({
    super.key,
    required this.reader,
    this.toolbar,
    this.bottomControls,
  });

  final Widget reader;
  final Widget? toolbar;
  final Widget? bottomControls;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (toolbar != null) toolbar!,
          Expanded(child: reader),
          if (bottomControls != null) bottomControls!,
        ],
      );
}

class ChatTemplate extends StatelessWidget {
  const ChatTemplate({
    super.key,
    required this.messages,
    required this.composer,
    this.header,
  });

  final Widget messages;
  final Widget composer;
  final Widget? header;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (header != null) header!,
          Expanded(child: messages),
          composer,
        ],
      );
}

class LibraryTemplate extends StatelessWidget {
  const LibraryTemplate({
    super.key,
    required this.items,
    required this.searchField,
    this.filters,
  });

  final Widget items;
  final Widget searchField;
  final Widget? filters;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            searchField,
            if (filters != null) ...[
              const SizedBox(height: 10),
              filters!,
            ],
            const SizedBox(height: 12),
            Expanded(child: items),
          ],
        ),
      );
}

class AnalyticsTemplate extends StatelessWidget {
  const AnalyticsTemplate({
    super.key,
    this.summary = const <Widget>[],
    this.charts = const <Widget>[],
    this.details = const <Widget>[],
    this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> summary;
  final List<Widget> charts;
  final List<Widget> details;
  final List<Widget>? children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: children ?? [
          if (summary.isNotEmpty) Wrap(spacing: 10, runSpacing: 10, children: summary),
          for (final chart in charts) ...[
            const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
            chart,
          ],
          for (final detail in details) ...[
            const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
            detail,
          ],
        ],
      );
}

/// Focused list layout for side-by-side Quran reference comparison.
class ComparisonTemplate extends StatelessWidget {
  const ComparisonTemplate({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: children,
      );
}

class GraphTemplate extends StatelessWidget {
  const GraphTemplate({
    super.key,
    required this.graph,
    this.inspector,
    this.minScale = .7,
    this.maxScale = 3,
  });

  final Widget graph;
  final Widget? inspector;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: minScale,
              maxScale: maxScale,
              boundaryMargin: const EdgeInsets.all(24),
              child: graph,
            ),
          ),
          if (inspector != null) inspector!,
        ],
      );
}

class PlayerTemplate extends StatelessWidget {
  const PlayerTemplate({
    super.key,
    required this.artwork,
    required this.trackTitle,
    required this.progress,
    required this.controls,
    this.trackSubtitle,
    this.queue,
  });

  final Widget artwork;
  final String trackTitle;
  final String? trackSubtitle;
  final Widget progress;
  final Widget controls;
  final Widget? queue;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(child: artwork),
          const SizedBox(height: 22),
          Text(trackTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          if (trackSubtitle != null) ...[
            const SizedBox(height: 6),
            Text(trackSubtitle!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 22),
          progress,
          const SizedBox(height: 14),
          controls,
          if (queue != null) ...[
            const SizedBox(height: 24),
            queue!,
          ],
        ],
      );
}

class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({
    super.key,
    required this.groups,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> groups;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: [
          for (final group in groups) ...[
            group,
            const SizedBox(height: 12),
          ],
        ],
      );
}

class SearchTemplate extends StatelessWidget {
  const SearchTemplate({
    super.key,
    required this.searchField,
    required this.results,
    this.filters,
  });

  final Widget searchField;
  final Widget results;
  final Widget? filters;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            searchField,
            if (filters != null) ...[
              const SizedBox(height: 10),
              filters!,
            ],
            const SizedBox(height: 12),
            Expanded(child: results),
          ],
        ),
      );
}

class ProfileTemplate extends StatelessWidget {
  const ProfileTemplate({
    super.key,
    required this.header,
    this.sections = const <Widget>[],
  });

  final Widget header;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          header,
          for (final section in sections) ...[
            const SizedBox(height: MudabbirDesignTokens.sectionSpacing),
            section,
          ],
        ],
      );
}

class LabTemplate extends StatelessWidget {
  const LabTemplate({
    super.key,
    required this.controls,
    required this.output,
    this.diagnostics,
  });

  final Widget controls;
  final Widget output;
  final Widget? diagnostics;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          controls,
          const SizedBox(height: 16),
          output,
          if (diagnostics != null) ...[
            const SizedBox(height: 16),
            diagnostics!,
          ],
        ],
      );
}

class ServiceHubTemplate extends StatelessWidget {
  const ServiceHubTemplate({
    super.key,
    required this.services,
    this.minTileWidth = 148,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> services;
  final double minTileWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final resolvedPadding = padding.resolve(Directionality.of(context));
          final availableWidth = constraints.maxWidth - resolvedPadding.horizontal;
          final columns =
              (availableWidth / minTileWidth).floor().clamp(1, 6).toInt();
          return GridView.count(
            padding: padding,
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.08,
            children: services,
          );
        },
      );
}
