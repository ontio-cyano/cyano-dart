import 'dart:async';
import 'package:flutter/material.dart';
import 'address.dart';
import 'package:cyano_dart/widget/wallet/wallets.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'package:ontology_dart_sdk/wallet.dart';
import 'package:cyano_dart/api.dart';
import 'package:cyano_dart/model/network.dart';
import 'package:cyano_dart/widget/wallet/password.dart';
import 'package:cyano_dart/widget/toast.dart';
import 'webview.dart';
import 'package:cyano_dart/model/oep4token.dart';
import 'asset_transfer.dart';

class AssetWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AssetState();
  }
}

class _AssetState extends State<AssetWidget>
    with WalletManagerObserver, NetworkManagerObserver {
  var _oep4Tokens = <Oep4Token>[];

  var _addr = '';
  var _ont = 0;
  double _ong = 0;
  double _unClaimedOng = 0;

  Timer _updateBalanceTimer;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddr();
    _loadOep4Tokens();
    WalletManager.subscribe(this);
  }

  @override
  dispose() {
    WalletManager.unsubscribe(this);
    if (_updateBalanceTimer != null) _updateBalanceTimer.cancel();
    super.dispose();
  }

  @override
  onDefaultWalletChanged(Wallet w) {
    var addr = w.accounts[0].address;
    _safeSetState(() {
      _addr = addr;
    });
    _updateBalanceAndSetTimer(addr);
  }

  @override
  onWalletDeleted(Wallet w) {
    _loadDefaultAddr();
  }

  @override
  onNodeChanged(String node) {
    _updateBalanceAndSetTimer(_addr);
  }

  _safeSetState(VoidCallback cb) {
    if (!mounted) return;
    setState(cb);
  }

  Future<void> _loadDefaultAddr() async {
    var wm = await WalletManager.sington();
    _safeSetState(() {
      _addr = wm.defaultAddress;
    });
    _updateBalanceAndSetTimer(wm.defaultAddress);
  }

  Future<void> _updateBalance(String addr) async {
    var b = await queryBalance(_addr);
    _safeSetState(() {
      _ont = b.ont;
      _ong = b.ong;
      _unClaimedOng = b.unClaimedOng;
    });
  }

  void _setupUpdateBalanceTimer(String addr) {
    if (_updateBalanceTimer != null) {
      _updateBalanceTimer.cancel();
    }
    _updateBalanceTimer = Timer.periodic(new Duration(seconds: 10), (timer) {
      _updateBalance(addr);
    });
  }

  Future<void> _updateBalanceAndSetTimer(String addr) async {
    _updateBalance(addr);
    _setupUpdateBalanceTimer(addr);
  }

  Future<void> _claimOng(String addr, String pwd) async {
    try {
      Navigator.pop(context);
      await claimOng(addr, pwd);
      toastSuccess('Claiming succeeds');
      _updateBalance(addr);
    } catch (e) {
      toastError('Unable to claim, please try it again later');
    }
  }

  Future<void> _navToExplor() async {
    var nm = await NetworkManager.sington();
    var url = '';
    if (nm.isMain) {
      url = "https://explorer.ont.io/address/$_addr/20/1/";
    } else if (nm.isTest) {
      url = "https://explorer.ont.io/address/$_addr/20/1/testnet";
    }
    if (url == '') {
      toastInfo('No transactions view for private network');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url)),
    );
  }

  Future<void> _loadOep4Tokens() async {
    var list = await Oep4Token.fetchList();
    _safeSetState(() {
      _oep4Tokens = list;
    });
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
                      _addr,
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
                          builder: (context) => AddressScreen(_addr)),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletsScreen()),
                      );
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
                      _navToExplor();
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
                onPressed: () {
                  if (_unClaimedOng == 0) return;
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return InputPasswordBottomSheet(_addr, (pwd) {
                          _claimOng(_addr, pwd);
                        });
                      });
                },
                child: new Text(
                  "CLAIM ONG: $_unClaimedOng",
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
              amount: _ont,
              cb: (name) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AssetTranserScreen(_addr, name, null, () {
                            _updateBalance(_addr);
                          })),
                );
              },
            ),
            _ListItemToken(
              name: 'ONG',
              icon: 'graphics/ong.png',
              amount: _ong,
              cb: (name) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AssetTranserScreen(_addr, name, null, () {
                            _updateBalance(_addr);
                          })),
                );
              },
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
          itemCount: _oep4Tokens.length,
          // shrinkWrap:true,
          itemExtent: 50,
          itemBuilder: (ctx, idx) {
            var tok = _oep4Tokens[idx];
            return _ListItemOep4Token(
              _addr,
              tok,
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

class _ListItemOep4Token extends StatelessWidget {
  final String from;
  final Oep4Token token;

  _ListItemOep4Token(this.from, this.token);

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    var children = <Widget>[
      Container(
        width: 20,
        margin: EdgeInsets.only(left: 5),
        child: token.logo.isEmpty
            ? Image.asset(
                'graphics/oep4_token.png',
                width: 25,
              )
            : FadeInImage.assetNetwork(
                placeholder: 'graphics/oep4_token.png',
                image: token.logo,
                width: 20,
              ),
      ),
      Container(
        margin: EdgeInsets.only(left: 10),
        child: Text(
          token.symbol,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ];

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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AssetTranserScreen(from, null, token, () {})),
        );
      },
    );
  }
}

typedef NativeAssetClickCallback = Function(String name);

class _ListItemToken extends StatelessWidget {
  final String icon;
  final String name;
  final dynamic amount;
  final NativeAssetClickCallback cb;

  _ListItemToken(
      {this.name,
      this.icon = 'graphics/oep4_token.png',
      this.amount = 0,
      this.cb});

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    var children = <Widget>[
      Image.asset(
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
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(amount is double
                ? amount.toStringAsFixed(9)
                : amount.toString()),
          ),
        ),
      )
    ];

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
      onTap: () {
        cb(name);
      },
    );
  }
}
