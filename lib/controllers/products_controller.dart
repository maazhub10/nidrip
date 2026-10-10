import 'package:flutter/foundation.dart';
import '../models/get_all_products_model.dart';
import '../models/get_products_sub_category_id_model.dart';
import '../models/get_product_details_by_id_model.dart';
import '../repositories/products_repository.dart';

class ProductsController {
  final ProductsRepository _repository = ProductsRepository();

  Future<List<ProductData>> fetchProducts() async {
    try {
      final model = await _repository.fetchProducts();
      if (model != null && (model.status == 200 || model.status == 201) && model.data != null) {
        return model.data!;
      }
      return <ProductData>[];
    } catch (e) {
      debugPrint('Error in ProductsController: $e');
      return <ProductData>[];
    }
  }

  Future<List<SubCategoryProductData>> fetchProductsBySubCategory(String subCategoryId) async {
    try {
      final model = await _repository.fetchProductsBySubCategory(subCategoryId);
      if (model != null && (model.status == 200 || model.status == 201) && model.data != null) {
        return model.data!;
      }
      return <SubCategoryProductData>[];
    } catch (e) {
      debugPrint('Error fetching subcategory products in ProductsController: $e');
      return <SubCategoryProductData>[];
    }
  }

  Future<ProductDetailsData?> fetchProductDetails(String productId) async {
    try {
      final model = await _repository.fetchProductDetails(productId);
      if (model != null && (model.status == 200 || model.status == 201) && model.data != null) {
        return model.data!;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product details in ProductsController: $e');
      return null;
    }
  }
}
