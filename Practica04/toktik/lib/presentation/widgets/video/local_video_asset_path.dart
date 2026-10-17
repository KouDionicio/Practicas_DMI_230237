import 'package:flutter/foundation.dart';

String localVideoAssetForPlatform(String assetPath, TargetPlatform platform) {
  final needsAndroidCompatibilityCopy =
      platform == TargetPlatform.android &&
      (assetPath.endsWith('/1.mp4') || assetPath.endsWith('/5.mp4'));
  if (!needsAndroidCompatibilityCopy) return assetPath;
  return assetPath.replaceFirst('assets/videos/', 'assets/videos_android/');
}
