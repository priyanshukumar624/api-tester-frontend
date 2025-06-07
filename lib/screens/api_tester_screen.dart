import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTesterScreen extends StatefulWidget {
  @override
  _ApiTesterScreenState createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  final urlController = TextEditingController();
  final bodyController = TextEditingController();
  final headersController = TextEditingController();
  String selectedMethod = 'GET';
  String responseText = '';

  final backendUrl =
      'https://c02a-2409-40e5-10ac-704e-44f2-79e8-1682-d8c1.ngrok-free.app/test-api'; // backend API

  Future<void> sendRequest() async {
    final uri = Uri.parse(backendUrl);
    Map<String, String>? parsedHeaders;

    try {
      if (headersController.text.trim().isNotEmpty) {
        final rawHeaders = json.decode(headersController.text);
        if (rawHeaders is Map<String, dynamic>) {
          parsedHeaders = rawHeaders.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        } else {
          throw FormatException('Headers must be a JSON object');
        }
      }

      dynamic parsedBody;
      if (['POST', 'PUT'].contains(selectedMethod)) {
        if (bodyController.text.trim().isNotEmpty) {
          try {
            parsedBody = json.decode(bodyController.text);
          } catch (_) {
            parsedBody = bodyController.text;
          }
        }
      }

      final requestPayload = {
        "method": selectedMethod,
        "url": urlController.text.trim(),
        "headers": parsedHeaders,
        "body": parsedBody,
      };

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      setState(() {
        final fullResponse = json.decode(res.body);
        final bodyString = fullResponse['body'];
        dynamic bodyJson;
        try {
          bodyJson = json.decode(bodyString);
        } catch (_) {
          bodyJson = bodyString;
        }

        final prettyBody = JsonEncoder.withIndent('  ').convert(bodyJson);
        responseText = '✅ Status: ${res.statusCode}\n\n$prettyBody';
      });
    } catch (e) {
      setState(() {
        responseText = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBodyAllowed = selectedMethod == 'POST' || selectedMethod == 'PUT';

    return Scaffold(
      appBar: AppBar(
        title: Text('API Tester'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: 'Request URL',
                      prefixIcon: Icon(Icons.link, color: Colors.orangeAccent),
                    ),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMethod,
                    decoration: InputDecoration(
                      labelText: 'HTTP Method',
                      prefixIcon: Icon(Icons.swap_horiz,
                          color: Colors.orangeAccent),
                    ),
                    dropdownColor: Color(0xFF2D2D2D),
                    items: ['GET', 'POST', 'PUT', 'DELETE']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method,
                                  style: TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedMethod = value!),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: headersController,
                    decoration: InputDecoration(
                      labelText: 'Headers (JSON format)',
                      hintText: '{"Accept": "application/json"}',
                      prefixIcon:
                          Icon(Icons.list_alt, color: Colors.orangeAccent),
                    ),
                    maxLines: 3,
                  ),
                  if (isBodyAllowed) ...[
                    SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Body (JSON or raw text)',
                        hintText: '{"name": "John"}',
                        prefixIcon:
                            Icon(Icons.note_alt, color: Colors.orangeAccent),
                      ),
                    ),
                  ],
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: sendRequest,
                    child: Text('Send Request'),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Response:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      responseText,
                      style: TextStyle(
                          fontFamily: 'monospace', color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'Developed by Priyanshu Singh ❤️',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
