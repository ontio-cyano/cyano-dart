import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:ontology_dart_sdk/wallet.dart';
import 'asset.dart';
import 'holder.dart';
import 'setting.dart';
import 'toast.dart';
import 'wallet.dart';
import 'package:cyano_dart/model/wallet.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen>
    with WidgetsBindingObserver, WalletManagerObserver {
  int _curIdx = 0;
  var _preCached = false;

  List<Widget> _children = [
    HolderWidget(Colors.white),
    HolderWidget(Colors.white),
    HolderWidget(Colors.white),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WalletManager.unsubscribe(this);
    super.dispose();
  }

  @override
  onWalletReset() {
    _initTabContents();
  }

  @override
  onDefaultWalletChanged(Wallet w) {
    _initTabContents();
  }

  @override
  onWalletDeleted(Wallet w) {
    _initTabContents();
  }

  @override
  onWalletCreated(Wallet w) {
    _initTabContents();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // do something when resumed
      _resetWallets();
    }
  }

  Future<void> _init() async {
    WalletManager.subscribe(this);
    await _initTabContents();
  }

  Future<void> _resetWallets() async {
    var wm = await WalletManager.sington();
    await wm.reset();
  }

  Future<void> _initTabContents() async {
    var children = [
      AssetWidget(),
      HolderWidget(Colors.deepOrange),
      SettingWidget()
    ];
    var wm = await WalletManager.sington();
    if (wm.isEmpty) {
      children[0] = CreateWalletWidget();
    }
    setState(() {
      _children = children;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_preCached) _preCacheImage();
  }

  void _preCacheImage() async {
    var urls = [
      'graphics/tab_asset_un_selected.png',
      'graphics/tab_game_select.png',
      'graphics/tab_me_un_selected.png'
    ];
    for (final url in urls) {
      await precacheImage(AssetImage(url), context);
    }
    _preCached = true;
  }

  Future<void> _scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
    } catch (e) {
      toastError('Unable to open camera');
    }
  }

  @override
  Widget build(BuildContext context) {
    var constraints = const BoxConstraints(minWidth: 48.0, minHeight: 48.0);
    var iconSize = 28.0;
    var padding = const EdgeInsets.only(right: 15.0);
    var radius = math.max(
      Material.defaultSplashRadius,
      (iconSize + math.min(padding.horizontal, padding.vertical)) * 0.7,
      // x 0.5 for diameter -> radius and + 40% overflow derived from other Material apps.
    );

    return Scaffold(
      appBar: new AppBar(
          elevation: 0.0,
          leading: Container(
            margin: EdgeInsets.only(left: 10),
            child: Center(
                child: Image.asset(
              'graphics/logo_white.png',
              width: 30,
            )),
          ),
          actions: <Widget>[
            InkResponse(
                onTap: () {
                  _scan();
                },
                child: ConstrainedBox(
                  constraints: constraints,
                  child: Padding(
                    padding: padding,
                    child: SizedBox(
                      height: iconSize,
                      width: iconSize,
                      child: Align(
                          alignment: Alignment.center,
                          child: Ink.image(
                            padding: const EdgeInsets.all(8.0),
                            image: AssetImage('graphics/icon_scan_qr.png'),
                            fit: BoxFit.contain,
                            width: iconSize,
                            height: iconSize,
                          )),
                    ),
                  ),
                ),
                radius: radius),
          ],
          automaticallyImplyLeading: false),
      body: _children[_curIdx],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          setState(() {
            _curIdx = idx;
          });
        },
        currentIndex: _curIdx,
        items: [
          BottomNavigationBarItem(
            icon: _FixedSizeImg('graphics/tab_asset_un_selected.png', 25),
            activeIcon: _FixedSizeImg('graphics/tab_asset_selected.png', 25),
            title: Text(
              'Assets',
              style: TextStyle(color: const Color(0xFF06244e), fontSize: 13.0),
            ),
          ),
          BottomNavigationBarItem(
            icon: _FixedSizeImg('graphics/tab_game_unselect.png', 25),
            activeIcon: _FixedSizeImg('graphics/tab_game_select.png', 25),
            title: Text(
              'DApps',
              style: TextStyle(color: const Color(0xFF06244e), fontSize: 13.0),
            ),
          ),
          BottomNavigationBarItem(
              icon: _FixedSizeImg('graphics/tab_me_un_selected.png', 25),
              activeIcon: _FixedSizeImg('graphics/tab_me_selected.png', 25),
              title: Text(
                'Settings',
                style:
                    TextStyle(color: const Color(0xFF06244e), fontSize: 13.0),
              ))
        ],
        fixedColor: Color(0xff6E6F70),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _FixedSizeImg extends StatelessWidget {
  final String icon;
  final double width;

  _FixedSizeImg(this.icon, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      child: Image.asset(
        icon,
        width: width,
      ),
    );
  }
}
