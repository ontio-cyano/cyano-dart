import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen(
    this.url, {
    Key key,
    this.title = '',
  }) : super(key: key);

  @override
  _WebViewState createState() => new _WebViewState();
}

class _WebViewState extends State<WebViewScreen>
    with SingleTickerProviderStateMixin {
  final _webViewPlugin = FlutterWebviewPlugin();
  AnimationController _aniCtrl;
  Animation _ani;

  @override
  void initState() {
    super.initState();
    _webViewPlugin.onWebviewMessage.listen((message) {
      print(message);
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
              hidden: true,
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
        await _wv.evalJavascript('window.history.go(-1);');
        var after = await _wv.evalJavascript('location.href');
        if (prev == after) {
          _wv.close();
        }
      },
    );
  }
}
