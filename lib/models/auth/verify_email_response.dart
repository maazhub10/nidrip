import 'signup_response.dart';

class VerifyEmailResponse {
  const VerifyEmailResponse({
    required this.status,
    required this.message,
    required this.token,
    this.data,
    required this.ok,
  });

  final dynamic status;
  final String message;
  final String token;
  final SignupData? data;
  final bool ok;

  bool get isSuccess {
    if (status == 200 || status == 201) return true;
    if (status?.toString().toLowerCase() == 'success') return true;
    return ok == true;
  }

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    SignupData? parsedData;

    final rawData = json['data'] ?? json['user'];
    if (rawData is Map<String, dynamic>) {
      if (rawData['user'] is Map<String, dynamic>) {
        parsedData = SignupData.fromJson(rawData['user']);
      } else {
        parsedData = SignupData.fromJson(rawData);
      }
    }

    return VerifyEmailResponse(
      status: json['status'],
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      data: parsedData,
      ok: json['ok'] == true,
    );
  }
}
