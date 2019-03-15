import 'package:flutter/material.dart';
import 'password.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'package:cyano_dart/widget/toast.dart';

class NewOntIdScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewOntIdState();
  }
}

class _NewOntIdState extends State<NewOntIdScreen> {
  Future<void> _doCreate(String pwd) async {
    try {
      var wm = await WalletManager.sington();
      await wm.createIdentity(pwd);
      toastSuccess('Creation succeeds');
    } catch (e) {
      toastSuccess('Failed to create identity: ' + e.toString());
    }
  }

  Future<void> _create() async {
    var wm = await WalletManager.sington();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return InputPasswordBottomSheet(wm.defaultAddress, (pwd) {
            Navigator.pop(context);
            _doCreate(pwd);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Container(
                color: Colors.cyan,
              ),
            ),
            Positioned(
              top: 30,
              left: 20,
              width: 50,
              height: 100,
              child: Image.asset(
                'graphics/logo_white.png',
              ),
            ),
            Positioned(
              top: 65,
              left: 90,
              child: Text(
                'New Identity',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Positioned(
              top: 115,
              left: 20,
              child: Text(
                'Enter your passphrase for identity creation.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Positioned(
              top: 200,
              left: 20,
              width: MediaQuery.of(context).size.width - 40,
              height: 600,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'graphics/cynao_logo.png',
                        width: 90,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text('What is an ONT ID?'),
                    ),
                    Container(
                      // color: Colors.blue,
                      width: MediaQuery.of(context).size.width - 70,
                      margin: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'ONT ID is a passport to the blockchain world. It is a distributed identity framework supporting identity verification and authentication for people, assets, objects, and affairs.',
                          textAlign: TextAlign.start,
                          style: TextStyle(height: 1.3),
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
                        Navigator.pop(context);
                      },
                      child: new Text(
                        "CANCEL",
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
                        _create();
                      },
                      child: new Text(
                        "CREATE",
                        style: TextStyle(fontSize: 13),
                      ),
                      highlightElevation: 1.2,
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
