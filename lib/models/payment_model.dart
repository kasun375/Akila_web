class PaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final double amount; // in LKR
  final String payherePaymentId;
  final String status; // 'success', 'pending', 'failed'
  final String paymentMethod; // 'PayHere Gateway', 'Bank Slip'
  final String month;
  final DateTime timestamp;

  PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.amount,
    required this.payherePaymentId,
    this.status = 'success',
    this.paymentMethod = 'PayHere Gateway',
    required this.month,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      payherePaymentId: map['payherePaymentId'] ?? '',
      status: map['status'] ?? 'success',
      paymentMethod: map['paymentMethod'] ?? 'PayHere Gateway',
      month: map['month'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'amount': amount,
      'payherePaymentId': payherePaymentId,
      'status': status,
      'paymentMethod': paymentMethod,
      'month': month,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
