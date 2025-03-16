import 'package:flutter/material.dart';
import 'package:watchface/pages/watchface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WatchFace(),
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey[400]),
      debugShowCheckedModeBanner: false,
    );
  }
}