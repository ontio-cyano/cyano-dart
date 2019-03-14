import 'package:flutter/material.dart';
import 'package:ontology_dart_sdk/wallet.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'new_wallet.dart';
import 'import_prikey.dart';
import 'package:cyano_dart/widget/toast.dart';
import 'password.dart';

class WalletsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletsState();
  }
}

class _WalletsState extends State<WalletsScreen> with WalletManagerObserver {
  var _defualtAddr = '';
  var _wallets = <Wallet>[];

  @override
  void initState() {
    super.initState();
    _loadWallets();
    WalletManager.subscribe(this);
  }

  @override
  void dispose() {
    WalletManager.unsubscribe(this);
    super.dispose();
  }

  @override
  onWalletCreated(w) {
    _loadWallets();
  }

  @override
  onDefaultWalletChanged(Wallet w) {
    setState(() {
      _defualtAddr = w.accounts[0].address;
    });
  }

  @override
  onWalletDeleted(Wallet w) {
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    var wm = await WalletManager.sington();
    setState(() {
      _wallets = wm.wallets;
      _defualtAddr = wm.defaultAddress;
    });
  }

  Future<void> _changeDefault(String addr) async {
    var wm = await WalletManager.sington();
    wm.setDefaultByAddress(addr);
  }

  Future<void> _deleteWallet(Wallet w) async {
    var wm = await WalletManager.sington();
    await wm.deleteWallet(w.accounts[0].address);
    toastSuccess('Deletion succeeds');
    Navigator.pop(context);
  }

  Widget _buildBottomSheetBtn(
      BuildContext context, String title, VoidCallback action) {
    return Container(
      width: 200,
      child: RaisedButton(
        padding: const EdgeInsets.all(8.0),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(3.0)),
        textColor: Colors.white,
        color: Colors.cyan,
        onPressed: action,
        child: new Text(
          title,
          style: TextStyle(fontSize: 13),
        ),
        highlightElevation: 1.2,
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, Wallet w) {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildBottomSheetBtn(context, 'SET AS DEFAULT', () {
            _changeDefault(w.accounts[0].address);
            toastSuccess('Operation succeeds');
            Navigator.pop(context);
          }),
          Container(
            height: 10,
          ),
          _buildBottomSheetBtn(context, 'EXPORT WALLET', () {}),
          Container(
            height: 10,
          ),
          _buildBottomSheetBtn(context, 'DELETE WALLET', () {
            Navigator.pop(context);
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return InputPasswordBottomSheet(w.accounts[0].address, (pwd) {
                    _deleteWallet(w);
                  });
                });
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.cyan,
          leading: BackButton(color: Colors.white),
          title: Text(
            'Wallets',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              itemCount: _wallets.length,
              itemBuilder: (ctx, idx) {
                var w = _wallets[idx];
                return _ListItem(w, w.accounts[0].address == _defualtAddr, (w) {
                  // _changeDefault(w.accounts[0].address);
                  showModalBottomSheet(
                      context: ctx,
                      builder: (context) {
                        return _buildBottomSheet(context, w);
                      });
                });
              },
            ),
            Positioned(
              bottom: 0,
              left: 20,
              width: MediaQuery.of(context).size.width - 40,
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(8.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(3.0)),
                      textColor: Colors.white,
                      color: Colors.cyan,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewWalletScreen(),
                              fullscreenDialog: true),
                        );
                      },
                      child: new Text(
                        "CREATE WALLET",
                        style: TextStyle(fontSize: 13),
                      ),
                      highlightElevation: 1.2,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  Expanded(
                    flex: 3,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(8.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(3.0)),
                      textColor: Colors.white,
                      color: Colors.cyan,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImportPrivateKeyScreen(),
                              fullscreenDialog: true),
                        );
                      },
                      child: new Text(
                        "IMPORT WALLET",
                        style: TextStyle(fontSize: 13),
                      ),
                      highlightElevation: 1.2,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}

typedef _ListItemCallback = void Function(Wallet url);

class _ListItem extends StatelessWidget {
  final Wallet w;
  final bool active;
  final _ListItemCallback cb;

  _ListItem(this.w, this.active, this.cb);

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    var children = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 5),
          child: Text(
            w.accounts[0].address,
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
        cb(w);
      },
    );
  }
}
