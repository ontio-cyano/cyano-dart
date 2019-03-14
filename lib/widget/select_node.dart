import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'toast.dart';
import 'package:cyano_dart/model/network.dart';

class NodeSelectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeSelectionState();
  }
}

class _NodeSelectionState extends State<NodeSelectionScreen>
    with NetworkManagerObserver {
  final _mainNodes = NetworkManager.mainNodes;
  final _testNodes = NetworkManager.testNodes;

  var _privateNode = '';
  var _scrollCtrl = ScrollController(initialScrollOffset: 0);
  var _selectedNode = '';
  var _privateUrlCtrl = new TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _loadNodes();
    NetworkManager.subscribe(this);
  }

  @override
  void dispose() {
    NetworkManager.unsubscribe(this);
    super.dispose();
  }

  @override
  onNodeChanged(String node) {
    _loadNodes();
  }

  @override
  onPrivateNodeChanged(String node) {
    toastSuccess('Change private network succeeds');
  }

  Future<void> _loadNodes() async {
    var nw = await NetworkManager.sington();
    setState(() {
      _selectedNode = nw.defaultNode;
      _privateNode = nw.privateNode;
    });
  }

  Future<void> _changeNode(node) async {
    var nw = await NetworkManager.sington();
    await nw.setDefaultNode(node);
  }

  List<Widget> get _mainNodeViews {
    var views = <Widget>[
      _SectionHeader(
        title: 'Main Net',
      )
    ];
    return views +
        _mainNodes
            .map((n) => _ListItemNode(n, n == _selectedNode, (url) {
                  _changeNode(url);
                }))
            .toList();
  }

  List<Widget> get _testNodeViews {
    var views = <Widget>[
      _SectionHeader(
        title: 'Test Net',
      ),
    ];
    return views +
        _testNodes
            .map((n) => _ListItemNode(n, n == _selectedNode, (url) {
                  _changeNode(url);
                }))
            .toList();
  }

  List<Widget> get _privateNodeViews {
    var views = <Widget>[
      _SectionHeader(
        title: 'Private Net',
      ),
      _ListItemNode(_privateNode, _privateNode == _selectedNode, (url) {
        _changeNode(url);
      }),
      Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: TextField(
          textInputAction: TextInputAction.done,
          controller: _privateUrlCtrl,
          keyboardType: TextInputType.url,
          style: TextStyle(fontSize: 13, color: Colors.black),
          decoration: InputDecoration(
              hintText: 'Please enter the address of your private network'),
          onSubmitted: (val) {
            if (val.isEmpty) return;

            var ok = _mainNodes.indexOf(val) == -1 &&
                _testNodes.indexOf(val) == -1 &&
                isURL(val, {
                  'protocols': ['http', 'https']
                });
            if (!ok) {
              toastError('Invalid url');
              return;
            }
            _privateUrlCtrl.clear();
            toastSuccess('Change private network succeeds');
            setState(() {
              if (_privateNode == _selectedNode) {
                _selectedNode = val;
              }
              _privateNode = val;
            });
          },
        ),
      )
    ];
    return views;
  }

  @override
  Widget build(BuildContext context) {
    var children = _mainNodeViews + _testNodeViews + _privateNodeViews;

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.cyan,
          leading: BackButton(color: Colors.white),
          title: Text(
            'Select Node',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                child: Column(children: children),
              ),
            ),
            Container(
              height: 30,
            )
          ],
        ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  _SectionHeader({this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        height: 50,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 8,
              bottom: 8,
              child: Text(
                title,
                style: TextStyle(color: Color(0xff6E6F70)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef _NodeSelectedCallback = void Function(String url);

class _ListItemNode extends StatelessWidget {
  final String url;
  final bool active;
  final _NodeSelectedCallback cb;

  _ListItemNode(this.url, this.active, this.cb);

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

    if (active) {
      children.add(Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              'graphics/default_icon.png',
              width: 20,
            ),
          ),
        ),
      ));
    }

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
