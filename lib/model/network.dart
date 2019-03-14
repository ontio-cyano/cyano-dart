import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

final _storage = new FlutterSecureStorage();

mixin NetworkManagerObserver {
  onNodeChanged(String node) {}
  onPrivateNodeChanged(String node) {}
}

class NetworkManager {
  static final observers = Set<NetworkManagerObserver>();

  static final mainNodes = [
    'dappnode1.ont.io',
    'dappnode2.ont.io',
    'dappnode3.ont.io',
    'dappnode4.ont.io'
  ];

  static final testNodes = [
    'polaris1.ont.io',
    'polaris2.ont.io',
    'polaris3.ont.io',
    'polaris4.ont.io',
    'polaris5.ont.io',
  ];

  static subscribe(NetworkManagerObserver obsr) {
    if (observers.contains(obsr)) return;
    observers.add(obsr);
  }

  static unsubscribe(NetworkManagerObserver obsr) {
    observers.remove(obsr);
  }

  static final storeKey = 'network-manager';
  static NetworkManager _inst;

  var _cur = 'dappnode3.ont.io';
  var _privateNode = '127.0.0.1';

  String get defaultNode {
    return _cur;
  }

  String get privateNode {
    return _privateNode;
  }

  bool get isMain {
    return mainNodes.contains(_cur);
  }

  bool get isTest {
    return testNodes.contains(_cur);
  }

  NetworkManager._internal();

  NetworkManager.fromJson(Map<String, dynamic> json) {
    _cur = json['cur'];
    _privateNode = json['privateNode'];
  }

  Map<String, dynamic> toJson() => {
        'cur': _cur,
        'privateNode': _privateNode,
      };

  static Future<NetworkManager> sington() async {
    if (_inst != null) return _inst;

    var raw = await _storage.read(key: storeKey);
    if (raw == null) {
      _inst = NetworkManager._internal();
      await _inst.save();
    } else {
      _inst = NetworkManager.fromJson(jsonDecode(raw));
    }
    return _inst;
  }

  Future<void> save() async {
    await _storage.write(key: storeKey, value: jsonEncode(this));
  }

  Future<void> setDefaultNode(String node) async {
    _cur = node;
    await save();
    observers.forEach((obsr) => obsr.onNodeChanged(node));
  }

  Future<void> setPrivateNode(String node) async {
    _privateNode = node;
    await save();
    observers.forEach((obsr) => obsr.onPrivateNodeChanged(node));
  }
}
