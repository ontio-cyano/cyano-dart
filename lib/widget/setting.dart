import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'select_node.dart';
import 'webview.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'package:cyano_dart/widget/wallet/new_ontid.dart';

class SettingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingState();
  }
}

class _SettingState extends State<SettingWidget> {
  var _version = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "Version: ${packageInfo.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                itemExtent: 50,
                children: <Widget>[
                  _SettingItem(
                    name: 'ONT Identities',
                    icon: 'graphics/tab_id_un_selected.png',
                  ),
                  _SettingItem(
                    name: 'Network',
                    icon: 'graphics/system_setting.png',
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(_version),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String name;
  final String icon;

  _SettingItem({this.name, this.icon});

  Future<void> _nav2OntId(BuildContext context) async {
    var wm = await WalletManager.sington();
    if (!wm.hasOntId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewOntIdScreen(),
          ));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewScreen(
                "https://auth.ont.io/#/mgmtHome?ontid=${wm.ontid.ontid}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var border = Border(bottom: BorderSide(width: 0.5, color: Colors.grey));

    return ListTile(
      // title: null,
      title: Container(
        height: 50,
        decoration: new BoxDecoration(
          border: border,
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 8),
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
                  child: Image.asset(
                    'graphics/anchor.png',
                    width: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      subtitle: null,
      onTap: () {
        if (name == 'Network') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NodeSelectionScreen()),
          );
        } else if (name == 'ONT Identities') {
          _nav2OntId(context);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => WebViewScreen(
          //           'https://auth.ont.io/#/mgmtHome?ontid=did:ont:Aaqase8cE4DkatKkvpQcJYaGVKvYSCPoFD')),
          // );
        }
      },
    );
  }
}
