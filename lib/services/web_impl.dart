import 'dart:async';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebStorage {
  static Map<String, String> get localStorage => html.window.localStorage;
}

void openWebFilePicker(void Function(String?) onFilePicked) {
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

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
            onFilePicked(compressedUrl);
          }).catchError((_) {
            onFilePicked(rawUrl);
          });
        } else {
          onFilePicked(rawUrl);
        }
      });
      reader.onError.listen((err) {
        onFilePicked(null);
      });
    } else {
      onFilePicked(null);
    }
  });
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
