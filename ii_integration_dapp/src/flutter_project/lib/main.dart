import 'dart:async';
import 'dart:convert';

import 'package:agent_dart/agent/auth.dart' show SignIdentity;
import 'package:agent_dart/identity/delegation.dart'
    show DelegationIdentity, DelegationChain;

import 'package:flutter/material.dart';
import 'package:flutter_project/ICP/ICP_Connector.dart';
import 'package:flutter_project/greeting_client.dart';
import 'package:flutter_project/login_button.dart';
import 'package:uni_links/uni_links.dart';

import 'package:flutter_project/constants.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uri? _initialURI;
  Uri? _currentURI;
  SignIdentity? _testIdentity;

  StreamSubscription? _streamSubscription;
  DelegationIdentity? _delegationIdentity;

  String _greetText = '';

  @override
  void initState() {
    super.initState();
    _initUniLinks();
    _testIdentity = generateKey();
  }

  Future<void> _initUniLinks() async {
    final localContext = context;

    try {
      _initialURI = await getInitialUri();
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(content: Text("Failed to open link: $e")),
        );
      }
    }

    _streamSubscription = linkStream.listen((String? link) {
      if (link != null) {
        setState(() {
          _currentURI = Uri.parse(link);
          onDeepLinkActivated(link);
        });
      }
    }, onError: (err) {
      debugPrint("Error listening to link stream: $err");
    });
  }

  void onDeepLinkActivated(String url) {
    if (url.isEmpty) return;

    const kDelegationParam = "delegation=";
    var indexOfDelegation = url.indexOf(kDelegationParam);
    if (indexOfDelegation == -1) {
      print("Cannot find delegation");
      return;
    }

    String substring =
        url.substring(indexOfDelegation + kDelegationParam.length);

    final UrlDecodedSubstring = Uri.decodeComponent(substring);

    _delegationIdentity = convertJsonToDelegationIdentity(UrlDecodedSubstring);
  }

  DelegationIdentity? convertJsonToDelegationIdentity(String jsonDelegation) {
    final obj = jsonDecode(jsonDelegation);
    DelegationChain? chain = DelegationChain.fromJSON(obj);

    return DelegationIdentity(_testIdentity!, chain);
  }

  Future<String?> callCanisterGreet() async {
    //zrób tutaj normalne odpalenie do baclendu czyli ICPconector mtlk todo
    // no i test czy to sie łączy z backendem przez delegowaną identity

    if (_delegationIdentity == null) {
      return null;
    }

    final icpConnector = await ICPconnector.init(
      identity: _delegationIdentity,
      newIdl: BackendMethod.idl,
      a_backendCanisterId: Constants.greetBackendCanister,
    );

    final client = GreetingClient(icpConnector);
    final content = await client.greet();
    return content;

    // if (mMyPrincipalText != null)
    //     mMyPrincipalText.text = content;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Linking Example')),
      body: ListView(
        children: <Widget>[
          Text('Initial URI: $_initialURI\nCurrent URI: $_currentURI'),
          LoginButton(context, _testIdentity!),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _greetText = 'Loading...'; // Show loading state
              });
              final s = await callCanisterGreet();
              setState(() {
                _greetText = s ?? 'Error';
              });
            },
            child: const Text('Call Canister Greet'),
          ),
          Text(_greetText),
        ],
      ),
    );
  }
}
