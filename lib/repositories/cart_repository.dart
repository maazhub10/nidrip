import '../api/api_service.dart';

class CartRepository {
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    return await ApiService.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }

  Future<Map<String, dynamic>> getCartItems() async {
    return await ApiService.getCartItems();
  }

  Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    return await ApiService.removeFromCart(cartItemId);
  }

  Future<Map<String, dynamic>> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    return await ApiService.updateCartItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
