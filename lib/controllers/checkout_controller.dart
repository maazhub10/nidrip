import 'package:get/get.dart';
import '../models/get_check_out_summary_model.dart';
import '../repositories/checkout_repo.dart';

class CheckoutController extends GetxController {
  final CheckoutRepo _repo = CheckoutRepo();

  var isLoading = true.obs;
  var checkoutSummary = Rxn<GetCheckoutSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    fetchCheckoutSummary();
  }

  Future<void> fetchCheckoutSummary() async {
    isLoading.value = true;
    try {
      final summary = await _repo.getCheckoutSummary();
      checkoutSummary.value = summary;
    } finally {
      isLoading.value = false;
    }
  }
}
