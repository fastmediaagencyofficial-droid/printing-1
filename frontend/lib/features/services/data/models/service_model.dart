class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final String? imageUrl;
  final List<String> features;
  final bool isActive;
  final int sortOrder;

  const ServiceModel({
    required this.id, required this.name, required this.slug,
    required this.description, required this.shortDescription,
    this.imageUrl, required this.features,
    required this.isActive, required this.sortOrder,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String,
        shortDescription: json['shortDescription'] as String,
        imageUrl: json['imageUrl'] as String?,
        features: List<String>.from(json['features'] as List? ?? []),
        isActive: json['isActive'] as bool? ?? true,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );
}
