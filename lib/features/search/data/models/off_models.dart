import 'package:freezed_annotation/freezed_annotation.dart';

part 'off_models.freezed.dart';
part 'off_models.g.dart';

@freezed
abstract class OffProduct with _$OffProduct {
  const factory OffProduct({
    @JsonKey(name: '_id') String? id,
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'product_name_en') String? productNameEn,
    @JsonKey(name: 'brands') String? brands,
    @JsonKey(name: 'image_front_small_url') String? imageFrontSmallUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'categories') String? categories,
    @JsonKey(name: 'nutriments') Map<String, dynamic>? nutriments,
  }) = _OffProduct;

  factory OffProduct.fromJson(Map<String, dynamic> json) => _$OffProductFromJson(json);
}
