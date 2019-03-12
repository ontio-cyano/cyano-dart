import 'package:flutter/material.dart';
import 'address.dart';
import 'package:ontology_dart_sdk/network.dart';
import 'package:ontology_dart_sdk/crypto.dart';

class AssetWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AssetState();
  }
}

class _AssetState extends State<AssetWidget> {
  final oep4Tokens = [
    'TNT',
    'OEP',
    'HP',
    'MYT',
    'LCY',
  ];

  @override
  void initState() {
    super.initState();
    _queryBalance();
  }

  Future<void> _queryBalance() async {
    print('querying balance...');
    var rpc = WebsocketRpc('ws://polaris1.ont.io:20335');
    rpc.connect();
    var res = await rpc.getNodeCount();
    print(res);
    var prikey = PrivateKey.fromHex(
        'e467a2a9c9f56b012c71cf2270df42843a9d7ff181934068b4a62bcdd570e8be');
    print(await prikey.getWif());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          color: Colors.cyan,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 20,
                child: Container(
                  color: Colors.cyan,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ANt6oJMEZBwCLbg5Dd6Pg3pxAs7FbJHSRY',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 12,
                child: InkWell(
                  child: Container(
                      color: Colors.cyan,
                      height: 40,
                      width: 40,
                      // padding: EdgeInsets.only(right: 8),
                      child: Center(
                        child: InkWell(
                          child: Image.asset(
                            'graphics/qrcode.png',
                            width: 20,
                          ),
                        ),
                      )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddressScreen(
                              'ANt6oJMEZBwCLbg5Dd6Pg3pxAs7FbJHSRY')),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: InkWell(
                    child: Container(
                      color: Colors.cyan,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'graphics/menu.png',
                            width: 20,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              'Manage',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('manage');
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: InkWell(
                    child: Container(
                      color: Colors.cyan,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'graphics/transaction.png',
                            width: 20,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text('Transaction',
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('transaction');
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              left: (MediaQuery.of(context).size.width - 0.5) / 2,
              child: Container(
                color: Colors.white,
                height: 40,
                width: 0.6,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 35,
              margin: EdgeInsets.only(top: 18),
              width: MediaQuery.of(context).size.width - 40,
              color: Colors.transparent,
              child: RaisedButton(
                padding: const EdgeInsets.all(8.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(3.0)),
                textColor: Colors.white,
                color: Colors.cyan,
                onPressed: () {},
                child: new Text(
                  "CLAIM ONG: 0",
                  style: TextStyle(fontSize: 12),
                ),
                highlightElevation: 1.2,
              ),
            ),
          ],
        ),
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemExtent: 50,
          children: <Widget>[
            _SectionHeader(title: 'Tokens'),
            _ListItemToken(
              name: 'ONT',
              icon: 'graphics/ont.png',
              amount: 0,
            ),
            _ListItemToken(
              name: 'ONG',
              icon: 'graphics/ong.png',
              amount: 0,
            )
          ],
        ),
        Container(
          height: 50,
          child: _SectionHeader(
            title: 'OEP-4 tokens',
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: oep4Tokens.length,
          // shrinkWrap:true,
          itemExtent: 50,
          itemBuilder: (ctx, idx) {
            var tok = oep4Tokens[idx];
            return _ListItemToken(
              name: tok,
            );
          },
        ))
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  _SectionHeader({this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            bottom: 8,
            child: Text(
              title,
              style: TextStyle(color: Color(0xff6E6F70)),
            ),
          )
        ],
      ),
    );
  }
}

class _ListItemToken extends StatelessWidget {
  final String icon;
  final String name;
  final int amount;
  final String url;

  _ListItemToken(
      {this.name,
      this.icon = 'graphics/oep4_token.png',
      this.amount = -1,
      this.url});

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    var children = <Widget>[
      url != null
          ? Image.network(url, width: 30)
          : Image.asset(
              icon,
              width: 30,
            ),
      Container(
        margin: EdgeInsets.only(left: 5),
        child: Text(
          name,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ];

    if (amount >= 0) {
      children.add(Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('0'),
          ),
        ),
      ));
    }

    return ListTile(
      title: Container(
        height: 50,
        decoration: new BoxDecoration(
          border: border,
        ),
        child: Row(
          children: children,
        ),
      ),
      subtitle: null,
    );
  }
}
