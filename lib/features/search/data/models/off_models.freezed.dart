// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'off_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OffProduct {

@JsonKey(name: '_id') String? get id;@JsonKey(name: 'code') String? get code;@JsonKey(name: 'product_name') String? get productName;@JsonKey(name: 'product_name_en') String? get productNameEn;@JsonKey(name: 'brands') String? get brands;@JsonKey(name: 'image_front_small_url') String? get imageFrontSmallUrl;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'categories') String? get categories;@JsonKey(name: 'nutriments') Map<String, dynamic>? get nutriments;
/// Create a copy of OffProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OffProductCopyWith<OffProduct> get copyWith => _$OffProductCopyWithImpl<OffProduct>(this as OffProduct, _$identity);

  /// Serializes this OffProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OffProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productNameEn, productNameEn) || other.productNameEn == productNameEn)&&(identical(other.brands, brands) || other.brands == brands)&&(identical(other.imageFrontSmallUrl, imageFrontSmallUrl) || other.imageFrontSmallUrl == imageFrontSmallUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categories, categories) || other.categories == categories)&&const DeepCollectionEquality().equals(other.nutriments, nutriments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,productName,productNameEn,brands,imageFrontSmallUrl,imageUrl,categories,const DeepCollectionEquality().hash(nutriments));

@override
String toString() {
  return 'OffProduct(id: $id, code: $code, productName: $productName, productNameEn: $productNameEn, brands: $brands, imageFrontSmallUrl: $imageFrontSmallUrl, imageUrl: $imageUrl, categories: $categories, nutriments: $nutriments)';
}


}

/// @nodoc
abstract mixin class $OffProductCopyWith<$Res>  {
  factory $OffProductCopyWith(OffProduct value, $Res Function(OffProduct) _then) = _$OffProductCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String? id,@JsonKey(name: 'code') String? code,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_name_en') String? productNameEn,@JsonKey(name: 'brands') String? brands,@JsonKey(name: 'image_front_small_url') String? imageFrontSmallUrl,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'categories') String? categories,@JsonKey(name: 'nutriments') Map<String, dynamic>? nutriments
});




}
/// @nodoc
class _$OffProductCopyWithImpl<$Res>
    implements $OffProductCopyWith<$Res> {
  _$OffProductCopyWithImpl(this._self, this._then);

  final OffProduct _self;
  final $Res Function(OffProduct) _then;

/// Create a copy of OffProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? code = freezed,Object? productName = freezed,Object? productNameEn = freezed,Object? brands = freezed,Object? imageFrontSmallUrl = freezed,Object? imageUrl = freezed,Object? categories = freezed,Object? nutriments = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productNameEn: freezed == productNameEn ? _self.productNameEn : productNameEn // ignore: cast_nullable_to_non_nullable
as String?,brands: freezed == brands ? _self.brands : brands // ignore: cast_nullable_to_non_nullable
as String?,imageFrontSmallUrl: freezed == imageFrontSmallUrl ? _self.imageFrontSmallUrl : imageFrontSmallUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as String?,nutriments: freezed == nutriments ? _self.nutriments : nutriments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [OffProduct].
extension OffProductPatterns on OffProduct {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OffProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OffProduct() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OffProduct value)  $default,){
final _that = this;
switch (_that) {
case _OffProduct():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OffProduct value)?  $default,){
final _that = this;
switch (_that) {
case _OffProduct() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? id, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_name_en')  String? productNameEn, @JsonKey(name: 'brands')  String? brands, @JsonKey(name: 'image_front_small_url')  String? imageFrontSmallUrl, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'categories')  String? categories, @JsonKey(name: 'nutriments')  Map<String, dynamic>? nutriments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OffProduct() when $default != null:
return $default(_that.id,_that.code,_that.productName,_that.productNameEn,_that.brands,_that.imageFrontSmallUrl,_that.imageUrl,_that.categories,_that.nutriments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? id, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_name_en')  String? productNameEn, @JsonKey(name: 'brands')  String? brands, @JsonKey(name: 'image_front_small_url')  String? imageFrontSmallUrl, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'categories')  String? categories, @JsonKey(name: 'nutriments')  Map<String, dynamic>? nutriments)  $default,) {final _that = this;
switch (_that) {
case _OffProduct():
return $default(_that.id,_that.code,_that.productName,_that.productNameEn,_that.brands,_that.imageFrontSmallUrl,_that.imageUrl,_that.categories,_that.nutriments);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String? id, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_name_en')  String? productNameEn, @JsonKey(name: 'brands')  String? brands, @JsonKey(name: 'image_front_small_url')  String? imageFrontSmallUrl, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'categories')  String? categories, @JsonKey(name: 'nutriments')  Map<String, dynamic>? nutriments)?  $default,) {final _that = this;
switch (_that) {
case _OffProduct() when $default != null:
return $default(_that.id,_that.code,_that.productName,_that.productNameEn,_that.brands,_that.imageFrontSmallUrl,_that.imageUrl,_that.categories,_that.nutriments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OffProduct implements OffProduct {
  const _OffProduct({@JsonKey(name: '_id') this.id, @JsonKey(name: 'code') this.code, @JsonKey(name: 'product_name') this.productName, @JsonKey(name: 'product_name_en') this.productNameEn, @JsonKey(name: 'brands') this.brands, @JsonKey(name: 'image_front_small_url') this.imageFrontSmallUrl, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'categories') this.categories, @JsonKey(name: 'nutriments') final  Map<String, dynamic>? nutriments}): _nutriments = nutriments;
  factory _OffProduct.fromJson(Map<String, dynamic> json) => _$OffProductFromJson(json);

@override@JsonKey(name: '_id') final  String? id;
@override@JsonKey(name: 'code') final  String? code;
@override@JsonKey(name: 'product_name') final  String? productName;
@override@JsonKey(name: 'product_name_en') final  String? productNameEn;
@override@JsonKey(name: 'brands') final  String? brands;
@override@JsonKey(name: 'image_front_small_url') final  String? imageFrontSmallUrl;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'categories') final  String? categories;
 final  Map<String, dynamic>? _nutriments;
@override@JsonKey(name: 'nutriments') Map<String, dynamic>? get nutriments {
  final value = _nutriments;
  if (value == null) return null;
  if (_nutriments is EqualUnmodifiableMapView) return _nutriments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of OffProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OffProductCopyWith<_OffProduct> get copyWith => __$OffProductCopyWithImpl<_OffProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OffProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OffProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productNameEn, productNameEn) || other.productNameEn == productNameEn)&&(identical(other.brands, brands) || other.brands == brands)&&(identical(other.imageFrontSmallUrl, imageFrontSmallUrl) || other.imageFrontSmallUrl == imageFrontSmallUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categories, categories) || other.categories == categories)&&const DeepCollectionEquality().equals(other._nutriments, _nutriments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,productName,productNameEn,brands,imageFrontSmallUrl,imageUrl,categories,const DeepCollectionEquality().hash(_nutriments));

@override
String toString() {
  return 'OffProduct(id: $id, code: $code, productName: $productName, productNameEn: $productNameEn, brands: $brands, imageFrontSmallUrl: $imageFrontSmallUrl, imageUrl: $imageUrl, categories: $categories, nutriments: $nutriments)';
}


}

/// @nodoc
abstract mixin class _$OffProductCopyWith<$Res> implements $OffProductCopyWith<$Res> {
  factory _$OffProductCopyWith(_OffProduct value, $Res Function(_OffProduct) _then) = __$OffProductCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String? id,@JsonKey(name: 'code') String? code,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_name_en') String? productNameEn,@JsonKey(name: 'brands') String? brands,@JsonKey(name: 'image_front_small_url') String? imageFrontSmallUrl,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'categories') String? categories,@JsonKey(name: 'nutriments') Map<String, dynamic>? nutriments
});




}
/// @nodoc
class __$OffProductCopyWithImpl<$Res>
    implements _$OffProductCopyWith<$Res> {
  __$OffProductCopyWithImpl(this._self, this._then);

  final _OffProduct _self;
  final $Res Function(_OffProduct) _then;

/// Create a copy of OffProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? code = freezed,Object? productName = freezed,Object? productNameEn = freezed,Object? brands = freezed,Object? imageFrontSmallUrl = freezed,Object? imageUrl = freezed,Object? categories = freezed,Object? nutriments = freezed,}) {
  return _then(_OffProduct(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productNameEn: freezed == productNameEn ? _self.productNameEn : productNameEn // ignore: cast_nullable_to_non_nullable
as String?,brands: freezed == brands ? _self.brands : brands // ignore: cast_nullable_to_non_nullable
as String?,imageFrontSmallUrl: freezed == imageFrontSmallUrl ? _self.imageFrontSmallUrl : imageFrontSmallUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as String?,nutriments: freezed == nutriments ? _self._nutriments : nutriments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
