import 'package:flutter/material.dart';
import 'package:cyano_dart/model/wallet.dart';
import 'package:cyano_dart/widget/toast.dart';
import 'package:cyano_dart/widget/wallet/password.dart';
import 'package:cyano_dart/model/oep4token.dart';
import 'package:validators/validators.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:cyano_dart/api.dart';
import 'loading.dart';

class AssetTranserScreen extends StatefulWidget {
  final String from;
  final String nativeAsset;
  final Oep4Token oep4token;
  final VoidCallback onNativeAssetTrasferred;

  bool get isNativeAsset {
    return nativeAsset != null;
  }

  AssetTranserScreen(this.from, this.nativeAsset, this.oep4token,
      this.onNativeAssetTrasferred);

  @override
  State<StatefulWidget> createState() {
    return _AssetTransferState();
  }
}

class _AssetTransferState extends State<AssetTranserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recvCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  FocusNode _nodeText1 = FocusNode();

  var _rectAddrErr = '';
  dynamic _balance = 0;

  String get _assetName {
    if (widget.nativeAsset != null) return widget.nativeAsset;
    return widget.oep4token.symbol;
  }

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    if (widget.isNativeAsset) {
      var b = await queryBalance(widget.from);
      setState(() {
        _balance = widget.nativeAsset == 'ONT' ? b.ont : b.ong;
      });
    } else {
      try {
        await widget.oep4token.queryBalance(widget.from);
      } catch (e) {
        toastError('Failed to query balance');
      }
    }
  }

  Future<void> _validateRecvAddr() async {
    var err = await WalletManager.validateAddress(_recvCtrl.text);
    setState(() {
      _rectAddrErr = err;
    });
  }

  Future<void> _transfer(
      String from, String pwd, String to, String amount) async {
    showLoadingDialog(context);
    if (widget.isNativeAsset) {
      BigInt a;
      if (widget.nativeAsset == 'ONT') {
        a = BigInt.parse(amount);
      } else {
        var d = double.parse(amount) * 1e9;
        a = BigInt.from(d);
      }
      await transferNativeAsset(widget.nativeAsset, from, pwd, to, a);
      // dismiss loading modal
      Navigator.pop(context);
      toastSuccess('Transfer succeeds');
      // go back
      Navigator.pop(context);
      widget.onNativeAssetTrasferred();
    } else {
      try {
        await widget.oep4token.transfer(from, pwd, to, amount);
        // dismiss loading modal
        Navigator.pop(context);
        toastSuccess('Transfer succeeds');
         Navigator.pop(context);
      } catch (e) {
        // dismiss loading modal
        Navigator.pop(context);
        toastError('Failed to transfer, please try it again later');
      }
    }
  }

  void _validateForm() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    _rectAddrErr = '';
    if (!_formKey.currentState.validate()) return;
    await _validateRecvAddr();
    if (_formKey.currentState.validate()) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return InputPasswordBottomSheet(widget.from, (pwd) {
              Navigator.pop(context);
              _transfer(widget.from, pwd, _recvCtrl.text, _amountCtrl.text);
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FormKeyboardActions(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardAction(
          focusNode: _nodeText1,
        ),
      ],
      child: Stack(
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
              'Transfer ' + _assetName,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          Positioned(
            top: 115,
            left: 20,
            child: Text(
              'Please double check the recipient address.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Positioned(
            top: 180,
            left: 20,
            width: MediaQuery.of(context).size.width - 40,
            height: 300,
            child: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Recipient:'),
                    ),
                    TextFormField(
                      controller: _recvCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please input the recipient address';
                        }
                        return _rectAddrErr.isEmpty ? null : _rectAddrErr;
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text('Amount:'),
                      ),
                    ),
                    TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      focusNode: _nodeText1,
                      controller: _amountCtrl,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please input the amount to transfer';
                        }
                        if (!isFloat(value)) {
                          return 'Please input a valid decimal';
                        }
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Balance: ' +
                              (_balance is int
                                  ? _balance.toString()
                                  : _balance.toStringAsFixed(9))),
                          Text('Fee: 0.01 ONG')
                        ],
                      ),
                    )
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
                      _validateForm();
                    },
                    child: new Text(
                      "CONFIRM",
                      style: TextStyle(fontSize: 13),
                    ),
                    highlightElevation: 1.2,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
