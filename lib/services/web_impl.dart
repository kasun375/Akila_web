import 'dart:async';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebStorage {
  static Map<String, String> get localStorage => html.window.localStorage;
}

void openWebFilePicker(void Function(String?) onFilePicked) {
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';

  html.document.body?.children.add(uploadInput);

  bool completed = false;
  void finish(String? res) {
    if (!completed) {
      completed = true;
      try {
        uploadInput.remove();
      } catch (_) {}
      onFilePicked(res);
    }
  }

  // Handle mobile and desktop cancel when file dialog is closed
  html.window.addEventListener('focus', (e) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!completed && (uploadInput.files == null || uploadInput.files!.isEmpty)) {
        finish(null);
      }
    });
  });

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        final rawUrl = reader.result as String?;
        if (rawUrl != null && rawUrl.startsWith('data:image')) {
          _compressAndResizeWebImage(rawUrl).then((compressedUrl) {
            finish(compressedUrl);
          }).catchError((_) {
            finish(rawUrl);
          });
        } else {
          finish(rawUrl);
        }
      });
      reader.onError.listen((err) {
        finish(null);
      });
    } else {
      finish(null);
    }
  });

  uploadInput.click();
}

Future<String> _compressAndResizeWebImage(String dataUrl) {
  final completer = Completer<String>();
  final img = html.ImageElement();
  img.src = dataUrl;
  img.onLoad.listen((_) {
    try {
      const int maxDim = 300;
      int width = img.width ?? maxDim;
      int height = img.height ?? maxDim;

      if (width > maxDim || height > maxDim) {
        if (width > height) {
          height = (height * maxDim / width).round();
          width = maxDim;
        } else {
          width = (width * maxDim / height).round();
          height = maxDim;
        }
      }

      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, width, height);
      final compressed = canvas.toDataUrl('image/jpeg', 0.82);
      completer.complete(compressed);
    } catch (e) {
      completer.complete(dataUrl);
    }
  });
  img.onError.listen((_) => completer.complete(dataUrl));
  return completer.future;
}
