import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebState();
  }
}

class _WebState extends State<WebViewScreen>
    with SingleTickerProviderStateMixin {
  final Completer<WebViewController> _wvController =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: _BackButton(_wvController.future),
          actions: <Widget>[_TerminateButton()],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  WebView(
                    initialUrl: 'https://www.baidu.com',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _wvController.complete(webViewController);
                    },
                    javascriptChannels: <JavascriptChannel>[].toSet(),
                    navigationDelegate: (NavigationRequest request) {
                      return NavigationDecision.navigate;
                    },
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    child: Container(color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void dispose() {
    super.dispose();
  }
}

class _TerminateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 60,
        child: Center(
          child: Image.asset(
            'graphics/close.png',
            width: 25,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final Future<WebViewController> _webViewControllerFuture;

  _BackButton(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (!webViewReady) {
              Navigator.pop(context);
              return;
            }
            if (await controller.canGoBack()) {
              controller.goBack();
              return;
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
