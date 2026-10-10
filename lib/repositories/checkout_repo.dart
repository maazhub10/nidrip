import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/get_check_out_summary_model.dart';
import '../services/auth_storage.dart';

class CheckoutRepo {
  Future<GetCheckoutSummaryModel?> getCheckoutSummary() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/checkout/summary');
      
      final token = await AuthStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedData = getCheckoutSummaryModelFromJson(response.body);
        if (parsedData.success == true) {
          return parsedData;
        }
      }
      return null;
    } catch (e) {
      print('CheckoutRepo.getCheckoutSummary error: $e');
      return null;
    }
  }
}
