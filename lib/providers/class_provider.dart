import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/enrollment_model.dart';
import '../services/database_service.dart';

class ClassProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<ClassModel> _classes = [];
  List<EnrollmentModel> _enrollments = [];
  bool _isLoading = false;

  ClassProvider(this._dbService) {
    _classes = _dbService.classes;
    _enrollments = _dbService.enrollments;

    _dbService.classesStream.listen((list) {
      _classes = list;
      notifyListeners();
    });

    _dbService.enrollmentsStream.listen((list) {
      _enrollments = list;
      notifyListeners();
    });
  }

  List<ClassModel> get classes => _classes;
  List<EnrollmentModel> get enrollments => _enrollments;
  bool get isLoading => _isLoading;

  // Student's Enrolled Classes
  List<ClassModel> getStudentClasses(String studentId) {
    final enrolledClassIds = _enrollments
        .where((e) => e.studentId == studentId)
        .map((e) => e.classId)
        .toSet();

    return _classes.where((c) => enrolledClassIds.contains(c.id)).toList();
  }

  // Enrollment for specific student and class
  EnrollmentModel? getEnrollment(String studentId, String classId) {
    try {
      return _enrollments.firstWhere(
        (e) => e.studentId == studentId && e.classId == classId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addClass(ClassModel newClass) async {
    _isLoading = true;
    notifyListeners();
    await _dbService.addClass(newClass);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateClass(ClassModel updatedClass) async {
    _isLoading = true;
    notifyListeners();
    await _dbService.updateClass(updatedClass);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteClass(String id) async {
    await _dbService.deleteClass(id);
  }

  Future<void> enrollStudent({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required ClassModel classItem,
  }) async {
    await _dbService.enrollStudent(
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      targetClass: classItem,
    );
  }

  Future<void> deleteEnrollment(String enrollmentId) async {
    _isLoading = true;
    notifyListeners();
    await _dbService.deleteEnrollment(enrollmentId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearAllEnrollments() async {
    _isLoading = true;
    notifyListeners();
    await _dbService.clearAllEnrollments();
    _isLoading = false;
    notifyListeners();
  }
}
