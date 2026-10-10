import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../controllers/checkout_controller.dart';
import '../config/api_config.dart';
import 'home_screen.dart';

class CheckoutSummaryScreen extends StatelessWidget {
  CheckoutSummaryScreen({super.key});

  final CheckoutController _controller = Get.put(CheckoutController());

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

  @override
  Widget build(BuildContext context) {
    const primaryGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 250, 97, 138),
        Color.fromARGB(255, 210, 77, 175),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Booking Confirmed',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          final summary = _controller.checkoutSummary.value?.summary;
          final currencyStr = summary?.currency?.toLowerCase() ?? 'usd';
          final currency = currencyStr == 'eur' ? '€' : (currencyStr == 'gbp' ? '£' : '\$');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Success Icon Animation
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF43A047),
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Payment Successful!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed and is being processed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // Order Summary Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 32),
                      
                      if (summary?.items != null)
                        ...summary!.items!.map((item) {
                           final product = item.product;
                           final imageUrl = _buildImageUrl(product?.image);
                           return Padding(
                             padding: const EdgeInsets.only(bottom: 16),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                  // Image
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        Uri.encodeFull(imageUrl),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product?.name ?? 'Unknown Product',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$currency${item.price?.toStringAsFixed(2) ?? '0.00'} x ${item.quantity}',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Line Total
                                  Text(
                                    "$currency${item.lineTotal?.toStringAsFixed(2) ?? '0.00'}",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700, 
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                               ],
                             ),
                           );
                        }),
                      
                      const Divider(height: 32),

                      _buildSummaryRow('Date', DateFormat('MMMM dd, yyyy').format(DateTime.now())),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Payment Method', 'Credit Card (Stripe)'),

                      const Divider(height: 32),

                      _buildSummaryRow('Subtotal', '$currency${summary?.subtotal?.toStringAsFixed(2) ?? '0.00'}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Shipping Fee', '$currency${summary?.shippingFee?.toStringAsFixed(2) ?? '0.00'}'),
                      if (summary?.shippingFee != null && summary!.shippingFee! > 0 && summary.freeShippingThreshold != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Free shipping for orders over $currency${summary.freeShippingThreshold?.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '$currency${summary?.total?.toStringAsFixed(2) ?? '0.00'}',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: const Color.fromARGB(255, 250, 97, 138),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Continue Shopping Button
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 250, 97, 138).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
