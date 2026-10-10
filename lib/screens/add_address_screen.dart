import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import '../controllers/address_controller.dart';
import '../controllers/payment_controller.dart';
import 'checkout_summary_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressController _addressController = AddressController();
  final PaymentController _paymentController = PaymentController();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? countryValue;
  String? stateValue;
  String? cityValue;

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (countryValue == null) {
      _showSnackBar('Please select your country', isError: true);
      return;
    }
    if (stateValue == null) {
      _showSnackBar('Please select your state', isError: true);
      return;
    }
    if (cityValue == null) {
      _showSnackBar('Please select your city', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final response = await _addressController.addAddress(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      city: cityValue!,
      state: stateValue!,
      postalCode: _postalCodeController.text.trim(),
      country: countryValue!,
      isDefault: true,
    );

    setState(() => _isLoading = false);

    final success = response['ok'] == true || response['success'] == true;

    if (success) {
      _showSnackBar('Address added successfully!');

      // Try to extract address ID from common response structures
      final addressId =
          response['_id']?.toString() ??
          response['data']?['_id']?.toString() ??
          response['address']?['_id']?.toString() ??
          response['data']?['id']?.toString() ??
          response['id']?.toString();

      if (addressId == null || addressId.isEmpty) {
        _showSnackBar('Could not find address ID in response', isError: true);
        return;
      }

      if (mounted) {
        _showPaymentDialog(addressId);
      }
    } else {
      _showSnackBar(
        response['message'] ?? 'Failed to add address',
        isError: true,
      );
    }
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
            'Your address has been saved. Would you like to proceed with the payment now?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to cart
              },
              child: Text(
                'Later',
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
    setState(() => _isLoading = true);

    final paymentSuccess = await _paymentController.processPayment(
      context: context,
      addressId: addressId,
    );

    setState(() => _isLoading = false);

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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 250, 97, 138),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
      ),
    );
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Address',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Full Name', _fullNameController),
                _buildTextField(
                  'Phone Number',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField('Address Line 1', _addressLine1Controller),
                _buildTextField('Address Line 2', _addressLine2Controller),

                const SizedBox(height: 8),
                CSCPickerPlus(
                  showStates: true,
                  showCities: true,
                  flagState: CountryFlag.DISABLE,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  disabledDropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  countrySearchPlaceholder: "Search Country",
                  stateSearchPlaceholder: "Search State",
                  citySearchPlaceholder: "Search City",
                  countryDropdownLabel: "Country",
                  stateDropdownLabel: "State",
                  cityDropdownLabel: "City",
                  selectedItemStyle: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  dropdownHeadingStyle: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  dropdownItemStyle: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  searchBarRadius: 10.0,
                  onCountryChanged: (value) {
                    setState(() {
                      countryValue = value;
                    });
                  },
                  onStateChanged: (value) {
                    setState(() {
                      stateValue = value;
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      cityValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  'Postal Code',
                  _postalCodeController,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          250,
                          97,
                          138,
                        ).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Text(
                              'Add Address',
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
          ),
        ),
      ),
    );
  }
}
