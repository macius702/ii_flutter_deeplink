import 'package:flutter/material.dart';

import 'js_interop_service.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

void main() async{
  //await dotenv.dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final jsinteropService =  JsInteropService();

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
              ElevatedButton(
                  onPressed: () {
                    jsinteropService.getSomeAsyncData();
                  },
                  child: Text('Get some async data')),
              ElevatedButton(
                  onPressed: () {
                    jsinteropService.login();
                  },
                  child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
