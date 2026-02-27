import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/category_api.dart';
import '../models/category.dart';

final categoryNotifierProvider = ChangeNotifierProvider<CategoryNotifier>((
  ref,
) {
  return CategoryNotifier(categoryApi: ref.read(categoryApiProvider));
});

class CategoryNotifier extends ChangeNotifier {
  CategoryNotifier({required CategoryApi categoryApi})
    : _categoryApi = categoryApi;

  final CategoryApi _categoryApi;

  List<Category> _categories = <Category>[];
  bool _loading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryApi.listCategories();
    } on DioException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required CategoryKind kind,
    String? color,
    String? icon,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final created = await _categoryApi.createCategory(
        name: name,
        kind: kind,
        color: color,
        icon: icon,
      );
      _categories = [..._categories, created];
      notifyListeners();
      return true;
    } on DioException catch (error) {
      _error = error.message;
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    }
  }
}
