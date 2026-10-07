import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../views/payment/stripe_checkout_dialog.dart';
import 'database_service.dart';

class StripeService {
  final DatabaseService _dbService;

  StripeService(this._dbService);

  /// Launches Stripe Elements Credit/Debit Card Checkout Modal
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
