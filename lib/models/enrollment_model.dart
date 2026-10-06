class EnrollmentModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String classId;
  final String className;
  final DateTime enrolledAt;
  final String paymentStatus; // 'paid', 'pending', 'expired'
  final String validMonth;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.classId,
    required this.className,
    DateTime? enrolledAt,
    this.paymentStatus = 'pending',
    required this.validMonth,
  }) : enrolledAt = enrolledAt ?? DateTime.now();

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      enrolledAt: map['enrolledAt'] != null
          ? DateTime.tryParse(map['enrolledAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      validMonth: map['validMonth'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'classId': classId,
      'className': className,
      'enrolledAt': enrolledAt.toIso8601String(),
      'paymentStatus': paymentStatus,
      'validMonth': validMonth,
    };
  }
}
