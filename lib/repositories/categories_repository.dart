import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/get_all_categories_model.dart';
import '../models/get_sub_category_by_id_model.dart';

class CategoriesRepository {
  String get _origin {
    var o = ApiConfig.baseUrl.trim();
    while (o.endsWith('/')) {
      o = o.substring(0, o.length - 1);
    }
    return o;
  }

  Future<GetAllCategoriesModel?> fetchCategories() async {
    final url = Uri.parse('$_origin/api/categories');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return getAllCategoriesModelFromJson(response.body);
      } else {
        debugPrint('Failed to load categories. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching categories in repo: $e');
      return null;
    }
  }

  Future<GetSubCategoryByIdModel?> fetchSubCategories(String categoryId) async {
    final url = Uri.parse('$_origin/api/categories/$categoryId/subcategories');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return getSubCategoryByIdModelFromJson(response.body);
      } else {
        debugPrint('Failed to load subcategories. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching subcategories in repo: $e');
      return null;
    }
  }
}
