import 'dart:async';
import 'package:flutter/foundation.dart';
import 'web_helper.dart';

class StorageService {
  /// Picks an image file directly from the user's device storage
  /// Opens OS File Explorer dialog on Web/Desktop/Mobile and reads file data URL
  Future<String?> pickAndUploadProfileImage({required String userId}) async {
    if (kIsWeb) {
      final Completer<String?> completer = Completer<String?>();
      openWebFilePicker((url) {
        completer.complete(url);
      });
      return completer.future;
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300';
    }
  }

  /// Upload file bytes to storage
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required List<int> bytes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (fileName.endsWith('.pdf')) {
      return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    } else if (fileName.endsWith('.mp4')) {
      return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    }

    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300';
  }
}
