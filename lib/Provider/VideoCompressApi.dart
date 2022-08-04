
import 'dart:io';

import 'package:video_compress/video_compress.dart';

class VideoCompressApi {
  static Future<MediaInfo?> compressVideo(File file, [bool includeAudio = false]) async {
    try {
      return VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        includeAudio: includeAudio,
      );
    } catch(e) {
      await VideoCompress.deleteAllCache();
      VideoCompress.cancelCompression();
      return null;
    }

  }
}