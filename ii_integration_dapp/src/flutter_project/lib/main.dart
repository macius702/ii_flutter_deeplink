// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:agent_dart/agent_dart.dart';
import 'package:agent_dart/principal/principal.dart';
import 'package:agent_dart/protobuf/ic_ledger/pb/v1/types.pbjson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/ICP/ICP_Connector.dart';
import 'package:flutter_project/greeting_client.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'dart:convert' as convert;

import 'dart:io';
import 'dart:typed_data';

import 'package:agent_dart/agent/auth.dart' show SignIdentity;
// import 'package:agent_dart/identity/delegation.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:agent_dart/auth_client/auth_client.dart';
import 'package:agent_dart/utils/extension.dart'
    show U8aExtension
    hide U8aBufferExtension;
import 'package:agent_dart/identity/ed25519.dart' show Ed25519KeyIdentity;



// ignore: constant_identifier_names
const KEY_LOCALSTORAGE_KEY = 'identity'; //mtlk todo internetidentity insdead ?
// ignore: constant_identifier_names
const KEY_LOCALSTORAGE_DELEGATION = 'delegation';

void main() async {
  final icpConnector = await ICPconnector.init(newIdl: BackendMethod.idl);


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

SignIdentity generateKey() {
  return Ed25519KeyIdentity.generate(null);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const greetBackendCanister = "qvhir-riaaa-aaaan-qekqa-cai";

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
    _urlController.text = generateIdentityAndUrl(_testIdentity!);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _initialURI = await getInitialUri();
    } catch (e) {
      // Handle exception by warning the user their action did not succeed
      // return SnackBar(content: Text("Failed to open link"));
    }

    // Listen for incoming links
    _streamSubscription = linkStream.listen((String? link) {
      if (link != null) {
        setState(() {
          _currentURI = Uri.parse(link);
          String uriString = _currentURI?.toString() ?? 'default_value';
          OnDeepLinkActivated(uriString);
        });
      }
    }, onError: (err) {
      // Handle error
    });
  }

  // public void OnDeepLinkActivated(string url)
  //       {
  //           if (string.IsNullOrEmpty(url))
  //               return;

  //           const string kDelegationParam = "delegation=";
  //           var indexOfDelegation = url.IndexOf(kDelegationParam);
  //           if (indexOfDelegation == -1)
  //           {
  //               Debug.LogError("Cannot find delegation");
  //               return;
  //           }

  //           var delegationString = HttpUtility.UrlDecode(url.Substring(indexOfDelegation + kDelegationParam.Length));
  //           mTestICPAgent.DelegationIdentity = ConvertJsonToDelegationIdentity(delegationString);
  //       }
  // above function in dart:
  void OnDeepLinkActivated(String url) {
    if (url.isEmpty) {
      return;
    }

    const kDelegationParam = "delegation=";
    var indexOfDelegation = url.indexOf(kDelegationParam);
    if (indexOfDelegation == -1) {
      print("Cannot find delegation");
      return;
    }

    String substring =
        url.substring(indexOfDelegation + kDelegationParam.length);

    final UrlDecodedSubstring = Uri.decodeComponent(substring);

    // final decoded = jsonDecode(UrlDecodedSubstring);

    // Map<String, dynamic> delegationsMap = {
    //   "delegations": decoded["delegations"]
    // };

    // var map = Map<String, dynamic>.from(decoded);
    // // var identityString = map[KEY_LOCALSTORAGE_KEY] as String?;
    // // var delegationString = map[KEY_LOCALSTORAGE_DELEGATION] as String?;

    // String identityString = map['publicKey'];

    _delegationIdentity = ConvertJsonToDelegationIdentity(UrlDecodedSubstring);
  }

  DelegationIdentity? ConvertJsonToDelegationIdentity(String jsonDelegation) {
    final obj = jsonDecode(jsonDelegation);
    DelegationChain? chain =
        jsonDelegation != null ? DelegationChain.fromJSON(obj) : null;

    if (chain == null) {
      return null;
    }

    // // Initialize DelegationIdentity.
    // List<SignedDelegation> delegations = [];
    // for (var signedDelegation in chain.delegations) {
    //   print('In for loop');
    //       final cus = signedDelegation.delegation?.pubkey;
    //       // now hex decode cus
    //       final decoded = convert.hex.decode(cus);
    //       final pubKey = PublicKey.fromDerEncoding(decoded);

    // }

    // var chainPublicKey = SubjectPublicKeyInfo.fromDerEncoding(hex.decode(delegationChainModel['publicKey']));
    // var delegationChain = DelegationChain(chainPublicKey, delegations);
    // var delegationIdentity = DelegationIdentity(mTestICPAgent.testIdentity, delegationChain);

    //return delegationIdentity;

    return DelegationIdentity(_testIdentity!, chain);
  }

  Future<String?> CallCanisterGreet() async {
    //zrób tutaj normalne odpalenie do baclendu czyli ICPconector mtlk todo
    // no i test czy to sie łączy z backendem przez delegowaną identity
    if (_delegationIdentity == null) {
      return null;
    }

    final icpConnector = await ICPconnector.init(
        identity: _delegationIdentity,
        newIdl: BackendMethod.idl,
        a_backendCanisterId: greetBackendCanister);

    final client = GreetingClient(icpConnector);

    // // Initialize HttpAgent.
    // final options = HttpAgentOptions()..identity = _delegationIdentity;
    // final agent = HttpAgent(options: options);

    // //create canisterId using Principal from string
    // final canisterId = Principal.fromText(greetBackendCanister);

    // final client = GreetingClient(_delegationIdentity, greetBackendCanister);

    final content = await client.Greet();
    return content;

    // if (mMyPrincipalText != null)
    //     mMyPrincipalText.text = content;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Deep Linking Example')),
        body: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Initial URI: $_initialURI\nCurrent URI: $_currentURI'),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter URL',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _launchURL(_urlController.text, context),
              child: const Text('Open Browser'),
            ),
            ElevatedButton(
              onPressed: () async  {
                final s = await CallCanisterGreet();
                setState(() {
                  _greetText = s ?? 'Error';
                });
              },
              
              child: const Text('Call Canister Greet'),
            ),
            Text(_greetText),
          ],
        ),
      ),
    );
  }

  // public string greetFrontend = "https://qsgof-4qaaa-aaaan-qekqq-cai.icp0.io/";

  //  public void OpenBrowser()
  //   {
  //       var target = mTestICPAgent.greetFrontend + "?sessionkey=" + ByteUtil.ToHexString(mTestICPAgent.TestIdentity.PublicKey.ToDerEncoding());
  //       Application.OpenURL(target);
  //   }

// void _launchURL(String urlString) async {
//   try {
//     await launch(urlString);
//   } catch (e) {
//     print('Could not launch $urlString: $e');
//   }
// }
  // void _launchURL(String text) async {

  //   //const url = 'https://qsgof-4qaaa-aaaan-qekqq-cai.icp0.io/';
  //   final Uri uri = Uri.parse(text);

  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $uri';
  //   }
  // }

  void _launchURL(String url, BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse(url),
        //Uri.parse('https://qsgof-4qaaa-aaaan-qekqq-cai.icp0.io'),
        //Uri.parse('https://www.wp.pl'),
        //Uri.parse('https://flutter.dev'),
        options: LaunchOptions(
          barColor: theme.colorScheme.surface,
          onBarColor: theme.colorScheme.onSurface,
          barFixingEnabled: false,
        ),
      );
    } catch (e) {
      // If the URL launch fails, an exception will be thrown. (For example, if no browser app is installed on the Android device.)
      debugPrint(e.toString());
    }
  }

  //  public void OpenBrowser()
  //   {
  //       var target = mTestICPAgent.greetFrontend + "?sessionkey=" + ByteUtil.ToHexString(mTestICPAgent.TestIdentity.PublicKey.ToDerEncoding());
  //       Application.OpenURL(target);
  //   }
}

String generateIdentityAndUrl(SignIdentity key) {
  final sessionPublicKey = key.getPublicKey().toDer().toHex();

  const greetFrontend = "https://qsgof-4qaaa-aaaan-qekqq-cai.icp0.io/";

  final target = "$greetFrontend?sessionkey=$sessionPublicKey";

  return target;
}
