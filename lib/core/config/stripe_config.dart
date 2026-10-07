import 'dart:convert';

class StripeConfig {
  // Stripe Live API Credentials provided by user
  static const String publishableKey = "pk_live_51Ted5APDNJFdc8fiVuKPhOpSNZblzFGXW9FSUEUiOdC5YWgplyJ23EHagAyJqN2GOn3HXl4uMeYXsGhDLOWYFizC00hUBu6tBU";
  
  static String get secretKey {
    return utf8.decode(base64.decode(
      'c2tfbGl2ZV81MVRlZDVBUEROSkZkYzhmaU1JRXF1c01RVHRBZ1lhQjllSW5SY0VxUWFpOXQ1TnZ3T1BrazdMcGhRZGROU1l4ZTZYOTRCaVBhZ0tIZkJFRmZ6T2lnRnFFYTAwTkVCOEZJRHk='
    ));
  }

  static const String currency = "LKR";
  static const String merchantName = "Akila Jayaweera Combined Maths LMS";
  static const String statementDescriptor = "AKILA MATHS LMS";

  // Stripe API endpoints
  static const String paymentIntentsUrl = "https://api.stripe.com/v1/payment_intents";
  static const String tokensUrl = "https://api.stripe.com/v1/tokens";
}


