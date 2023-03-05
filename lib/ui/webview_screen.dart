import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool loading = true;
  bool hasInternet = true;

  Future<bool> onGoBack() async {
    var canGoBack = await controller.canGoBack();
    if (canGoBack) {
      controller.goBack();
      return false;
    }
    return false;
  }

  Future<void> checkInternet() async {
    final connectivity = await (Connectivity().checkConnectivity());
    print(connectivity);
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        hasInternet = false;
      });
    }
  }

  @override
  void initState() {
    print(widget.url);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onGoBack,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: !hasInternet
            ? const Center(
                child: Text('Необходимо доступ к сети'),
              )
            : SafeArea(
                bottom: false,
                child: WebViewWidget(controller: controller),
              ),
      ),
    );
  }
}
