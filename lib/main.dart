import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'login.dart';
import 'register.dart';
import 'forgotpassword.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgotpassword': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/camera': (context) => CameraScreen(),
      },
    );
  }
}
