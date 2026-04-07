import 'package:flutter/material.dart';
import 'package:quiz_app/utils/constants.dart';
import 'screens/quiz_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 181, 228, 255),
      ),
      home: QuizScreen(),
    );
  }
}