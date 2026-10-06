import 'dart:convert';
import 'package:flutter/material.dart';

/// Helper to resolve profile image URLs (assets, data URIs, or web network URLs)
/// into a reliable Flutter [ImageProvider].
ImageProvider? getProfileImageProvider(String? url, {String defaultAsset = ''}) {
  if (url == null || url.trim().isEmpty) {
    if (defaultAsset.isNotEmpty) {
      return AssetImage(defaultAsset);
    }
    return null;
  }
  final cleanUrl = url.trim();

  if (cleanUrl.startsWith('assets/')) {
    return AssetImage(cleanUrl);
  }

  if (cleanUrl.startsWith('data:image')) {
    try {
      final base64Parts = cleanUrl.split(',');
      final base64Str = base64Parts.length > 1 ? base64Parts[1] : base64Parts[0];
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint('Error decoding base64 profile image: $e');
      if (defaultAsset.isNotEmpty) return AssetImage(defaultAsset);
      return null;
    }
  }

  return NetworkImage(cleanUrl);
}
