// models/product_type.dart
class ProductType {
  final int id;
  final String description;
  final int? confeitariaId;

  ProductType({
    required this.id,
    required this.description,
    this.confeitariaId,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id_tipo_produto'],
      description: json['desc_tipo_produto'],
      confeitariaId: json['id_confeitaria'],
    );
  }
}

// models/product.dart
class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final double shipping;
  final bool isActive;
  final int deliveryLimit;
  final String? imagePath;
  final int productTypeId;
  final int? confeitariaId;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.shipping,
    this.isActive = true,
    required this.deliveryLimit,
    this.imagePath,
    required this.productTypeId,
    this.confeitariaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome_produto': name,
      'desc_produto': description,
      'valor_produto': price,
      'frete': shipping,
      'produto_ativo': isActive ? 1 : 0,
      'limite_entrega': deliveryLimit,
      'img_produto': imagePath ?? '',
      'id_tipo_produto': productTypeId,
      'id_confeitaria': confeitariaId,
    };
  }
}