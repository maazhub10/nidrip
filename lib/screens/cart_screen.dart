import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'all_products_screen.dart';
import '../controllers/cart_controller.dart';
import '../models/get_cart_items_model.dart';
import '../config/api_config.dart';
import 'address_list_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ─── Dependencies ────────────────────────────────────────────────────────
  final CartController _cartController = CartController();

  // ─── State ───────────────────────────────────────────────────────────────
  GetCartItemModel? cartModel;
  bool isLoading = true;

  /// cartItemId of the item whose DELETE icon shows a spinner.
  String? removingCartItemId;

  /// cartItemId of the item whose +/- counter shows a spinner.
  String? updatingCartItemId;

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // ─── Data Methods ────────────────────────────────────────────────────────

  Future<void> _fetchCartItems() async {
    setState(() => isLoading = true);
    try {
      final model = await _cartController.fetchCartItems();
      if (mounted) setState(() => cartModel = model);
    } catch (_) {
      _showSnackBar('Failed to load cart items', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateQuantity({
    required String cartItemId,
    required int currentQty,
    required int change,
  }) async {
    final newQty = currentQty + change;
    if (newQty < 1) return; // guard: never go below 1

    try {
      // Optimistic UI – update local model instantly for a snappy feel.
      _applyOptimisticQtyUpdate(cartItemId, newQty);

      final success = await _cartController.updateCartItemQuantity(
        cartItemId: cartItemId,
        quantity: newQty,
      );

      if (!success) {
        // Rollback on failure
        _applyOptimisticQtyUpdate(cartItemId, currentQty);
        _showSnackBar('Could not update quantity', isError: true);
      }
    } catch (_) {
      _applyOptimisticQtyUpdate(cartItemId, currentQty);
      _showSnackBar('Error updating quantity', isError: true);
    }
  }

  /// Mutates the local cartModel in-place so the UI updates without a
  /// full network round-trip for every +/- tap.
  void _applyOptimisticQtyUpdate(String cartItemId, int newQty) {
    if (!mounted) return;
    setState(() {
      final items = cartModel?.data?.items;
      if (items == null) return;
      for (final item in items) {
        if (item.id == cartItemId) {
          item.quantity = newQty;
          if (item.price != null) item.subtotal = item.price! * newQty;
          break;
        }
      }
      // Recalculate totals locally
      double newTotal = 0;
      int newCount = 0;
      for (final item in items) {
        newTotal += item.subtotal ?? 0;
        newCount += item.quantity ?? 0;
      }
      cartModel?.data?.totalPrice = newTotal;
      cartModel?.data?.totalItems = newCount;
    });
  }

  /// DELETE /api/cart/items/:cartItemId
  Future<void> _removeCartItem(String cartItemId) async {
    setState(() => removingCartItemId = cartItemId);
    try {
      final success = await _cartController.removeFromCart(cartItemId);
      if (success) {
        _showSnackBar('Item removed from cart');
        await _fetchCartItems();
      } else {
        _showSnackBar('Failed to remove item', isError: true);
      }
    } catch (_) {
      _showSnackBar('Error removing item', isError: true);
    } finally {
      if (mounted) setState(() => removingCartItemId = null);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    String origin = ApiConfig.baseUrl.trim();
    while (origin.endsWith('/')) {
      origin = origin.substring(0, origin.length - 1);
    }
    return path.startsWith('http')
        ? path
        : (path.startsWith('/') ? '$origin$path' : '$origin/$path');
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE8184D);
    const bgColor = Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (cartModel?.data?.totalItems != null &&
                cartModel!.data!.totalItems! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cartModel!.data!.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _fetchCartItems,
        child: isLoading ? _buildShimmer() : _buildCartBody(primaryColor),
      ),
      bottomNavigationBar:
          isLoading || (cartModel?.data?.items?.isEmpty ?? true)
              ? null
              : _buildBottomNav(primaryColor),
    );
  }

  // ─── Cart Body ────────────────────────────────────────────────────────────

  Widget _buildCartBody(Color primaryColor) {
    final items = cartModel?.data?.items ?? [];

    if (items.isEmpty) return _buildEmptyState(primaryColor);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildOrderSummary();
        }
        return _buildCartItem(items[index], primaryColor);
      },
    );
  }

  Widget _buildCartItem(Item item, Color primaryColor) {
    final product = item.product;
    if (product == null) return const SizedBox.shrink();

    final imageUrl = _buildImageUrl(product.image);
    final cartItemId = item.id ?? '';
    final isRemoving = removingCartItemId == cartItemId;
    final isUpdatingQty = updatingCartItemId == cartItemId;
    final qty = item.quantity ?? 1;
    final isBusy = isRemoving || isUpdatingQty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Image ────────────────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                Uri.encodeFull(imageUrl),
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Details ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.category ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey, // 11px muted
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (product.rating != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 11, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  product.name ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500, // 14px medium
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Price
                Text(
                  '£${item.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // #E8184D
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom row: stepper + subtotal (left), trash (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stepper + Subtotal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill Stepper
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100, // gray bg
                            borderRadius: BorderRadius.circular(14), // pill
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap:
                                    isBusy
                                        ? null
                                        : () => _updateQuantity(
                                          cartItemId: cartItemId,
                                          currentQty: qty,
                                          change: -1,
                                        ),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color:
                                        qty <= 1
                                            ? Colors.grey.shade400
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              InkWell(
                                onTap:
                                    isBusy
                                        ? null
                                        : () => _updateQuantity(
                                          cartItemId: cartItemId,
                                          currentQty: qty,
                                          change: 1,
                                        ),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(14),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtotal
                        Text(
                          'Subtotal: £${item.subtotal?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey, // 11px muted
                          ),
                        ),
                      ],
                    ),

                    // Trash button
                    isRemoving
                        ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          ),
                        )
                        : Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50, // soft red bg
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            onPressed:
                                isBusy
                                    ? null
                                    : () => _removeCartItem(cartItemId),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Order Summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    final total = cartModel?.data?.totalPrice ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Subtotal', '£${total.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Delivery',
            'Free',
            valueColor: Colors.green.shade600,
            valueFontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Save',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 14,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '£0.00',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '£${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? Colors.black87,
            fontWeight: valueFontWeight ?? FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Looks like you haven't added\nanything to your cart yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllProductsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddressListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
    );
  }
}
