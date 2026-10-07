import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../views/payment/stripe_checkout_dialog.dart';
import 'database_service.dart';

class StripeService {
  final DatabaseService _dbService;

  StripeService(this._dbService);

  // Render backend server URL
  static const String backendUrl = "https://akila-maths-payment-server.onrender.com";

  /// Creates a Payment Intent via Render Backend Server
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String studentId,
    required String classId,
    required String className,
    String? studentEmail,
    String? month,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/create-payment-intent"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'studentId': studentId,
          'classId': classId,
          'className': className,
          'studentEmail': studentEmail,
          'month': month,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Payment creation failed');
      }
    } catch (e) {
      debugPrint("Error creating payment intent: $e");
      return null;
    }
  }

  /// Launches Stripe Credit/Debit Card Checkout Modal
  Future<StripeResponse> initiateCardPayment({
    required BuildContext context,
    required UserModel student,
    required ClassModel classItem,
  }) async {
    final String orderId = 'ORD_STRIPE_${DateTime.now().millisecondsSinceEpoch}';

    final StripeResponse? result = await showDialog<StripeResponse>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StripeCheckoutDialog(
        student: student,
        classItem: classItem,
        orderId: orderId,
      ),
    );

    if (result != null && result.status == StripeStatus.success) {
      // Record successful Stripe payment into Firestore
      await _dbService.recordPayment(
        studentId: student.uid,
        studentName: student.name,
        classId: classItem.id,
        className: classItem.title,
        amount: result.amount,
        payherePaymentId: result.paymentIntentId,
        status: 'success',
        paymentMethod: 'Online Payment',
      );
    }

    return result ??
        StripeResponse(
          status: StripeStatus.cancelled,
          orderId: orderId,
          paymentIntentId: '',
          amount: classItem.monthlyFee,
          message: 'Payment cancelled by user.',
        );
  }
}

