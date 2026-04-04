/// Category model for products and vendor shops
class CategoryModel {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? svgIcon;
  final int? productsCount;
  final List<SubcategoryModel>? subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.svgIcon,
    this.productsCount,
    this.subcategories,
  });

  /// Create from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      svgIcon: json['svg_icon'] as String?,
      productsCount: json['products_count'] as int?,
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
              .map((sub) => SubcategoryModel.fromJson(sub))
              .toList()
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'description': description,
      'svg_icon': svgIcon,
      'products_count': productsCount,
      'subcategories': subcategories?.map((sub) => sub.toJson()).toList(),
    };
  }
}

/// Subcategory model
class SubcategoryModel {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final int? productsCount;

  SubcategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.productsCount,
  });

  /// Create from JSON
  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      slug: json['slug'] as String,
      productsCount: json['products_count'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'products_count': productsCount,
    };
  }
}
