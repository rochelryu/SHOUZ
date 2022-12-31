import 'package:video_compress/video_compress.dart';

class VideoCompressApi {
  static Future<MediaInfo?> compressVideo(String filePath) async {
    try {
      return VideoCompress.compressVideo(
        filePath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
    } catch(e) {
      await VideoCompress.deleteAllCache();
      VideoCompress.cancelCompression();
      return null;
    }

  }
}