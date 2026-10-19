import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/presentation/widgets/video/local_video_asset_path.dart';

void main() {
  test('uses compatible copies only for the two 4K Android assets', () {
    expect(
      localVideoAssetForPlatform('assets/videos/1.mp4', TargetPlatform.android),
      'assets/videos_android/1.mp4',
    );
    expect(
      localVideoAssetForPlatform('assets/videos/5.mp4', TargetPlatform.android),
      'assets/videos_android/5.mp4',
    );
    expect(
      localVideoAssetForPlatform('assets/videos/3.mp4', TargetPlatform.android),
      'assets/videos/3.mp4',
    );
    expect(
      localVideoAssetForPlatform('assets/videos/1.mp4', TargetPlatform.iOS),
      'assets/videos/1.mp4',
    );
  });
}
