import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/database_service.dart';

class ContentProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<ContentModel> _contentList = [];
  bool _isLoading = false;

  ContentProvider(this._dbService) {
    _contentList = _dbService.contentList;
    _dbService.contentStream.listen((list) {
      _contentList = list;
      notifyListeners();
    });
  }

  List<ContentModel> get contentList => _contentList;
  bool get isLoading => _isLoading;

  List<ContentModel> getContentForClass(String classId) {
    return _contentList.where((c) => c.classId == classId).toList();
  }

  List<ContentModel> getRecordings(String classId) {
    return _contentList
        .where((c) => c.classId == classId && c.isRecording)
        .toList();
  }

  List<ContentModel> getStudyPacks(String classId) {
    return _contentList
        .where((c) => c.classId == classId && c.isStudyPack)
        .toList();
  }

  Future<void> addContent(ContentModel item) async {
    _isLoading = true;
    notifyListeners();
    await _dbService.addContent(item);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteContent(String id) async {
    await _dbService.deleteContent(id);
  }
}
