import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../api/api_service.dart';

class PaymentController {
  Future<bool> processPayment({
    required BuildContext context,
    required String addressId,
  }) async {
    try {
      // 1. Create Payment Intent on the backend
      final response = await ApiService.createPaymentIntent(addressId: addressId);

      if (response['ok'] != true && response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create payment intent');
      }

      final clientSecret = response['clientSecret'];
      final paymentIntentId = response['paymentIntentId'];
      final summary = response['summary'];

      if (clientSecret == null) {
        throw Exception('Client secret is missing from the response');
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Ni Drip',
          // You can customize the appearance here
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFD215C),
            ),
          ),
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If we get here, payment was successful
      return true;
    } on StripeException catch (e) {
      debugPrint('Stripe Error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('Payment Error: $e');
      return false;
    }
  }
}
