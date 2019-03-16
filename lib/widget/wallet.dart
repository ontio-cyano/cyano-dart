import 'package:flutter/material.dart';
import 'wallet/new_wallet.dart';
import 'wallet/import_prikey.dart';

class CreateWalletWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Image.asset(
              'graphics/logo.png',
              width: 90,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                'Cyano Wallet',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 15),
                width: 350,
                child: Text(
                  'An Ontology wallet. For using Ontology, you would create a new account or import an existing one.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              width: MediaQuery.of(context).size.width * 0.6 + 2,
              height: 50,
              child: RaisedButton(
                padding: const EdgeInsets.all(8.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(0)),
                textColor: Colors.white,
                color: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewWalletScreen(),
                        fullscreenDialog: true),
                  );
                },
                child: new Text(
                  "NEW ACCOUNT",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                highlightElevation: 1.2,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width * 0.6,
              height: 52,
              child: OutlineButton(
                highlightedBorderColor: Colors.black,
                borderSide: BorderSide(color: Colors.black),
                padding: const EdgeInsets.all(8.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(0)),
                textColor: Colors.black,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImportPrivateKeyScreen(),
                        fullscreenDialog: true),
                  );
                },
                child: new Text(
                  "IMPORT PRIVATE KEY",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                highlightElevation: 1.2,
              ),
            )
          ],
        )
      ],
    );
  }
}
