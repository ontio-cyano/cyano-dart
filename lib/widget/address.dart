import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'toast.dart';

class AddressScreen extends StatelessWidget {
  final String address;

  AddressScreen(this.address);

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: address));
      toastSuccess('Address copy succeeds');
    } catch (e) {
      toastError('Unable to copy address' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Text('Address:'),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          address,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: RaisedButton(
                          padding: const EdgeInsets.all(8.0),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(3.0)),
                          textColor: Colors.white,
                          color: Colors.cyan,
                          onPressed: () {
                            _copy();
                          },
                          child: new Text(
                            "Copy",
                            style: TextStyle(fontSize: 13),
                          ),
                          highlightElevation: 1.2,
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: RepaintBoundary(
                    child: QrImage(
                      data: address,
                      size: 0.5 * MediaQuery.of(context).size.width,
                      onError: (ex) {
                        print("[QR] ERROR - $ex");
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
