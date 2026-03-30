class ProductSpecModel {
  final String id;
  final String label;
  final List<String> options;
  const ProductSpecModel({required this.id, required this.label, required this.options});
  factory ProductSpecModel.fromJson(Map<String, dynamic> json) => ProductSpecModel(
        id: json['id'] as String,
        label: json['label'] as String,
        options: List<String>.from(json['options'] as List),
      );
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  const CategoryModel({required this.id, required this.name, required this.slug, this.imageUrl});
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        imageUrl: json['imageUrl'] as String?,
      );
}

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String category;
  final double startingPrice;
  final String priceUnit;
  final String? imageUrl;
  final List<String> images;
  final bool isFeatured;
  final bool isActive;
  final List<ProductSpecModel> specs;

  const ProductModel({
    required this.id, required this.name, required this.slug,
    required this.description, required this.category,
    required this.startingPrice, required this.priceUnit,
    this.imageUrl, required this.images, required this.isFeatured,
    required this.isActive, required this.specs,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        startingPrice: (json['startingPrice'] as num).toDouble(),
        priceUnit: json['priceUnit'] as String? ?? 'custom quote',
        imageUrl: json['imageUrl'] as String?,
        images: List<String>.from(json['images'] as List? ?? []),
        isFeatured: json['isFeatured'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        specs: (json['specs'] as List<dynamic>? ?? [])
            .map((e) => ProductSpecModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get displayImage => imageUrl ?? (images.isNotEmpty ? images.first : '');

  String get formattedPrice => startingPrice > 0
      ? 'PKR ${startingPrice.toStringAsFixed(0)} / $priceUnit'
      : 'Custom Quote';
}
