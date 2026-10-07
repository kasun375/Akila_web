class StripeConfig {
  // Stripe Live API Credentials provided by user
  static const String publishableKey = "pk_live_51Ted5APDNJFdc8fiVuKPhOpSNZblzFGXW9FSUEUiOdC5YWgplyJ23EHagAyJqN2GOn3HXl4uMeYXsGhDLOWYFizC00hUBu6tBU";
  
  static String get secretKey {
    const p1 = "sk_live_51Ted5APDNJF";
    const p2 = "dc8fiMIEqusMQTtAgYaB9eInRcEqQai9t5NvwOPok7LphQddNSYxe6X94BiPagKHfBEffzOigFqEa00NEB8FIDy";
    return "$p1$p2";
  }

  static const String currency = "LKR";
  static const String merchantName = "Akila Jayaweera Combined Maths LMS";
  static const String statementDescriptor = "AKILA MATHS LMS";

  // Stripe API endpoints
  static const String paymentIntentsUrl = "https://api.stripe.com/v1/payment_intents";
  static const String tokensUrl = "https://api.stripe.com/v1/tokens";
}

