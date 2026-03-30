class IndustryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int sortOrder;

  const IndustryModel({
    required this.id, required this.name, required this.slug,
    this.description, this.imageUrl, required this.sortOrder,
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) => IndustryModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );
}
