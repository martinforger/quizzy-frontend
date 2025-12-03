import 'package:flutter/material.dart';
import 'epica1/presentation/login/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen( onLogin: () {print('El usuario a iniciado sesion');}),
    );
  }
}
