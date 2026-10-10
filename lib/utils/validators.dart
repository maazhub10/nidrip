class Validators {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    // Standard robust regex for email validation
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    );
    return emailRegex.hasMatch(email);
  }
}
