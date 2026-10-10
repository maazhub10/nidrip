import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../models/get_product_details_by_id_model.dart';
import '../controllers/products_controller.dart';
import '../controllers/cart_controller.dart';
import '../config/api_config.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // ─── Dependencies ────────────────────────────────────────────────────────
  final ProductsController _productsController = ProductsController();
  final CartController _cartController = CartController();

  // ─── State ───────────────────────────────────────────────────────────────
  ProductDetailsData? product;
  bool isLoading = true;
  bool isAddingToCart = false;
  int selectedQty = 1;

  static const Color primaryColor = Color(0xFFFD215C);

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  // ─── Data Methods ────────────────────────────────────────────────────────

  Future<void> _fetchDetails() async {
    setState(() => isLoading = true);
    final data = await _productsController.fetchProductDetails(
      widget.productId,
    );
    if (mounted) {
      setState(() {
        product = data;
        isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (product?.id == null) return;
    setState(() => isAddingToCart = true);

    try {
      final success = await _cartController.addToCart(
        product!.id!,
        selectedQty,
      );
      if (success) {
        _showSnackBar('Added $selectedQty × "${product!.name}" to cart 🛒');
        // Reset quantity back to 1 after successful add
        setState(() => selectedQty = 1);
      } else {
        _showSnackBar('Failed to add to cart', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
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
                style: GoogleFonts.inter(
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _fetchDetails,
        child: isLoading ? _buildShimmerLoading() : _buildContent(),
      ),
      bottomNavigationBar:
          isLoading || product == null ? null : _buildBottomBar(),
    );
  }

  // ─── Content ──────────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Product not found.',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final imageUrl = _buildImageUrl(product?.image);
    String formattedDate = '';
    if (product?.createdAt != null) {
      formattedDate = DateFormat.yMMMMd().format(product!.createdAt!);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 320,
            color: Colors.grey.shade50,
            child: Stack(
              children: [
                Center(
                  child: Image.network(
                    Uri.encodeFull(imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade300,
                          size: 80,
                        ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey.shade600,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Details Section ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                Row(
                  children: [
                    if (product?.category != null)
                      _buildTag(product!.category!),
                    if (product?.category != null &&
                        product?.subCategory != null)
                      const SizedBox(width: 8),
                    if (product?.subCategory != null)
                      _buildTag(product!.subCategory!, isPrimary: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Name & Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product?.name ?? 'Unknown Product',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '£${product?.price ?? "0"}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating & date
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product?.rating ?? 4.8}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Listed: $formattedDate',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Quantity Selector ────────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Minus button
                    _buildQtyButton(
                      icon: Icons.remove,
                      onTap:
                          selectedQty > 1
                              ? () => setState(() => selectedQty--)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$selectedQty',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Plus button
                    _buildQtyButton(
                      icon: Icons.add,
                      onTap: () => setState(() => selectedQty++),
                      isPrimary: true,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Description
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product?.description ??
                      'No description available for this product.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final unitPrice = product?.price ?? 0;
    final totalPrice = unitPrice * selectedQty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total price summary
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  '£${totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Add to Cart button
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isAddingToCart ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryColor.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      isAddingToCart
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_shopping_cart, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Add to Cart',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              enabled
                  ? (isPrimary ? primaryColor : Colors.white)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                enabled
                    ? (isPrimary ? primaryColor : Colors.grey.shade300)
                    : Colors.grey.shade200,
          ),
          boxShadow:
              enabled
                  ? [
                    BoxShadow(
                      color: (isPrimary ? primaryColor : Colors.black)
                          .withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              enabled
                  ? (isPrimary ? Colors.white : Colors.black87)
                  : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPrimary ? primaryColor : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 320, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 80, height: 24, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 100, height: 24, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 150, height: 32, color: Colors.white),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
