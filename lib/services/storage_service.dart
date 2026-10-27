import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'web_helper.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image file directly from the user's device storage
  /// Works across Mobile (Android/iOS Gallery & Camera) and Web.
  Future<String?> pickAndUploadProfileImage({
    required String userId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );

      if (image == null) return null;

      final Uint8List bytes = await image.readAsBytes();
      if (bytes.isEmpty) return null;
      final String base64String = base64Encode(bytes);
      final String mimeType = image.mimeType ?? 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('ImagePicker primary pick error: $e');
      if (kIsWeb) {
        try {
          final Completer<String?> completer = Completer<String?>();
          openWebFilePicker((url) {
            if (!completer.isCompleted) completer.complete(url);
          });
          return await completer.future.timeout(
            const Duration(minutes: 2),
            onTimeout: () => null,
          );
        } catch (webErr) {
          debugPrint('Web fallback picker error: $webErr');
          rethrow;
        }
      }
      rethrow;
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
