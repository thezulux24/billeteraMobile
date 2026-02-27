import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryApi {
  CategoryApi(this._dio);

  final Dio _dio;

  Future<List<Category>> listCategories() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/categories');
    final rows = response.data ?? <dynamic>[];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList(growable: false);
  }

  Future<Category> createCategory({
    required String name,
    required CategoryKind kind,
    String? color,
    String? icon,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/categories',
      data: {'name': name, 'kind': kind.name, 'color': color, 'icon': icon},
    );
    return Category.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteCategory(String categoryId) async {
    await _dio.delete<Map<String, dynamic>>('/api/v1/categories/$categoryId');
  }
}
