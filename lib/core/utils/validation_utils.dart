/// Validation utilities for form fields
class ValidationUtils {
  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation regex (allows international formats)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)\.]{10,15}$',
  );

  /// Name validation regex (letters, spaces, hyphens, apostrophes)
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-Z\s\-\'\.]+$',
  );

  /// Validate email address
  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }

    final email = value.trim();
    
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    if (email.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    final phone = value.trim();
    
    // Remove all non-digit characters for length validation
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate name (person name, plan name, etc.)
  static String? validateName(String? value, {
    bool required = true,
    int minLength = 2,
    int maxLength = 100,
    String fieldName = 'Name',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final name = value.trim();

    if (name.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (name.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    if (!_nameRegex.hasMatch(name)) {
      return '$fieldName contains invalid characters';
    }

    return null;
  }

  /// Validate text field with length constraints
  static String? validateText(String? value, {
    bool required = false,
    int minLength = 0,
    int maxLength = 1000,
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final text = value.trim();

    if (text.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (text.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {
    bool required = true,
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = false,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Password is required' : null;
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChars && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate date is not in the past
  static String? validateFutureDate(DateTime? value, {
    bool required = false,
    String fieldName = 'Date',
  }) {
    if (value == null) {
      return required ? '$fieldName is required' : null;
    }

    final now = DateTime.now();
    if (value.isBefore(now)) {
      return '$fieldName cannot be in the past';
    }

    return null;
  }

  /// Validate date is within a range
  static String? validateDateRange(DateTime? value, {
    DateTime? minDate,
    DateTime? maxDate,
    bool required = false,
    String fieldName = 'Date',
  }) {
    if (value == null) {
      return required ? '$fieldName is required' : null;
    }

    if (minDate != null && value.isBefore(minDate)) {
      return '$fieldName cannot be before ${_formatDate(minDate)}';
    }

    if (maxDate != null && value.isAfter(maxDate)) {
      return '$fieldName cannot be after ${_formatDate(maxDate)}';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    final url = value.trim();
    
    if (!RegExp(r'^https?:\/\/.+').hasMatch(url)) {
      return 'Please enter a valid URL starting with http:// or https://';
    }

    return null;
  }

  /// Validate numeric value
  static String? validateNumber(String? value, {
    bool required = false,
    double? min,
    double? max,
    String fieldName = 'Number',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName cannot exceed $max';
    }

    return null;
  }

  /// Validate that two fields match (e.g., password confirmation)
  static String? validateMatch(String? value, String? matchValue, {
    String fieldName = 'Field',
    String matchFieldName = 'matching field',
  }) {
    if (value != matchValue) {
      return '$fieldName does not match $matchFieldName';
    }
    return null;
  }

  /// Check if email is valid (without error message)
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Check if phone is valid (without error message)
  static bool isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && 
           digitsOnly.length <= 15 && 
           _phoneRegex.hasMatch(phone.trim());
  }

  /// Format date for display in error messages
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Sanitize text input (remove potentially harmful characters)
  static String sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'[<>{}[\]\\|`~]'), '')
        .trim();
  }

  /// Validate invitation code format
  static String? validateInvitationCode(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Invitation code is required' : null;
    }

    final code = value.trim().toUpperCase();
    
    if (code.length != 8) {
      return 'Invitation code must be 8 characters long';
    }

    if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
      return 'Invitation code must contain only letters and numbers';
    }

    return null;
  }

  /// Validate decision title
  static String? validateDecisionTitle(String? value) {
    return validateText(
      value,
      required: true,
      minLength: 5,
      maxLength: 200,
      fieldName: 'Decision title',
    );
  }

  /// Validate plan name
  static String? validatePlanName(String? value) {
    return validateName(
      value,
      required: true,
      minLength: 3,
      maxLength: 100,
      fieldName: 'Plan name',
    );
  }
}
