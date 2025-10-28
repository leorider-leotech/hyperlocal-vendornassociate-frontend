class Validators {
  Validators._();

  static String? requiredField(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? phone(String? value) {
    final sanitized = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (sanitized.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter an email address';
    }
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.length != 6) {
      return 'Enter the 6 digit OTP';
    }
    return null;
  }
}
