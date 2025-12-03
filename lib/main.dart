import 'package:flutter/material.dart';
import 'features/epica1/presentation/login/login_screen.dart';
import 'features/epica1/presentation/profile/profile_screen.dart';
void main() {
  runApp(MyApp());
}

/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen( onLogin: () {print('El usuario a iniciado sesion');}),
    );
  }
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(
        onLogout: () {},
      ),
    );
  }
}
