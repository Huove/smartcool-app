import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://oreo-production-15cb.up.railway.app/";

  static Future<Map<String, dynamic>> getData() async {
    final res = await http.get(Uri.parse("$baseUrl/data"));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getControl() async {
    final res = await http.get(Uri.parse("$baseUrl/control"));
    return jsonDecode(res.body);
  }

  static Future<void> setControl(String mode, int fan) async {
    await http.post(
      Uri.parse("$baseUrl/set"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mode": mode,
        "fan": fan,
      }),
    );
  }
}