import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/stripe_service.dart';
import '../views/payment/stripe_checkout_dialog.dart';

class PaymentGatewayResult {
  final bool isSuccess;
  final String orderId;
  final String paymentId;
  final double amount;
  final String message;

  PaymentGatewayResult({
    required this.isSuccess,
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.message,
  });
}

class PaymentProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  final StripeService _stripeService;

  List<PaymentModel> _payments = [];
  bool _isProcessing = false;

  PaymentProvider(this._dbService, this._stripeService) {
    _payments = _dbService.payments;
    _dbService.paymentsStream.listen((list) {
      _payments = list;
      notifyListeners();
    });
  }

  List<PaymentModel> get payments => _payments;
  bool get isProcessing => _isProcessing;

  double get totalRevenue =>
      _payments.fold(0.0, (sum, p) => p.status == 'success' ? sum + p.amount : sum);

  List<PaymentModel> getPaymentsForStudent(String studentId) {
    return _payments.where((p) => p.studentId == studentId).toList();
  }

  /// Directly opens checkout card dialog & processes fee payment
  Future<PaymentGatewayResult> makeClassPayment({
    required BuildContext context,
    required UserModel student,
    required ClassModel classItem,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final stripeResp = await _stripeService.initiateCardPayment(
        context: context,
        student: student,
        classItem: classItem,
      );

      _isProcessing = false;
      notifyListeners();

      return PaymentGatewayResult(
        isSuccess: stripeResp.status == StripeStatus.success,
        orderId: stripeResp.orderId,
        paymentId: stripeResp.paymentIntentId,
        amount: stripeResp.amount,
        message: stripeResp.message,
      );
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return PaymentGatewayResult(
        isSuccess: false,
        orderId: '',
        paymentId: '',
        amount: classItem.monthlyFee,
        message: 'Payment processing error: $e',
      );
    }
  }

  Future<PaymentModel> recordPayment({
    required String studentId,
    required String studentName,
    required String classId,
    required String className,
    required double amount,
    required String payherePaymentId,
    String status = 'success',
  }) async {
    _isProcessing = true;
    notifyListeners();

    final payment = await _dbService.recordPayment(
      studentId: studentId,
      studentName: studentName,
      classId: classId,
      className: className,
      amount: amount,
      payherePaymentId: payherePaymentId,
      status: status,
    );

    _isProcessing = false;
    notifyListeners();
    return payment;
  }

  Future<void> deletePayment(String paymentId) async {
    _isProcessing = true;
    notifyListeners();

    await _dbService.deletePayment(paymentId);

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> clearAllPayments() async {
    _isProcessing = true;
    notifyListeners();

    await _dbService.clearAllPayments();

    _isProcessing = false;
    notifyListeners();
  }
}
