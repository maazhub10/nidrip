class SignupData {
  const SignupData({required this.id, required this.email});

  final String id;
  final String email;

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class SignupResponse {
  const SignupResponse({
    required this.status,
    required this.message,
    this.data,
    required this.ok,
  });

  final dynamic status;
  final String message;
  final SignupData? data;
  final bool ok;

  bool get isSuccess {
    if (status == 200 || status == 201) return true;
    if (status?.toString().toLowerCase() == 'success') return true;
    return ok == true;
  }

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    SignupData? parsedData;

    final rawData = json['data'] ?? json['user'];
    if (rawData is Map<String, dynamic>) {
      if (rawData['user'] is Map<String, dynamic>) {
        parsedData = SignupData.fromJson(rawData['user']);
      } else {
        parsedData = SignupData.fromJson(rawData);
      }
    }

    return SignupResponse(
      status: json['status'],
      message: json['message']?.toString() ?? '',
      data: parsedData,
      ok: json['ok'] == true,
    );
  }
}
