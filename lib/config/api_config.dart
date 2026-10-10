/// Global API origin: scheme + host (+ port if any). No trailing slash, no `/api` suffix.
///
/// Override for local/dev:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',

    // defaultValue: 'https://enlisted-resonate-riddance.ngrok-free.dev',
    // defaultValue: 'http://localhost:5000',
    defaultValue: 'https://nidrip-new-backend-1.onrender.com',
  );
}
