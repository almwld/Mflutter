class OccultEntry {
  const OccultEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.properties = const <String, dynamic>{},
    this.abjadValue,
    this.source,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final Map<String, dynamic> properties;
  final int? abjadValue;
  final String? source;

  factory OccultEntry.fromJson(Map<String, dynamic> json) {
    final rawProperties = json['properties'];
    return OccultEntry(
      id: (json['id'] ?? json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      category: (json['category'] ?? json['type'] ?? 'general').toString(),
      description: (json['description'] ?? json['summary'] ?? '').toString(),
      properties: rawProperties is Map
          ? Map<String, dynamic>.from(rawProperties)
          : const <String, dynamic>{},
      abjadValue: int.tryParse(
        (json['abjad_value'] ?? json['abjadValue'] ?? '').toString(),
      ),
      source: (json['source'] ?? json['reference'])?.toString(),
    );
  }
}