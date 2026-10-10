import 'package:flutter/foundation.dart';
import '../repositories/cart_repository.dart';
import '../models/get_cart_items_model.dart';

class CartController {
  final CartRepository _repository = CartRepository();

  // ── Add to cart ──────────────────────────────────────────────────────────
  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final response = await _repository.addToCart(
        productId: productId,
        quantity: quantity,
      );
      return response['status'] == 200 || response['ok'] == true;
    } catch (e) {
      debugPrint('CartController.addToCart error: $e');
      return false;
    }
  }

  // ── Fetch cart items ──────────────────────────────────────────────────────
  Future<GetCartItemModel?> fetchCartItems() async {
    try {
      final response = await _repository.getCartItems();
      if (response['ok'] == true || response['status'] == 200) {
        return GetCartItemModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('CartController.fetchCartItems error: $e');
      return null;
    }
  }

  // ── Remove from cart ──────────────────────────────────────────────────────
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      final response = await _repository.removeFromCart(cartItemId);
      return response['status'] == 200 || response['ok'] == true;
    } catch (e) {
      debugPrint('CartController.removeFromCart error: $e');
      return false;
    }
  }

  // ── Update cart item quantity ─────────────────────────────────────────────
  Future<bool> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _repository.updateCartItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return response['status'] == 200 || response['ok'] == true;
    } catch (e) {
      debugPrint('CartController.updateCartItemQuantity error: $e');
      return false;
    }
  }
}
