import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/payhere_service.dart';

class PaymentProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  final PayHereService _payHereService;

  List<PaymentModel> _payments = [];
  bool _isProcessing = false;

  PaymentProvider(this._dbService, this._payHereService) {
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

  Future<PayHereResponse> makeClassPayment({
    required BuildContext context,
    required UserModel student,
    required ClassModel classItem,
  }) async {
    _isProcessing = true;
    notifyListeners();

    final response = await _payHereService.initiatePayment(
      context: context,
      student: student,
      classItem: classItem,
    );

    _isProcessing = false;
    notifyListeners();
    return response;
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
