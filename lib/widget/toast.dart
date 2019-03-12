import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toastSuccess(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0);
}

void toastError(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0);
}

void toastInfo(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 2,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 14.0);
}
