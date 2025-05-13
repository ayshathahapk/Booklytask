import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:booklytask/utils/password_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse(
      "https://neptonglobal.co.in/Master/schedule/getuser.php",
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] == 1) {
          final empID = data['empID'] ?? '';
          final encodedPassword = data['pswd'] ?? '';
          final decodedPassword = gvremakecode(encodedPassword);
          print('decodedPassword : $decodedPassword');


          if (password == decodedPassword) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username);
            await prefs.setString('password', password);
            await prefs.setString('empId', empID); // ✅ Save empID
            await prefs.setBool('isLoggedIn', true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(empId: empID)),
            );
          }

          // if (password == decodedPassword) {
          //   final prefs = await SharedPreferences.getInstance();
          //   await prefs.setString('username', username);
          //   await prefs.setString('password', password);
          //   await prefs.setBool('isLoggedIn', true);
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (_) => HomePage(empId: empID)),
          //   );
          // }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect password.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final message = data['message'] ?? 'Username not found.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server error: ${response.statusCode}. Please try again later.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unexpected error occurred. Please check your internet connection and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          Container(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'STAFF SCHEDULES',
                    style: TextStyle(
                      fontSize: w * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: w * 0.1),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.025),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.04),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: 'username',
                              hintText: 'Enter username',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: w * 0.06),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: w * 0.02),
                          SizedBox(height: w * 0.04),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.3,
                                vertical: w * 0.035,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _handleLogin(context),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
