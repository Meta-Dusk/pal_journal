import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/services/currency/currency_service.dart';

class AppFormatters {
  // Converts 150000.5 to "150,000.50"
  static String toCurrency(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  // Safely converts back to a double, aggressively stripping rogue characters
  static double parseCurrency(String input) {
    if (input.isEmpty) return 0.0;
    // Strip commas, spaces, and currency symbols just in case they get pasted in
    final cleanString = input
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll(CurrencyService.symbol, '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}

/// A custom formatter that handles commas, decimals, and negative signs.
class PnLFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty text or just a solitary minus sign to start a negative number
    if (newValue.text.isEmpty || newValue.text == '-') return newValue;

    // Strip all commas to process the raw number
    String cleanText = newValue.text.replaceAll(',', '');

    // Check if it's a valid number. If not, reject the keystroke.
    if (double.tryParse(cleanText) == null) {
      // Exception: allow ending with a dot so they can begin typing decimals
      if (!cleanText.endsWith('.') || cleanText.split('.').length > 2) {
        return oldValue;
      }
    }

    // Separate the sign, integer part, and decimal part
    bool isNegative = cleanText.startsWith('-');
    if (isNegative) cleanText = cleanText.substring(1);

    List<String> parts = cleanText.split('.');
    String intPart = parts[0];

    // Add commas every 3 digits
    String formattedInt = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      // Add a comma every 3 characters
      if (count > 0 && count % 3 == 0) {
        formattedInt = ',$formattedInt';
      }
      formattedInt = intPart[i] + formattedInt;
      count++;
    }

    // Reassemble everything
    String finalString = (isNegative ? '-' : '') + formattedInt;
    if (parts.length > 1) {
      finalString += '.${parts[1]}';
    } else if (newValue.text.endsWith('.')) {
      finalString += '.';
    }

    // Count how many actual numbers/symbols are before the cursor in the unformatted text
    int rawCursorPos = newValue.selection.end;
    int nonCommaCharsBeforeCursor = 0;
    for (int i = 0; i < rawCursorPos && i < newValue.text.length; i++) {
      if (newValue.text[i] != ',') nonCommaCharsBeforeCursor++;
    }

    // Find where that exact character lands in our newly formatted string
    int newCursorPos = 0;
    int nonCommaCount = 0;
    for (int i = 0; i < finalString.length; i++) {
      if (finalString[i] != ',') nonCommaCount++;
      newCursorPos++;
      if (nonCommaCount == nonCommaCharsBeforeCursor) break;
    }

    // Safety bounds
    if (newCursorPos < 0) newCursorPos = 0;
    if (newCursorPos > finalString.length) newCursorPos = finalString.length;

    return TextEditingValue(
      text: finalString,
      selection: .collapsed(offset: newCursorPos),
    );
  }
}
