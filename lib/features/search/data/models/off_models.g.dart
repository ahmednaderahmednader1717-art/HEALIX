// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'off_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OffProduct _$OffProductFromJson(Map<String, dynamic> json) => _OffProduct(
  id: json['_id'] as String?,
  code: json['code'] as String?,
  productName: json['product_name'] as String?,
  productNameEn: json['product_name_en'] as String?,
  brands: json['brands'] as String?,
  imageFrontSmallUrl: json['image_front_small_url'] as String?,
  imageUrl: json['image_url'] as String?,
  categories: json['categories'] as String?,
  nutriments: json['nutriments'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$OffProductToJson(_OffProduct instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'code': instance.code,
      'product_name': instance.productName,
      'product_name_en': instance.productNameEn,
      'brands': instance.brands,
      'image_front_small_url': instance.imageFrontSmallUrl,
      'image_url': instance.imageUrl,
      'categories': instance.categories,
      'nutriments': instance.nutriments,
    };
