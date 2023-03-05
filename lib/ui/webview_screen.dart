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
  WebViewController? controller;
  bool hasInternet = true;

  Future<void> checkInternet() async {
    final connectivity = await (Connectivity().checkConnectivity());
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        hasInternet = false;
      });
    }
  }

  @override
  void initState() {
    checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: !hasInternet
          ? const Center(
              child: Text('Необходимо доступ к сети'),
            )
          : SafeArea(
              bottom: false,
              child: Builder(builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async {
                    if (await controller!.canGoBack()) {
                      controller!.goBack();
                    }
                    return false;
                  },
                  child: WebView(
                    initialUrl: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      controller = webViewController;
                    },
                    gestureNavigationEnabled: true,
                  ),
                );
              }),
            ),
    );
  }
}
