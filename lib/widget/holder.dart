import 'package:flutter/material.dart';

class HolderWidget extends StatelessWidget {
  final Color color;

  HolderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
