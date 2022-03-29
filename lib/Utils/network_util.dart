import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    final uri = Uri.parse(url);
    return http.get(uri).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Erreur de communication avec le serveur");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map<String, String>? headers,required Map<String,String> body, encoding}) {
    final uri = Uri.parse(url);
    return http
        .post(uri, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        return Exception("Erreur de communication avec le serveur");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> postFile(String url, {Map<String, String>? headers,required Map<String,String> body, required Iterable<http.MultipartFile> files, encoding}) async {
    final uri = Uri.parse(url);
    var request = http.MultipartRequest('POST',uri);
    request.headers.addAll({"Authorization": "Bearar ${body['id']}"});
    request.files.addAll(files);
    request.fields.addAll(body);
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
      final String res = responsed.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        return Exception("Erreur de communication avec le serveur");
      }
      return _decoder.convert(res);
    }
}