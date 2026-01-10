import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(QuizzyApp(sharedPreferences: sharedPreferences));
}
