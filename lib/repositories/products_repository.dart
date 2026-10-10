import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/get_all_products_model.dart';
import '../models/get_products_sub_category_id_model.dart';
import '../models/get_product_details_by_id_model.dart';
import '../services/auth_storage.dart';

class ProductsRepository {
  String get _origin {
    var o = ApiConfig.baseUrl.trim();
    while (o.endsWith('/')) {
      o = o.substring(0, o.length - 1);
    }
    return o;
  }

  Future<GetAllProductsModel?> fetchProducts() async {
    final url = Uri.parse('$_origin/api/products');
    
    final token = await AuthStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return getAllProductsModelFromJson(response.body);
      } else {
        debugPrint(
          'Failed to load products. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching products in repo: $e');
      return null;
    }
  }

  Future<GetProductsBySubCateforyIdModel?> fetchProductsBySubCategory(String subCategoryId) async {
    final url = Uri.parse('$_origin/api/products?subCategoryId=$subCategoryId');
    
    final token = await AuthStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return getProductsBySubCateforyIdModelFromJson(response.body);
      } else {
        debugPrint('Failed to load subcat products. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching subcat products in repo: $e');
      return null;
    }
  }

  Future<GetProductsDetailsByIdModel?> fetchProductDetails(String productId) async {
    final url = Uri.parse('$_origin/api/products/$productId');
    
    final token = await AuthStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return getProductsDetailsByIdModelFromJson(response.body);
      } else {
        debugPrint('Failed to load product details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product details in repo: $e');
      return null;
    }
  }
}
