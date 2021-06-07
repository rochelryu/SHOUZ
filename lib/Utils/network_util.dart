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

  Future<dynamic> post(String url, {Map headers,Map body, encoding}) {
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
}