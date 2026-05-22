import 'package:flutter/services.dart';

/// Removes leading spaces so validation and storage are consistent.
class LeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final trimmed = newValue.text.replaceFirst(RegExp(r'^\s+'), '');
    if (trimmed == newValue.text) return newValue;
    return newValue.copyWith(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }
}
