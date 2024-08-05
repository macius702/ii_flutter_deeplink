import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Deep Link Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Deep Link Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latestLink = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
    } catch (e) {
      // Handle exception by warning the user their action did not succeed
      // return SnackBar(content: Text("Failed to open link"));
    }

    // Attach a listener to the links stream
    getLinksStream().listen((String link) {
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null` if the `link` is in the format `uni_links://example.com/xyz`
      setState(() {
        _latestLink = link;
      });
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Latest link: $_latestLink\n'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchURL,
        tooltip: 'Open Browser',
        child: const Icon(Icons.open_in_browser),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://your-website.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}