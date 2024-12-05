import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gwdg_fdo_application/utils/home.dart';
import 'package:gwdg_fdo_application/utils/register.dart';
import 'package:gwdg_fdo_application/views/camera_screen.dart';
import 'package:gwdg_fdo_application/views/detection.dart';
import 'package:gwdg_fdo_application/views/forgotpassword.dart';
import 'package:gwdg_fdo_application/views/login.dart';


late List<CameraDescription> cameras;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
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
        '/detection': (context) => DetectionPage(),
      },
    );
  }
}