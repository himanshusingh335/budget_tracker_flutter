import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AskBudgetScreen extends StatefulWidget {
  const AskBudgetScreen({super.key});

  @override
  State<AskBudgetScreen> createState() => _AskBudgetScreenState();
}

class _AskBudgetScreenState extends State<AskBudgetScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'http://raspberrypi4.tailad9f80.ts.net:3000/?apiUrl=http://raspberrypi4.tailad9f80.ts.net:8123&assistantId=agent',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C47FF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
