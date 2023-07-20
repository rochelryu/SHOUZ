import 'package:video_compress/video_compress.dart';

class VideoCompressApi {
  static Future<MediaInfo?> getMediaInfo(String filePath) async {
    try {
      return VideoCompress.getMediaInfo(
        filePath,
      );
    } catch(e) {
      await VideoCompress.deleteAllCache();
      VideoCompress.cancelCompression();
      return null;
    }

  }
}