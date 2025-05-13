import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/login/homepage.dart';
import 'features/login/loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final empId = prefs.getString('empId') ?? '';

  runApp(MyApp(isLoggedIn: isLoggedIn, empId: empId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String empId;

  const MyApp({super.key, required this.isLoggedIn, required this.empId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEPTON',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7453A1),
          primary: const Color(0xFF7453A1),
          secondary: const Color(0xFF435EA6),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7453A1),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7453A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF435EA6), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: const TextStyle(color: Color(0xFF435EA6)),
        ),
      ),
      home: isLoggedIn ? HomePage(empId: empId) : const LoginPage(),
    );
  }
}
