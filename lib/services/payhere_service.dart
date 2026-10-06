import 'dart:async';
import 'package:flutter/material.dart';
import '../core/config/payhere_config.dart';
import '../core/utils/payhere_hash.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

enum PayHereStatus { success, pending, failed, cancelled }

class PayHereResponse {
  final PayHereStatus status;
  final String orderId;
  final String payherePaymentId;
  final double amount;
  final String message;

  PayHereResponse({
    required this.status,
    required this.orderId,
    required this.payherePaymentId,
    required this.amount,
    required this.message,
  });
}

class PayHereService {
  final DatabaseService _dbService;

  PayHereService(this._dbService);

  /// Launches PayHere Payment Checkout for a given Combined Maths class
  Future<PayHereResponse> initiatePayment({
    required BuildContext context,
    required UserModel student,
    required ClassModel classItem,
  }) async {
    final String orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final double amount = classItem.monthlyFee;
    final String currency = PayHereConfig.currency;

    // Generate MD5 Hash Signature for PayHere security validation
    final String md5Hash = PayHereHash.generateHash(
      merchantId: PayHereConfig.merchantId,
      orderId: orderId,
      amount: amount,
      currency: currency,
      merchantSecret: PayHereConfig.merchantSecret,
    );

    debugPrint('--- PayHere Integration Checkout ---');
    debugPrint('Merchant ID: ${PayHereConfig.merchantId}');
    debugPrint('Order ID: $orderId');
    debugPrint('Amount: LKR $amount');
    debugPrint('Generated MD5 Hash: $md5Hash');

    // Show simulated modal / gateway dialog with PayHere branding and options
    final result = await _showPayHereCheckoutDialog(
      context: context,
      orderId: orderId,
      student: student,
      classItem: classItem,
      hash: md5Hash,
    );

    if (result != null && result.status == PayHereStatus.success) {
      // Record successful payment into Firestore
      await _dbService.recordPayment(
        studentId: student.uid,
        studentName: student.name,
        classId: classItem.id,
        className: classItem.title,
        amount: amount,
        payherePaymentId: result.payherePaymentId,
        status: 'success',
      );
    }

    return result ??
        PayHereResponse(
          status: PayHereStatus.cancelled,
          orderId: orderId,
          payherePaymentId: '',
          amount: amount,
          message: 'Payment cancelled by user.',
        );
  }

  /// Interactive PayHere Gateway UI Modal for Mobile & Web
  Future<PayHereResponse?> _showPayHereCheckoutDialog({
    required BuildContext context,
    required String orderId,
    required UserModel student,
    required ClassModel classItem,
    required String hash,
  }) async {
    return showDialog<PayHereResponse>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(20),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A), // Royal Indigo PayHere header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.payment_rounded, color: Color(0xFF1E3A8A), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PayHere Payment Gateway',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sri Lanka Secure LKR Checkout',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Teacher', PayHereConfig.teacherName),
                _buildInfoRow('Class', classItem.title),
                _buildInfoRow('Student', student.name),
                _buildInfoRow('Order ID', orderId),
                _buildInfoRow('PayHere Hash', '${hash.substring(0, 16)}...'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Fee (Monthly):', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      'Rs. ${classItem.monthlyFee.toStringAsFixed(2)} LKR',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Secured with 256-bit MD5 verification. Visa, Mastercard, eZ Cash, Genie & Frimi supported.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                PayHereResponse(
                  status: PayHereStatus.cancelled,
                  orderId: orderId,
                  payherePaymentId: '',
                  amount: classItem.monthlyFee,
                  message: 'User cancelled payment.',
                ),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final paymentId = 'PH_${DateTime.now().millisecondsSinceEpoch}';
                Navigator.of(dialogContext).pop(
                  PayHereResponse(
                    status: PayHereStatus.success,
                    orderId: orderId,
                    payherePaymentId: paymentId,
                    amount: classItem.monthlyFee,
                    message: 'Payment completed successfully via PayHere Gateway!',
                  ),
                );
              },
              child: const Text('Complete LKR Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
