import 'package:flutter/material.dart';

class NodeSelectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeSelectionState();
  }
}

class _NodeSelectionState extends State<NodeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.cyan,
        ),
        body: Text('nodes'));
  }
}
