import 'package:flutter/material.dart';

import 'js_interop_service.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String loginResult = '';

  final jsinteropService = JsInteropService();

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
                child: Text('Login'),
                onPressed: () async {
                  final s = await jsinteropService.login();
                  setState(() {
                    loginResult = s;
                  });
                },
              ),
              loginResult != ''
                  ? Container(
                      padding: EdgeInsets.all(10.0), // Add some padding
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blueAccent), // Add border
                        borderRadius: BorderRadius.circular(
                            5.0), // Add border radius if you need
                      ),
                      child: Text('Login result: $loginResult'),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
