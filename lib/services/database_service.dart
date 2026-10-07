import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../models/enrollment_model.dart';
import '../models/content_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ClassModel> _classes = [];
  final List<EnrollmentModel> _enrollments = [];
  final List<ContentModel> _contentList = [];
  final List<PaymentModel> _payments = [];

  final _classStream = StreamController<List<ClassModel>>.broadcast();
  final _enrollmentStream = StreamController<List<EnrollmentModel>>.broadcast();
  final _contentStream = StreamController<List<ContentModel>>.broadcast();
  final _paymentStream = StreamController<List<PaymentModel>>.broadcast();

  DatabaseService() {
    _listenToFirestore();
  }

  /// Listens to live Cloud Firestore snapshot collections and syncs real-time updates
  void _listenToFirestore() {
    // 1. Classes Stream (Admin-created classes only)
    _firestore.collection('classes').snapshots().listen((snapshot) {
      _classes.clear();
      for (final doc in snapshot.docs) {
        // Purge legacy system seeded IDs if stored in Firestore from past runs
        if (doc.id == 'cls_2026_theory' ||
            doc.id == 'cls_2026_revision' ||
            doc.id == 'cls_2027_theory') {
          _firestore.collection('classes').doc(doc.id).delete().catchError((_) {});
          continue;
        }
        _classes.add(ClassModel.fromMap(doc.data(), doc.id));
      }
      _classStream.add(_classes);
    }, onError: (e) {
      debugPrint("Firestore classes stream error: $e");
    });

    // 2. Enrollments Stream
    _firestore.collection('enrollments').snapshots().listen((snapshot) {
      _enrollments.clear();
      for (final doc in snapshot.docs) {
        _enrollments.add(EnrollmentModel.fromMap(doc.data(), doc.id));
      }
      _enrollmentStream.add(_enrollments);
    }, onError: (e) {
      debugPrint("Firestore enrollments stream error: $e");
    });

    // 3. Content Stream (Admin-uploaded content only)
    _firestore.collection('content').snapshots().listen((snapshot) {
      _contentList.clear();
      for (final doc in snapshot.docs) {
        // Purge legacy system seeded content IDs if stored in Firestore from past runs
        if (doc.id == 'cnt_001' || doc.id == 'cnt_002' || doc.id == 'cnt_003') {
          _firestore.collection('content').doc(doc.id).delete().catchError((_) {});
          continue;
        }
        _contentList.add(ContentModel.fromMap(doc.data(), doc.id));
      }
      _contentStream.add(_contentList);
    }, onError: (e) {
      debugPrint("Firestore content stream error: $e");
    });

    // 4. Payments Stream
    _firestore.collection('payments').snapshots().listen((snapshot) {
      _payments.clear();
      for (final doc in snapshot.docs) {
        _payments.add(PaymentModel.fromMap(doc.data(), doc.id));
      }
      _paymentStream.add(_payments);
    }, onError: (e) {
      debugPrint("Firestore payments stream error: $e");
    });
  }


  // Getters & Streams
  Stream<List<ClassModel>> get classesStream => _classStream.stream;
  Stream<List<EnrollmentModel>> get enrollmentsStream => _enrollmentStream.stream;
  Stream<List<ContentModel>> get contentStream => _contentStream.stream;
  Stream<List<PaymentModel>> get paymentsStream => _paymentStream.stream;

  List<ClassModel> get classes => List.unmodifiable(_classes);
  List<EnrollmentModel> get enrollments => List.unmodifiable(_enrollments);
  List<ContentModel> get contentList => List.unmodifiable(_contentList);
  List<PaymentModel> get payments => List.unmodifiable(_payments);

  // Class Operations (Admin)
  Future<void> addClass(ClassModel newClass) async {
    _classes.add(newClass);
    _classStream.add(_classes);
    try {
      await _firestore.collection('classes').doc(newClass.id).set(newClass.toMap());
    } catch (e) {
      debugPrint("Firestore addClass error: $e");
    }
  }

  Future<void> updateClass(ClassModel updatedClass) async {
    final index = _classes.indexWhere((c) => c.id == updatedClass.id);
    if (index != -1) {
      _classes[index] = updatedClass;
      _classStream.add(_classes);
    }
    try {
      await _firestore.collection('classes').doc(updatedClass.id).update(updatedClass.toMap());
    } catch (e) {
      debugPrint("Firestore updateClass error: $e");
    }
  }

  Future<void> deleteClass(String id) async {
    _classes.removeWhere((c) => c.id == id);
    _classStream.add(_classes);
    try {
      await _firestore.collection('classes').doc(id).delete();
    } catch (e) {
      debugPrint("Firestore deleteClass error: $e");
    }
  }

  // Content Operations (Admin / Teacher Uploads)
  Future<void> addContent(ContentModel item) async {
    _contentList.insert(0, item);
    _contentStream.add(_contentList);
    try {
      await _firestore.collection('content').doc(item.id).set(item.toMap());
    } catch (e) {
      debugPrint("Firestore addContent error: $e");
    }
  }

  Future<void> deleteContent(String id) async {
    _contentList.removeWhere((c) => c.id == id);
    _contentStream.add(_contentList);
    try {
      await _firestore.collection('content').doc(id).delete();
    } catch (e) {
      debugPrint("Firestore deleteContent error: $e");
    }
  }

  // Enrollment Operations (Student)
  Future<void> enrollStudent({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required ClassModel targetClass,
  }) async {
    final enrollment = EnrollmentModel(
      id: 'enr_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      classId: targetClass.id,
      className: targetClass.title,
      paymentStatus: 'pending',
      validMonth: 'October 2026',
    );
    _enrollments.add(enrollment);
    _enrollmentStream.add(_enrollments);
    try {
      await _firestore.collection('enrollments').doc(enrollment.id).set(enrollment.toMap());
    } catch (e) {
      debugPrint("Firestore enrollStudent error: $e");
    }
  }

  // Record Payment & Activate Student Access
  Future<PaymentModel> recordPayment({
    required String studentId,
    required String studentName,
    required String classId,
    required String className,
    required double amount,
    required String payherePaymentId,
    String status = 'success',
    String paymentMethod = 'Stripe Credit/Debit Card',
  }) async {
    final payment = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      classId: classId,
      className: className,
      amount: amount,
      payherePaymentId: payherePaymentId,
      status: status,
      paymentMethod: paymentMethod,
      month: 'October 2026',
    );

    _payments.insert(0, payment);
    _paymentStream.add(_payments);

    final index = _enrollments.indexWhere(
        (e) => e.studentId == studentId && e.classId == classId);
    if (index != -1) {
      final old = _enrollments[index];
      _enrollments[index] = EnrollmentModel(
        id: old.id,
        studentId: old.studentId,
        studentName: old.studentName,
        studentEmail: old.studentEmail,
        classId: old.classId,
        className: old.className,
        enrolledAt: old.enrolledAt,
        paymentStatus: status == 'success' ? 'paid' : 'pending',
        validMonth: old.validMonth,
      );
      _enrollmentStream.add(_enrollments);
      try {
        await _firestore.collection('enrollments').doc(old.id).update({
          'paymentStatus': status == 'success' ? 'paid' : 'pending',
        });
      } catch (_) {}
    } else {
      // Automatically create new paid enrollment record if not pre-existing
      final newEnr = EnrollmentModel(
        id: 'enr_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        studentName: studentName,
        studentEmail: '',
        classId: classId,
        className: className,
        paymentStatus: status == 'success' ? 'paid' : 'pending',
        validMonth: 'October 2026',
      );
      _enrollments.add(newEnr);
      _enrollmentStream.add(_enrollments);
      try {
        await _firestore.collection('enrollments').doc(newEnr.id).set(newEnr.toMap());
      } catch (_) {}
    }

    try {
      await _firestore.collection('payments').doc(payment.id).set(payment.toMap());
    } catch (e) {
      debugPrint("Firestore recordPayment error: $e");
    }

    return payment;
  }

  // Delete a specific payment record
  Future<void> deletePayment(String paymentId) async {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      final payment = _payments[index];
      _payments.removeAt(index);
      _paymentStream.add(_payments);

      // Check if student has any other successful payments for this class
      final hasOtherSuccessPayment = _payments.any(
        (p) => p.studentId == payment.studentId && p.classId == payment.classId && p.status == 'success',
      );

      if (!hasOtherSuccessPayment) {
        final enrIndex = _enrollments.indexWhere(
          (e) => e.studentId == payment.studentId && e.classId == payment.classId,
        );
        if (enrIndex != -1) {
          final old = _enrollments[enrIndex];
          _enrollments[enrIndex] = EnrollmentModel(
            id: old.id,
            studentId: old.studentId,
            studentName: old.studentName,
            studentEmail: old.studentEmail,
            classId: old.classId,
            className: old.className,
            enrolledAt: old.enrolledAt,
            paymentStatus: 'pending',
            validMonth: old.validMonth,
          );
          _enrollmentStream.add(_enrollments);
          try {
            await _firestore.collection('enrollments').doc(old.id).update({'paymentStatus': 'pending'});
          } catch (_) {}
        }
      }

      try {
        await _firestore.collection('payments').doc(paymentId).delete();
      } catch (e) {
        debugPrint("Firestore deletePayment error: $e");
      }
    }
  }

  // Clear all payment records
  Future<void> clearAllPayments() async {
    final copy = List<PaymentModel>.from(_payments);
    _payments.clear();
    _paymentStream.add(_payments);

    // Reset all enrollment statuses to pending
    for (int i = 0; i < _enrollments.length; i++) {
      final old = _enrollments[i];
      _enrollments[i] = EnrollmentModel(
        id: old.id,
        studentId: old.studentId,
        studentName: old.studentName,
        studentEmail: old.studentEmail,
        classId: old.classId,
        className: old.className,
        enrolledAt: old.enrolledAt,
        paymentStatus: 'pending',
        validMonth: old.validMonth,
      );
    }
    _enrollmentStream.add(_enrollments);

    for (final p in copy) {
      try {
        await _firestore.collection('payments').doc(p.id).delete();
      } catch (_) {}
    }

    for (final enr in _enrollments) {
      try {
        await _firestore.collection('enrollments').doc(enr.id).update({'paymentStatus': 'pending'});
      } catch (_) {}
    }
  }

  // Delete a specific enrollment record
  Future<void> deleteEnrollment(String enrollmentId) async {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index != -1) {
      _enrollments.removeAt(index);
      _enrollmentStream.add(_enrollments);
      try {
        await _firestore.collection('enrollments').doc(enrollmentId).delete();
      } catch (e) {
        debugPrint("Firestore deleteEnrollment error: $e");
      }
    }
  }

  // Clear all enrollment records & access statuses
  Future<void> clearAllEnrollments() async {
    final copy = List<EnrollmentModel>.from(_enrollments);
    _enrollments.clear();
    _enrollmentStream.add(_enrollments);

    for (final enr in copy) {
      try {
        await _firestore.collection('enrollments').doc(enr.id).delete();
      } catch (_) {}
    }
  }
}
