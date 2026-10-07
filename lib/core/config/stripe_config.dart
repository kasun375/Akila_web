class StripeConfig {
  // Stripe Live API Publishable Key for client tokenization
  static const String publishableKey = "pk_live_51Ted5APDNJFdc8fiVuKPhOpSNZblzFGXW9FSUEUiOdC5YWgplyJ23EHagAyJqN2GOn3HXl4uMeYXsGhDLOWYFizC00hUBu6tBU";
  
  // Render Backend Server URL (which securely holds the STRIPE_SECRET_KEY)
  static const String backendUrl = "https://akila-maths-payment-server.onrender.com";

  static const String currency = "LKR";
  static const String merchantName = "Akila Jayaweera Combined Maths LMS";
  static const String statementDescriptor = "AKILA MATHS LMS";

  // Stripe API endpoints
  static const String paymentIntentsUrl = "https://api.stripe.com/v1/payment_intents";
  static const String tokensUrl = "https://api.stripe.com/v1/tokens";
}



