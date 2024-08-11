import 'package:agent_dart/identity/delegation.dart' show DelegationIdentity;

import 'package:flutter/material.dart';
import 'package:flutter_project/ICP/ICP_Connector.dart';
import 'package:flutter_project/greeting_client.dart';
import 'package:flutter_project/login_button.dart';

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
  DelegationIdentity? _delegationIdentity;

  String _greetText = '';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Linking Example')),
      body: ListView(
        children: <Widget>[
          LoginButton(
              context: context,
              updateDelegationIdentity: (identity) {
                setState(() {
                  _delegationIdentity = identity;
                });
              }),
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
