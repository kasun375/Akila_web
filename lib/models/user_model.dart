class UserModel {
  final String uid;
  final String role; // 'student' or 'admin'
  final String name;
  final String email;
  final String phone;
  final String grade;
  final String school;
  final String profilePicUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    this.grade = '2026 A/L',
    this.school = '',
    this.profilePicUrl = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStudent => role.toLowerCase() == 'student';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      role: map['role'] ?? 'student',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      grade: map['grade'] ?? '2026 A/L',
      school: map['school'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'grade': grade,
      'school': school,
      'profilePicUrl': profilePicUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? grade,
    String? school,
    String? profilePicUrl,
  }) {
    return UserModel(
      uid: uid,
      role: role,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      grade: grade ?? this.grade,
      school: school ?? this.school,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      createdAt: createdAt,
    );
  }
}
