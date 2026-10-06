import 'dart:convert';
import 'package:crypto/crypto.dart';

class PayHereHash {
  /// Generates the PayHere security hash for checkout verification.
  /// Formula: UPPERCASE(MD5(merchant_id + order_id + amount + currency + UPPERCASE(MD5(merchant_secret))))
  static String generateHash({
    required String merchantId,
    required String orderId,
    required double amount,
    required String currency,
    required String merchantSecret,
  }) {
    // Format amount to 2 decimal places (e.g. 3500.00)
    final formattedAmount = amount.toStringAsFixed(2);

    // Step 1: MD5 of merchant secret converted to UPPERCASE
    final secretBytes = utf8.encode(merchantSecret);
    final secretMd5Upper = md5.convert(secretBytes).toString().toUpperCase();

    // Step 2: Combine params
    final rawString = '$merchantId$orderId$formattedAmount$currency$secretMd5Upper';

    // Step 3: Final MD5 converted to UPPERCASE
    final rawBytes = utf8.encode(rawString);
    return md5.convert(rawBytes).toString().toUpperCase();
  }
}
