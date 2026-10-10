import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/get_list_address_model.dart';
import '../controllers/address_controller.dart';
import '../controllers/payment_controller.dart';
import 'add_address_screen.dart';
import 'checkout_summary_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final AddressController _addressController = AddressController();
  final PaymentController _paymentController = PaymentController();

  bool _isLoadingAddresses = true;
  List<Address> _previousAddresses = [];
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final response = await _addressController.getAddresses();
      if (response['ok'] == true || response['success'] == true) {
        final model = GetListAddressModel.fromJson(response);
        if (mounted) {
          setState(() {
            _previousAddresses = model.addresses ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  void _selectAddress(Address address) {
    if (address.id == null) return;
    _showPaymentDialog(address.id!);
  }

  void _showPaymentDialog(String addressId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Proceed to Payment',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Would you like to proceed with the payment for this address now?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _startPaymentProcess(addressId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD215C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Yes, Proceed',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startPaymentProcess(String addressId) async {
    setState(() => _isProcessingPayment = true);

    final paymentSuccess = await _paymentController.processPayment(
      context: context,
      addressId: addressId,
    );

    setState(() => _isProcessingPayment = false);

    if (paymentSuccess) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CheckoutSummaryScreen()),
        );
      }
    } else {
      _showSnackBar('Payment failed or cancelled', isError: true);
    }
  }

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

  Widget _buildShimmerAddresses() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
        title: Text(
          'Select Address',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAddressScreen(),
                ),
              );
            },
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                color: const Color(0xFFFD215C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: _isProcessingPayment
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFD215C),
              ),
            )
          : _isLoadingAddresses
              ? _buildShimmerAddresses()
              : _previousAddresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No previous addresses found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddAddressScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFD215C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Add New Address',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _previousAddresses.length,
                      itemBuilder: (context, index) {
                        final address = _previousAddresses[index];
                        return GestureDetector(
                          onTap: () => _selectAddress(address),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xFFFD215C), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        address.fullName ?? '',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 36),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${address.addressLine1}, ${address.city}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${address.state}, ${address.country}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        address.phone ?? '',
                                        style: GoogleFonts.inter(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
