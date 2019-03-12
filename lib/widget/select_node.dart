import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'toast.dart';

class NodeSelectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeSelectionState();
  }
}

class _NodeSelectionState extends State<NodeSelectionScreen> {
  final _mainNodes = [
    'http://dappnode1.ont.io',
    'http://dappnode2.ont.io',
    'http://dappnode3.ont.io',
    'http://dappnode4.ont.io'
  ];

  final _testNodes = [
    'http://polaris1.ont.io',
    'http://polaris2.ont.io',
    'http://polaris3.ont.io',
    'http://polaris4.ont.io',
    'http://polaris5.ont.io',
  ];

  var _privateNode = 'http://127.0.0.1';

  var _scrollCtrl = ScrollController(initialScrollOffset: 0);

  var _selectedNode = '';

  var _privateUrlCtrl = new TextEditingController(text: '');

  List<Widget> get _mainNodeViews {
    var views = <Widget>[
      _SectionHeader(
        title: 'Main Net',
      )
    ];
    return views +
        _mainNodes
            .map((n) => _ListItemNode(n, n == _selectedNode, (url) {
                  setState(() {
                    _selectedNode = url;
                  });
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
                  setState(() {
                    _selectedNode = url;
                  });
                }))
            .toList();
  }

  List<Widget> get _privateNodeViews {
    var views = <Widget>[
      _SectionHeader(
        title: 'Private Net',
      ),
      _ListItemNode(_privateNode, _privateNode == _selectedNode, (url) {
        setState(() {
          _selectedNode = url;
        });
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
                child: Column(children: children
                    // <Widget>[
                    // _SectionHeader(
                    // title: 'Main Net',
                    // ),

                    // ListView.builder(
                    // shrinkWrap: true,
                    // padding: EdgeInsets.all(0),
                    // itemExtent: 50,
                    // itemCount: _mainNodes.length,
                    // itemBuilder: (ctx, idx) {
                    // return _ListItemNode(_mainNodes[idx]);
                    // },
                    // ),
                    // _SectionHeader(
                    // title: 'Test Net',
                    // ),
                    // ListView.builder(
                    // shrinkWrap: true,
                    // padding: EdgeInsets.all(0),
                    // itemExtent: 50,
                    // itemCount: _testNodes.length,
                    // itemBuilder: (ctx, idx) {
                    // return _ListItemNode(_testNodes[idx]);
                    // },
                    // )
                    // ],
                    ),
              ),
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
