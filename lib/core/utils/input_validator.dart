class InputValidator {
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    if (username.length < 3) return false;
    return true;
  }

  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }

  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final phoneRegex = RegExp(r'^09\d{9}$');
    return phoneRegex.hasMatch(phone);
  }
}
