import 'package:flutter/foundation.dart';
import '../models/get_all_categories_model.dart';
import '../models/get_sub_category_by_id_model.dart';
import '../repositories/categories_repository.dart';

class CategoriesController {
  final CategoriesRepository _repository = CategoriesRepository();

  Future<List<Datum>> fetchAllCategories() async {
    try {
      final model = await _repository.fetchCategories();
      if (model != null && model.status == 200 && model.data != null) {
        return model.data!;
      }
      return <Datum>[];
    } catch (e) {
      debugPrint('Error in CategoriesController: $e');
      return <Datum>[];
    }
  }

  Future<List<SubCategoryData>> fetchSubCategories(String categoryId) async {
    try {
      final model = await _repository.fetchSubCategories(categoryId);
      if (model != null && model.status == 200 && model.data != null && model.data!.subCategories != null) {
        return model.data!.subCategories!;
      }
      return <SubCategoryData>[];
    } catch (e) {
      debugPrint('Error in CategoriesController fetchSubCategories: $e');
      return <SubCategoryData>[];
    }
  }
}
