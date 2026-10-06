class PayHereConfig {
  static const bool isSandbox = true;
  
  // PayHere Merchant Credentials
  static const String merchantId = "1229988"; // Replace with Teacher's PayHere Merchant ID
  static const String merchantSecret = "4MTE1MjM4NjMxNjI0NDg0OTE5MjAyMzk3MTUzMzc2MzA5MTI0"; // Replace with PayHere Merchant Secret
  static const String currency = "LKR";

  static String get checkoutUrl => isSandbox
      ? "https://sandbox.payhere.lk/pay/checkout"
      : "https://www.payhere.lk/pay/checkout";

  // Default merchant details
  static const String teacherName = "Akila Jayaweera";
  static const String merchantName = "Akila Jayaweera Combined Maths LMS";
  static const String notifyUrl = "https://us-central1-akila-maths-lms.cloudfunctions.net/payhereNotify";
}
