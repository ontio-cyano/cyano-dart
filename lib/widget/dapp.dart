import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cyano_dart/api.dart';
import 'webview.dart';
import 'package:cyano_dart/model/debug_history.dart';
import 'package:validators/validators.dart';

class DAppWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DappState();
  }
}

class _DappState extends State<DAppWidget> with DebugHistoryObserver {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();

  var _banner = <dynamic>[];
  var _apps = <dynamic>[];
  var _history = <String>[];

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _updateHistory();
    DebugHistory.subscribe(this);
  }

  @override
  void dispose() {
    DebugHistory.unsubscribe(this);
    super.dispose();
  }

  @override
  onRecordsUpdated() {
    _updateHistory();
  }

  _safeSetState(VoidCallback cb) {
    if (!mounted) return;
    setState(cb);
  }

  Future<void> _loadBanner() async {
    var apps = await fetchApps();
    _safeSetState(() {
      _banner = apps['banner'];
      _apps = apps['apps'];
    });
  }

  Future<void> _updateHistory() async {
    var hm = await DebugHistory.sington();
    _safeSetState(() {
      _history = hm.records;
    });
  }

  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WebViewScreen(url), fullscreenDialog: true),
    );
  }

  Widget _makeCarousel() {
    if (_banner.length == 0) return Container();
    return CarouselSlider(
      height: 150,
      viewportFraction: 1.0,
      aspectRatio: 2.0,
      autoPlay: true,
      enlargeCenterPage: false,
      items: _banner.map((b) {
        return InkWell(
          child: FadeInImage(
            placeholder: AssetImage('graphics/transparent.png'),
            image: NetworkImage(b['image']),
            fit: BoxFit.fitWidth,
          ),
          onTap: () {
            _openWebView(b['link']);
          },
        );
      }).toList(),
    );
  }

  List<Widget> _makeAppViews() {
    double w = 100;
    return _apps.map((app) {
      return SizedBox(
        width: w,
        height: 85,
        child: InkWell(
          child: Stack(
            children: <Widget>[
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: FadeInImage(
                      placeholder: AssetImage('graphics/transparent.png'),
                      image: NetworkImage(app['icon']),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                width: w,
                height: 10,
                child: Container(
                  child: Center(
                    child: Text(app['name']),
                  ),
                ),
              )
            ],
          ),
          onTap: () {
            _openWebView(app['link']);
          },
        ),
      );
    }).toList();
  }

  Future<void> _openDebugView(String url) async {
    var hm = await DebugHistory.sington();
    await hm.addRecord(url);
    _openWebView(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: _makeCarousel(),
          ),
        ),
        Expanded(
          child: new DefaultTabController(
            length: 2,
            child: new Scaffold(
              appBar: new PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: new Container(
                  height: 50,
                  child: new TabBar(
                    tabs: [
                      Container(
                        height: 50,
                        child: Center(
                          child: Text('Apps'),
                        ),
                      ),
                      Container(
                        height: 50,
                        child: Center(
                          child: Text('Private Apps'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: _makeAppViews(),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        width: MediaQuery.of(context).size.width - 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Please input the link of your app to debug'),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _urlCtrl,
                                keyboardType: TextInputType.url,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Url cannot be empty';
                                  if (!isURL(value))
                                    return 'A valid URL is required';
                                },
                              ),
                              Container(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RaisedButton(
                                  padding: const EdgeInsets.all(8.0),
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  textColor: Colors.white,
                                  color: Colors.cyan,
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _openDebugView(_urlCtrl.text);
                                    }
                                  },
                                  child: new Text(
                                    "GO",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  highlightElevation: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        // width: 10,
                        margin: EdgeInsets.only(top: 15),
                        color: Colors.grey,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15, left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('History'),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _history.length,
                          itemExtent: 50,
                          itemBuilder: (context, index) {
                            return _ListItemNode(_history[index], (url) {
                              _openWebView(url);
                            });
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

typedef _ItemClickedCallback = void Function(String url);

class _ListItemNode extends StatelessWidget {
  final String url;
  final _ItemClickedCallback cb;

  _ListItemNode(this.url, this.cb);

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    var children = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 5),
          child: Text(
            url,
            style: TextStyle(fontSize: 14),
          ),
        ),
      )
    ];

    return InkWell(
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 20, right: 20),
        decoration: new BoxDecoration(
          border: border,
        ),
        child: Row(
          children: children,
        ),
      ),
      onTap: () {
        cb(url);
      },
    );
  }
}
