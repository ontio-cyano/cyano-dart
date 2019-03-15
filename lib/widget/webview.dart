import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cyano_dart/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cyano_dart/widget/wallet/password.dart';

class CommunityWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const CommunityWebViewScreen(
    this.url, {
    Key key,
    this.title = '',
  }) : super(key: key);

  @override
  _CommunityWebViewState createState() => new _CommunityWebViewState();
}

class _CommunityWebViewState extends State<CommunityWebViewScreen>
    with SingleTickerProviderStateMixin {
  final _webViewPlugin = FlutterWebviewPlugin();

  AnimationController _aniCtrl;
  Animation _ani;

  Providor _providor;

  Providor get providor {
    if (_providor == null) {
      _providor = Providor(context);
      _providor.addSender(JsResponseSender(_webViewPlugin));
      _providor.addSender(HttpResponseSender());
    }
    return _providor;
  }

  @override
  void initState() {
    super.initState();
    _webViewPlugin.onWebviewMessage.listen((message) {
      providor.process(message);
    });
    _webViewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        var disableZoom = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);";
        await _webViewPlugin.evalJavascript(disableZoom);
        await _webViewPlugin.linkBridge();
        _aniCtrl.forward(from: MediaQuery.of(context).size.width);
      } else if (state.type == WebViewState.startLoad) {
        _aniCtrl.forward(from: 0);
      }
    });
    _webViewPlugin.onDestroy.listen((_) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
    _aniCtrl =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation curve =
        CurvedAnimation(parent: _aniCtrl, curve: Curves.easeInOut);
    _ani = Tween<double>(begin: 0, end: 1000).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(''),
      backgroundColor: Colors.white,
      leading: _BackButton(_webViewPlugin),
      actions: <Widget>[
        Container(
          width: 60,
          child: Center(
            child: _TerminateButton(_webViewPlugin),
          ),
        )
      ],
    );

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Container(
        child: Stack(
          children: <Widget>[
            WebviewScaffold(
              appBar: appBar,
              url: widget.url,
              withZoom: false,
              withJavascript: true,
              withLocalStorage: true,
            ),
            appBar,
            SafeArea(
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: appBar.preferredSize.height - 1,
                      left: 0,
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: _ani.value,
                          height: 1,
                          child: Container(color: Colors.cyan),
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webViewPlugin.dispose();
    _aniCtrl.dispose();
    super.dispose();
  }
}

class _TerminateButton extends StatelessWidget {
  final FlutterWebviewPlugin _wv;

  _TerminateButton(this._wv);

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
        _wv.close();
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final FlutterWebviewPlugin _wv;

  _BackButton(this._wv);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () async {
        var prev = await _wv.evalJavascript('location.href');
        await _wv.goBack();
        await new Future.delayed(const Duration(milliseconds: 100));
        var after = await _wv.evalJavascript('location.href');
        if (prev == after) {
          _wv.close();
        }
      },
    );
  }
}

class WebViewWidget extends StatefulWidget {
  final String url;

  WebViewWidget(this.url);

  @override
  _WebViewWidgetState createState() => new _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  final _controller = Completer<WebViewController>();

  Providor _providor;

  Future<Providor> get providor async {
    if (_providor == null) {
      _providor = Providor(context);
      _providor.addSender(JsResponseSender1(await _controller.future));
      _providor.addSender(HttpResponseSender());
    }
    return _providor;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _disableZoom() async {
    var ctrl = await _controller.future;
    var disableZoom = """
     (function () {
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      var head = document.getElementsByTagName('head')[0];
      head.appendChild(meta);
    })();
     """;
    await ctrl.evaluateJavascript(disableZoom);
  }

  Future<void> _linkBrigde() async {
    var ctrl = await _controller.future;
    var js = """
        (function () {
          window.originalPostMessage = window.postMessage;
          window.postMessage = function (data) {
            Ontology.postMessage(data);
          };
        })();
        """;
    await ctrl.evaluateJavascript(js);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: _BackButton1(_controller),
        actions: <Widget>[
          Container(
            width: 60,
            child: Center(
              child: _TerminateButton1(_controller),
            ),
          )
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[
            _ontoMessageChannel(context),
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            _linkBrigde();
            _disableZoom();
          },
        );
      }),
    );
  }

  Future<void> _handleOntoMessage(String message) async {
    var p = await providor;
    await p.process(message);
  }

  JavascriptChannel _ontoMessageChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Ontology',
        onMessageReceived: (JavascriptMessage message) {
          _handleOntoMessage(message.message);
        });
  }
}

class _BackButton1 extends StatelessWidget {
  final Completer<WebViewController> _wvFuture;

  _BackButton1(this._wvFuture);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _wvFuture.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (!webViewReady) return;
            if (await controller.canGoBack()) {
              controller.goBack();
            } else {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }
}

class _TerminateButton1 extends StatelessWidget {
  final Completer<WebViewController> _wvFuture;

  _TerminateButton1(this._wvFuture);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _wvFuture.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
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
      },
    );
  }
}
