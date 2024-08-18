import 'package:agent_dart/agent_dart.dart';
import 'package:flutter/material.dart';

import 'js_interop_service.dart';

import 'dart:convert' show JsonEncoder, jsonDecode, jsonEncode;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // ignore: use_super_parameters
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String loginResult = '';

  final jsinteropService = JsInteropService();

  final SignIdentity _testIdentity = generateKey();

  DelegationIdentity? convertJsonToDelegationIdentity(String jsonDelegation) {
    final obj = jsonDecode(jsonDelegation);
    DelegationChain? chain = DelegationChain.fromJSON(obj);

    return DelegationIdentity(_testIdentity, chain);
  }

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
                  String url_text = generateIdentityAndUrl(_testIdentity);
                  final String delegations =
                      await jsinteropService.login(url_text);
                  final UrlDecodedSubstring = Uri.decodeComponent(delegations);

                  DelegationIdentity? delegationIdentity =
                      convertJsonToDelegationIdentity(UrlDecodedSubstring);
                  //widget.updateIdentity(delegationIdentity);
                  setState(() {
                    // Principal p = i.getPrincipal();
                    loginResult =
                        'DelegationIdentity:{ ${printDelegationIdentityDetails(delegationIdentity!)}';
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

SignIdentity generateKey() {
  return Ed25519KeyIdentity.generate(null);
}

String generateIdentityAndUrl(SignIdentity key) {
  final sessionPublicKey = key.getPublicKey().toDer().toHex();
  final target = "sessionkey=$sessionPublicKey";
  return target;
}

String printDelegationIdentityDetails(DelegationIdentity delegationIdentity) {
  var delegations = delegationIdentity.getDelegation().toJSON();
  delegations = formatJson(jsonEncode(delegations));

  var publicKey = delegationIdentity.getPublicKey().toDer().toHex();

  var result =
      '"DelegationIdentity": {"mtlk_publicKey": $publicKey, "mtlk_delegations": $delegations}';

  //result = formatJson(result);

  // final result = 'DelegationIdentity: {mtlk publicKey: $publicKey, mtlk delegations: $delegations}';
  return result;
}

String formatJson(String jsonString) {
  var json = jsonDecode(jsonString);
  var formattedJson = JsonEncoder.withIndent('  ').convert(json);
  return formattedJson;
}
