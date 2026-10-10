import '../repositories/address_repository.dart';

class AddressController {
  final AddressRepository _repository = AddressRepository();

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
    return await _repository.addAddress(
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
  }

  Future<Map<String, dynamic>> getAddresses() async {
    return await _repository.getAddresses();
  }
}
