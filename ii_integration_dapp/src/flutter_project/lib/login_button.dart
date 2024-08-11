import 'package:flutter/material.dart';

import 'package:flutter_project/constants.dart';


import 'package:agent_dart/agent/auth.dart' show SignIdentity;
import 'package:agent_dart/identity/ed25519.dart' show Ed25519KeyIdentity;
import 'package:agent_dart/utils/extension.dart'
    show U8aExtension
    hide U8aBufferExtension;

import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';

class LoginButton extends StatefulWidget {
  final BuildContext context;
  final SignIdentity _testIdentity;


  LoginButton(this.context, this._testIdentity);

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  String? _url_text;

  @override
  void initState() {
    super.initState();
    _url_text = generateIdentityAndUrl(widget._testIdentity);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _launchURL(_url_text!, widget.context),
      child: const Text('Open Browser'),
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
}

SignIdentity generateKey() {
  return Ed25519KeyIdentity.generate(null);
}

String generateIdentityAndUrl(SignIdentity key) {
  final sessionPublicKey = key.getPublicKey().toDer().toHex();
  final target = "${Constants.greetFrontendUrl}?sessionkey=$sessionPublicKey";
  return target;
}
