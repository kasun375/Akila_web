class ContentModel {
  final String id;
  final String classId;
  final String className;
  final String type; // 'recording' or 'studypack'
  final String title;
  final String description;
  final String fileUrl;
  final String thumbnailUrl;
  final String fileSize;
  final DateTime uploadedAt;

  ContentModel({
    required this.id,
    required this.classId,
    this.className = '',
    required this.type,
    required this.title,
    this.description = '',
    required this.fileUrl,
    this.thumbnailUrl = '',
    this.fileSize = 'PDF Document',
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  bool get isRecording => type.toLowerCase() == 'recording';
  bool get isStudyPack => type.toLowerCase() == 'studypack';

  factory ContentModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentModel(
      id: id,
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      type: map['type'] ?? 'studypack',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      fileSize: map['fileSize'] ?? 'Document',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'className': className,
      'type': type,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
