import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const backendUrl = 'https://c02a-2409-40e5-10ac-704e-44f2-79e8-1682-d8c1.ngrok-free.app/test-api';

  static Future<String> sendRequest({
    required String method,
    required String url,
    required String rawHeaders,
    required String rawBody,
  }) async {
    Map<String, String>? headers;

    try {
      if (rawHeaders.trim().isNotEmpty) {
        final parsed = json.decode(rawHeaders);
        if (parsed is Map<String, dynamic>) {
          headers = parsed.map((key, value) => MapEntry(key, value.toString()));
        } else {
          throw FormatException('Headers must be a JSON object');
        }
      }

      dynamic body;
      if (['POST', 'PUT'].contains(method) && rawBody.trim().isNotEmpty) {
        try {
          body = json.decode(rawBody);
        } catch (_) {
          body = rawBody;
        }
      }

      final requestPayload = {
        "method": method,
        "url": url,
        "headers": headers,
        "body": body,
      };

      final res = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      final fullResponse = json.decode(res.body);
      final bodyString = fullResponse['body'];

      dynamic parsedBody;
      try {
        parsedBody = json.decode(bodyString);
      } catch (_) {
        parsedBody = bodyString;
      }

      final prettyBody = JsonEncoder.withIndent('  ').convert(parsedBody);
      return '✅ Status: ${res.statusCode}\n\n$prettyBody';
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}
