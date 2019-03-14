import 'package:flutter/material.dart';
import 'password.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'package:cyano_dart/widget/toast.dart';

class ImportPrivateKeyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImportPrivateKetState();
  }
}

class _ImportPrivateKetState extends State<ImportPrivateKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wifCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  Future<void> _import() async {
    try {
      var wm = await WalletManager.sington();
      await wm.import(_wifCtrl.text, _pwdCtrl.text);
      toastSuccess('Importation succeeds');
      Navigator.pop(context);
    } catch (e) {
      toastError('Unable to import: ' + e.toString());
    }
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
                'Import private key',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Positioned(
              top: 115,
              left: 20,
              child: Text(
                'Enter your passphrase for account encryption.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Positioned(
              top: 180,
              left: 20,
              width: MediaQuery.of(context).size.width - 40,
              height: 500,
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('Private key (WIF format):'),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _wifCtrl,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter private key';
                          }
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('Password:'),
                        ),
                      ),
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          return validatePassword(value);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('Confirm password:'),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) return 'Please confirm password';
                          var err = validatePassword(value);
                          if (err != null) return err;
                          if (value != _pwdCtrl.text) {
                            return 'Two passwords you entered do not match';
                          }
                        },
                      ),
                    ],
                  ),
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
                        if (_formKey.currentState.validate()) {
                          _import();
                        }
                      },
                      child: new Text(
                        "IMPORT",
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
