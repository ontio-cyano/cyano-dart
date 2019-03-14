import 'package:flutter/material.dart';
import 'package:cyano_dart/model/wallet.dart';

String validatePassword(String pwd) {
  if (pwd == null || pwd.isEmpty) return 'Please enter password';
  if (pwd.length < 6) return 'Password is too short, min length is 6';
  if (pwd.length > 20) return 'Password is too long, max length is 20';
  return null;
}

typedef PasswordOKCallback = Function(String pwd);

class InputPasswordBottomSheet extends StatefulWidget {
  final PasswordOKCallback cb;
  final String addr;

  InputPasswordBottomSheet(this.addr, this.cb);

  @override
  State<StatefulWidget> createState() {
    return _InputPasswordBottomSheetState();
  }
}

class _InputPasswordBottomSheetState extends State<InputPasswordBottomSheet> {
  final TextEditingController pwdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var _passwordOK = '';

  Future<void> _verifyPassword() async {
    var wm = await WalletManager.sington();
    var err = await wm.verifyAccountPwd(widget.addr, pwdCtrl.text);
    setState(() {
      _passwordOK = err;
      _formKey.currentState.validate();
    });
    if (err.isEmpty) {
      widget.cb(pwdCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Please enter the password of your wallet',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              height: 20,
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: pwdCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          obscureText: true,
                          autofocus: true,
                          onFieldSubmitted: (val) {
                            _verifyPassword();
                          },
                          validator: (val) {
                            return _passwordOK.isEmpty ? null : _passwordOK;
                          },
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
