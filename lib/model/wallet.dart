import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:event_bus/event_bus.dart';
import 'package:ontology_dart_sdk/wallet.dart';
import 'package:ontology_dart_sdk/crypto.dart';
import 'dart:convert';

final storage = new FlutterSecureStorage();

class WalletCreatedEvent {
  Wallet wallet;
  WalletCreatedEvent(this.wallet);
}

class WalletsResetEvent {}

class WalletManager {
  static var eventBus = new EventBus();

  static final storeKey = 'wallet-manager';
  static WalletManager _inst;

  var cur = '';
  var wallets = <Wallet>[];

  WalletManager._internal();

  WalletManager.fromJson(Map<String, dynamic> json) {
    cur = json['cur'];

    List<dynamic> wallets = json['wallets'] ?? [];
    wallets.forEach((w) => this.wallets.add(Wallet.fromJson(w)));
  }

  Map<String, dynamic> toJson() => {
        'cur': cur,
        'wallets': wallets,
      };

  bool get isEmpty {
    return wallets.length == 0;
  }

  static Future<WalletManager> sington() async {
    if (_inst != null) return _inst;

    var raw = await storage.read(key: storeKey);
    if (raw == null) {
      _inst = WalletManager._internal();
      await _inst.save();
    } else {
      _inst = WalletManager.fromJson(jsonDecode(raw));
    }
    return _inst;
  }

  Future<void> save() async {
    await storage.write(key: storeKey, value: jsonEncode(this));
  }

  Future<void> create(String pwd, {String name}) async {
    var w = Wallet(name);
    var prikey = await PrivateKey.random();
    var acc = await Account.create(pwd, prikey: prikey);
    w.addAccount(acc);
    if (w.name == null) w.name = acc.label;
    wallets.add(w);
    if (cur == '') cur = w.name;
    await save();
    eventBus.fire(WalletCreatedEvent(w));
  }

  Future<void> import(String wif, String pwd) async {
    var acc = await Account.fromWif(wif, pwd);
    var w = Wallet(acc.label);
    w.addAccount(acc);
    wallets.add(w);
    await save();
    eventBus.fire(WalletCreatedEvent(w));
  }

  Future<void> reset() async {
    var w = WalletManager._internal();
    await w.save();
    cur = '';
    wallets.clear();
    _inst = null;
    eventBus.fire(WalletsResetEvent());
  }
}
