import 'dart:js_interop' show importModule, JSAny;

import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Interop javascript Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {

            },
            child: const Text('Text: Interop javascript'),
          ),
        ),
      ),
    );
  }
}


