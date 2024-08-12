import 'package:flutter/material.dart';
import 'package:js/js.dart';

import 'js_interop_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final jsinteropService =  JsInteropService()  

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
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                  onPressed: () {
                    jsinteropService.showAlert('Hello from Flutter');
                  },
                  child: Text('Show alert')),
              ElevatedButton(
                  onPressed: () {
                    jsinteropService.requestFullScreen();
                  },
                  child: Text('Request Fullscreen')),
            ],
          ),
        ),
      ),
    );
  }
}
