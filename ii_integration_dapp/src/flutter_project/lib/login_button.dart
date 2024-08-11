import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';

class LoginButton extends StatefulWidget {
  final String url;
  final BuildContext context;

  LoginButton({required this.url, required this.context});

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _launchURL(widget.url, widget.context),
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
