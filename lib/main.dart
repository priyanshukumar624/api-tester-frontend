import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/api_tester_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Use edgeToEdge to keep system buttons visible even in gesture mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(ApiTesterApp());
}

class ApiTesterApp extends StatelessWidget {
  const ApiTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Tester',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange[700],
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.deepOrangeAccent,
          surface: Color(0xFF2D2D2D),
          onPrimary: Colors.white,
          onSurface: Colors.white70,
        ),
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
      ),
      home: ApiTesterScreen(),
    );
  }
}
