import 'dart:async';
import 'dart:convert';

import 'package:agent_dart/agent_dart.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';


import 'dart:io';
import 'dart:typed_data';

import 'package:agent_dart/agent/auth.dart'
 show SignIdentity
;
// import 'package:agent_dart/identity/delegation.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:agent_dart/auth_client/auth_client.dart';
import 'package:agent_dart/utils/extension.dart'
 show U8aExtension hide U8aBufferExtension
;
import 'package:agent_dart/identity/ed25519.dart'
 show Ed25519KeyIdentity
;

// ignore: constant_identifier_names
const KEY_LOCALSTORAGE_KEY = 'identity'; //mtlk todo internetidentity insdead ?
// ignore: constant_identifier_names
const KEY_LOCALSTORAGE_DELEGATION = 'delegation';


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

  Uri? _initialURI;
  Uri? _currentURI;
  StreamSubscription? _streamSubscription;
  DelegationIdentity? _delegationIdentity;


  @override
  void initState() {
    super.initState();
    _initUniLinks();
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
  void OnDeepLinkActivated(String url)
  {
      if (url.isEmpty) {
        return;
      }

      const kDelegationParam = "delegation=";
      var indexOfDelegation = url.indexOf(kDelegationParam);
      if (indexOfDelegation == -1)
      {
          print("Cannot find delegation");
          return;
      }
    var map = Map<String, dynamic>.from(jsonDecode(url));
    var identityString = map[KEY_LOCALSTORAGE_KEY] as String?;
    var delegationString = map[KEY_LOCALSTORAGE_DELEGATION] as String?;

    SignIdentity? key = identityString != null
        ? Ed25519KeyIdentity.fromJSON(identityString)
        : null;
    DelegationChain? chain = delegationString != null
        ? DelegationChain.fromJSON(delegationString)
        : null;

    DelegationIdentity? identity;

    if (chain != null && !isDelegationValid(chain, null)) {
      key = null;
    } else {
      _delegationIdentity = DelegationIdentity.fromDelegation(key!, chain!);
    }
    // return FromStorageResult(
    //     delegationChain: chain,
    //     signIdentity: key,
    //     delegationIdentity: identity);      //mTestICPAgent.DelegationIdentity = ConvertJsonToDelegationIdentity(delegationString);


  }



  

  //       internal DelegationIdentity ConvertJsonToDelegationIdentity(string jsonDelegation)
  //       {
  //           var delegationChainModel = JsonConvert.DeserializeObject<DelegationChainModel>(jsonDelegation);
  //           if (delegationChainModel == null && delegationChainModel.delegations.Length == 0)
  //           {
  //               Debug.LogError("Invalid delegation chain.");
  //               return null;
  //           }

  //           // Initialize DelegationIdentity.
  //           var delegations = new List<SignedDelegation>();
  //           foreach (var signedDelegationModel in delegationChainModel.delegations)
  //           {
  //               var pubKey = SubjectPublicKeyInfo.FromDerEncoding(ByteUtil.FromHexString(signedDelegationModel.delegation.pubkey));
  //               var expiration = ICTimestamp.FromNanoSeconds(Convert.ToUInt64(signedDelegationModel.delegation.expiration, 16));
  //               var delegation = new Delegation(pubKey, expiration);

  //               var signature = ByteUtil.FromHexString(signedDelegationModel.signature);
  //               var signedDelegation = new SignedDelegation(delegation, signature);
  //               delegations.Add(signedDelegation);
  //           }

  //           var chainPublicKey = SubjectPublicKeyInfo.FromDerEncoding(ByteUtil.FromHexString(delegationChainModel.publicKey));
  //           var delegationChain = new DelegationChain(chainPublicKey, delegations);
  //           var delegationIdentity = new DelegationIdentity(mTestICPAgent.TestIdentity, delegationChain);

  //           return delegationIdentity;
  //       }
  //   }  
  // the above in dart :
   // DelegationIdentity ConvertJsonToDelegationIdentity(String jsonDelegation)
  //  {
  //    DelegationChain? chain = jsonDelegation != null
  //       ? DelegationChain.fromJSON(jsonDelegation)
  //       : null;

  //   DelegationIdentity? identity;

  //   if (chain != null && !isDelegationValid(chain, null)) {
  //     key = null;
  //   } else {
  //     identity = DelegationIdentity.fromDelegation(key!, chain!);
  //   }
  

  //       var chainPublicKey = SubjectPublicKeyInfo.FromDerEncoding(ByteUtil.FromHexString(delegationChainModel.publicKey));
  //       var delegationChain = new DelegationChain(chainPublicKey, delegations);
  //       var delegationIdentity = new DelegationIdentity(mTestICPAgent.TestIdentity, delegationChain);
  
  //       return delegationIdentity;
  //       return DelegationIdentity();  
  //  }
  





    //     private async void CallCanisterGreet()
    //     {
    //         if (DelegationIdentity == null)
    //             return;

    //         // Initialize HttpAgent.
    //         var agent = new HttpAgent(DelegationIdentity);

    //         var canisterId = Principal.FromText(greetBackendCanister);

    //         // Initialize the client and make the call.
    //         var client = new GreetingClient.GreetingClient(agent, canisterId);
    //         var content = await client.Greet();

    //         if (mMyPrincipalText != null)
    //             mMyPrincipalText.text = content;
    //     }
    // }
    // the above in dart
    void CallCanisterGreet()
    {
      //zrób tutaj normalne odpalenie do baclendu czyli ICPconector mtlk todo
      // no i test czy to sie łączy z backendem przez delegowaną identity
      
    }


  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }


  final TextEditingController _urlController = TextEditingController(text:generateIdentityAndUrl());

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

String generateIdentityAndUrl() {
    SignIdentity key = Ed25519KeyIdentity.generate(null);
    
    final sessionPublicKey =  key.getPublicKey().toDer().toHex() ;       

    const greetFrontend = "https://qsgof-4qaaa-aaaan-qekqq-cai.icp0.io/";

    final target = "$greetFrontend?sessionkey=$sessionPublicKey";

    return target;
}
