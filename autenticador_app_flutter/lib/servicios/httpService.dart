import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;

  HttpService(this.baseUrl);

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.patch(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: headers);
  }
}
