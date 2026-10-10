import '../api/api_service.dart';

class AddressRepository {
  Future<Map<String, dynamic>> addAddress({
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
    final response = await ApiService.addAddress(
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
    );

    return response;
  }

  Future<Map<String, dynamic>> getAddresses() async {
    return await ApiService.getAddresses();
  }
}
