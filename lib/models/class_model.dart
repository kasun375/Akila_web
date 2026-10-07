class ClassModel {
  final String id;
  final String title;
  final String description;
  final String schedule;
  final double monthlyFee; // in LKR (Rs.)
  final String teacherName; // "Akila Jayaweera"
  final String imageUrl;
  final int studentCount;
  final bool active;
  final String zoomUrl;

  ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.schedule,
    required this.monthlyFee,
    this.teacherName = "Akila Jayaweera",
    this.imageUrl = "",
    this.studentCount = 0,
    this.active = true,
    this.zoomUrl = "",
  });

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      schedule: map['schedule'] ?? '',
      monthlyFee: (map['monthlyFee'] ?? 0.0).toDouble(),
      teacherName: map['teacherName'] ?? 'Akila Jayaweera',
      imageUrl: map['imageUrl'] ?? '',
      studentCount: map['studentCount'] ?? 0,
      active: map['active'] ?? true,
      zoomUrl: map['zoomUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'schedule': schedule,
      'monthlyFee': monthlyFee,
      'teacherName': teacherName,
      'imageUrl': imageUrl,
      'studentCount': studentCount,
      'active': active,
      'zoomUrl': zoomUrl,
    };
  }
}
