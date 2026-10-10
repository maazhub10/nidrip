import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../services/auth_storage.dart';

class ApiService {
  static String _origin() {
    var o = ApiConfig.baseUrl.trim();
    while (o.endsWith('/')) {
      o = o.substring(0, o.length - 1);
    }
    return o;
  }

  /// Shared headers (ngrok free tier returns an HTML warning page without this for some clients).
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  static Uri _uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${_origin()}$p');
  }

  static const String signupPath = '/api/auth/signup';
  static const String loginPath = '/api/auth/login';
  static const String verifyEmailPath = '/api/auth/verify-email';
  static const String resendOtpPath = '/api/auth/resend-otp';
  static const String forgotPasswordPath = '/api/auth/forgot-password';
  static const String resetPasswordPath = '/api/auth/reset-password';
  static const String addToCartPath = '/api/cart';
  static const String addAddressPath = '/api/addresses';

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
  }) async {
    final payload = {'email': email, 'password': password};

    debugPrint('📤 SIGNUP Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(signupPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 SIGNUP Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ SIGNUP Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final payload = {'email': email, 'password': password};

    debugPrint('📤 LOGIN Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(loginPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 LOGIN Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ LOGIN Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final payload = {'email': email, 'otp': otp};

    debugPrint('📤 VERIFY_EMAIL Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(verifyEmailPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 VERIFY_EMAIL Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ VERIFY_EMAIL Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final payload = {'email': email};

    debugPrint('📤 RESEND_OTP Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(resendOtpPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 RESEND_OTP Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ RESEND_OTP Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final payload = {'email': email};

    debugPrint('📤 FORGOT_PASSWORD Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(forgotPasswordPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 FORGOT_PASSWORD Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ FORGOT_PASSWORD Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    final payload = {'email': email, 'password': password};

    debugPrint('📤 RESET_PASSWORD Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        _uri(resetPasswordPath),
        headers: _headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 RESET_PASSWORD Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ RESET_PASSWORD Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    final payload = {'productId': productId, 'quantity': quantity};

    debugPrint('📤 ADD_TO_CART Payload: ${jsonEncode(payload)}');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        _uri(addToCartPath),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 ADD_TO_CART Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ ADD_TO_CART Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCartItems() async {
    debugPrint('📤 GET_CART_ITEMS Request');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        _uri(addToCartPath), // same path: /api/cart
        headers: headers,
      );

      debugPrint('📥 GET_CART_ITEMS Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ GET_CART_ITEMS Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    final path = '/api/cart/items/$cartItemId';
    debugPrint('📤 REMOVE_FROM_CART Request to $path');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        _uri(path),
        headers: headers,
      );

      debugPrint('📥 REMOVE_FROM_CART Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ REMOVE_FROM_CART Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final path = '/api/cart/items/$cartItemId';
    final payload = {'quantity': quantity};
    debugPrint('📤 UPDATE_CART_ITEM Payload: ${jsonEncode(payload)}');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        _uri(path),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 UPDATE_CART_ITEM Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ UPDATE_CART_ITEM Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required bool isDefault,
  }) async {
    final payload = {
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };

    debugPrint('📤 ADD_ADDRESS Payload: ${jsonEncode(payload)}');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        _uri(addAddressPath),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 ADD_ADDRESS Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ ADD_ADDRESS Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAddresses() async {
    debugPrint('📤 GET_ADDRESSES Request to $addAddressPath');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        _uri(addAddressPath),
        headers: headers,
      );

      debugPrint('📥 GET_ADDRESSES Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ GET_ADDRESSES Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {}
    }

    final httpOk = response.statusCode >= 200 && response.statusCode < 300;
    var ok = httpOk;

    if (body != null) {
      final explicitFail =
          body['ok'] == false ||
          body['success'] == false ||
          body['status'] == 'error' ||
          body['status'] == false ||
          (body['status'] is int && body['status'] >= 400);
      final explicitOk =
          body['ok'] == true ||
          body['success'] == true ||
          body['status'] == 'success';

      if (explicitFail) {
        ok = false;
      } else if (explicitOk) {
        ok = true;
      } else if (!httpOk) {
        ok = false;
      }
    } else if (!httpOk) {
      ok = false;
    }

    if (body != null) {
      final out = Map<String, dynamic>.from(body);
      out['ok'] = ok;
      if (ok && out['status'] == null) out['status'] = 'success';
      if (!ok && out['message'] == null) {
        out['message'] =
            body['error']?.toString() ??
            body['detail']?.toString() ??
            'Request failed (${response.statusCode})';
      }
      return out;
    }

    if (ok) return {'ok': true, 'status': 'success'};
    return {
      'ok': false,
      'status': false,
      'message': 'Server error: ${response.statusCode}',
    };
  }
  static Future<Map<String, dynamic>> createPaymentIntent({
    required String addressId,
  }) async {
    final path = '/api/checkout/create-payment-intent';
    final payload = {'addressId': addressId};
    debugPrint('📤 CREATE_PAYMENT_INTENT Payload: ${jsonEncode(payload)}');

    try {
      final token = await AuthStorage.getToken();
      final headers = Map<String, String>.from(_headers);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        _uri(path),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📥 CREATE_PAYMENT_INTENT Response: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      debugPrint('❌ CREATE_PAYMENT_INTENT Error: $e');
      return {'ok': false, 'status': false, 'message': 'Error: $e'};
    }
  }
}
