import 'package:dio/dio.dart';
import 'package:test_splash/core/error/failures.dart';

class OpenFoodFactsRemoteDataSource {
  final Dio dio;
  
  static const _fields = 'product_name,product_name_en,brands,image_front_small_url,image_url,nutriments,categories,food_groups,_id,code';

  OpenFoodFactsRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> searchFoods(String query, int page) async {
    try {
      final response = await dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'json': 1,
          'page': page,
          'page_size': 20,
          'fields': _fields,
          'lc': 'en',
          'action': 'process',
          'sort_by': 'unique_scans_n',
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerFailure("Server returned ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure();
      }
      throw ServerFailure(e.message ?? 'Unknown Dio error');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> getFoodDetails(String id) async {
    try {
      final response = await dio.get(
        'https://world.openfoodfacts.org/api/v2/product/$id',
        queryParameters: {'fields': _fields},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerFailure("Server returned ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerFailure("Product not found");
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure();
      }
      throw ServerFailure(e.message ?? 'Unknown Dio error');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
