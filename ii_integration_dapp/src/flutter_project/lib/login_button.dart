import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_project/constants.dart';

import 'package:agent_dart/agent/auth.dart' show SignIdentity, Identity;
import 'package:agent_dart/identity/ed25519.dart' show Ed25519KeyIdentity;
import 'package:agent_dart/identity/delegation.dart'
    show DelegationIdentity, DelegationChain;

import 'package:agent_dart/utils/extension.dart'
    show U8aExtension
    hide U8aBufferExtension;

import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';

class LoginButton extends StatefulWidget {
  final BuildContext context;
  final Function(Identity) updateIdentity;

  LoginButton({required this.context, required this.updateIdentity});

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  String? _url_text;
  SignIdentity? _testIdentity;
  StreamSubscription? _streamSubscription;

  // ignore: unused_field
  Uri? _initialURI;
  // ignore: unused_field
  Uri? _currentURI;

  DelegationIdentity? _delegationIdentity; //returning  from deep link

  @override
  void initState() {
    super.initState();
    _initUniLinks();
    _testIdentity = generateKey();
    _url_text = generateIdentityAndUrl(_testIdentity!);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

//          Text('Initial URI: $_initialURI\nCurrent URI: $_currentURI'),
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _launchURL(_url_text!, widget.context),
      child: const Text('Login'),
    );
  }

  void _launchURL(String url, BuildContext context) async {
    final localContext = context;

    final theme = Theme.of(localContext);
    try {
      await launchUrl(
        Uri.parse(url),
        options: LaunchOptions(
          barColor: theme.colorScheme.surface,
          onBarColor: theme.colorScheme.onSurface,
          barFixingEnabled: false,
        ),
      );
    } catch (e) {
      debugPrint("Failed to launch URL: $e");
      if (localContext.mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(content: Text("Failed to open URL: $e")),
        );
      }
    }
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
    widget.updateIdentity(_delegationIdentity!);
  }

  DelegationIdentity? convertJsonToDelegationIdentity(String jsonDelegation) {
    final obj = jsonDecode(jsonDelegation);
    DelegationChain? chain = DelegationChain.fromJSON(obj);

    return DelegationIdentity(_testIdentity!, chain);
  }
}

SignIdentity generateKey() {
  return Ed25519KeyIdentity.generate(null);
}

String generateIdentityAndUrl(SignIdentity key) {
  final sessionPublicKey = key.getPublicKey().toDer().toHex();
  final target = "${Constants.greetFrontendUrl}?sessionkey=$sessionPublicKey";
  return target;
}
