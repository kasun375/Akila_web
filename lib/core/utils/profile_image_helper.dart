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

  if (cleanUrl.startsWith('data:') || (cleanUrl.length > 200 && !cleanUrl.startsWith('http'))) {
    try {
      final base64Parts = cleanUrl.split(',');
      final base64Str = base64Parts.length > 1 ? base64Parts[1] : base64Parts[0];
      final cleanBase64 = base64Str.replaceAll(RegExp(r'\s+'), '');
      final bytes = base64Decode(cleanBase64);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint('Error decoding base64 profile image: $e');
      if (defaultAsset.isNotEmpty) return AssetImage(defaultAsset);
      return null;
    }
  }

  return NetworkImage(cleanUrl);
}
