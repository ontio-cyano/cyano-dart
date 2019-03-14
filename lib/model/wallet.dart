import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ontology_dart_sdk/wallet.dart';
import 'package:ontology_dart_sdk/crypto.dart';

final _storage = new FlutterSecureStorage();

mixin WalletManagerObserver {
  onWalletCreated(Wallet w) {}
  onWalletReset() {}
  onDefaultWalletChanged(Wallet w) {}
  onWalletDeleted(Wallet w) {}
}

class WalletManager {
  static final observers = Set<WalletManagerObserver>();

  static subscribe(WalletManagerObserver obsr) {
    if (observers.contains(obsr)) return;
    observers.add(obsr);
  }

  static unsubscribe(WalletManagerObserver obsr) {
    observers.remove(obsr);
  }

  static final storeKey = 'wallet-manager';
  static WalletManager _inst;

  var _addr = '';
  var _wallets = <Wallet>[];

  List<Wallet> get wallets {
    return _wallets.sublist(0);
  }

  WalletManager._internal();

  WalletManager.fromJson(Map<String, dynamic> json) {
    _addr = json['addr'];

    List<dynamic> wallets = json['wallets'] ?? [];
    wallets.forEach((w) => this._wallets.add(Wallet.fromJson(w)));
  }

  Map<String, dynamic> toJson() => {
        'addr': _addr,
        'wallets': _wallets,
      };

  bool get isEmpty {
    return _wallets.length == 0;
  }

  // through this app we use a one-address-per-wallet strategy
  // so using the address of first account within the wallet to find a wallet
  Wallet findWalletByAddress(String address) {
    return _wallets.where((w) => w.accounts[0].address == address).first;
  }

  String get defaultAddress {
    return _addr;
  }

  static Future<WalletManager> sington() async {
    if (_inst != null) return _inst;

    var raw = await _storage.read(key: storeKey);
    if (raw == null) {
      _inst = WalletManager._internal();
      await _inst.save();
    } else {
      _inst = WalletManager.fromJson(jsonDecode(raw));
    }
    return _inst;
  }

  Future<void> save() async {
    await _storage.write(key: storeKey, value: jsonEncode(this));
  }

  Future<void> create(String pwd, {String name}) async {
    var w = Wallet(name);
    var prikey = await PrivateKey.random();
    var acc = await Account.create(pwd, prikey: prikey);
    w.addAccount(acc);
    w.name = acc.label;
    _wallets.add(w);
    if (_addr == '') _addr = acc.address;
    await save();
    observers.forEach((obsr) => obsr.onWalletCreated(w));
  }

  Future<void> import(String wif, String pwd) async {
    var acc = await Account.fromWif(wif, pwd);
    var w = Wallet(acc.label);
    w.addAccount(acc);
    _wallets.add(w);
    w.name = acc.label;
    if (_addr == '') _addr = acc.address;
    await save();
    observers.forEach((obsr) => obsr.onWalletCreated(w));
  }

  Future<void> reset() async {
    _addr = '';
    _wallets.clear();
    await save();
    _inst = null;
    observers.forEach((obsr) => obsr.onWalletReset());
  }

  Future<void> setDefaultByAddress(String addr) async {
    var w = findWalletByAddress(addr);
    if (w == null) return;
    _addr = addr;
    await save();
    observers.forEach((obsr) => obsr.onDefaultWalletChanged(w));
  }

  Account findAccountByAddr(String addr) {
    for (var w in _wallets) {
      if (w.accounts[0].address == addr) return w.accounts[0];
    }
    return null;
  }

  Future<String> verifyAccountPwd(String addr, String pwd) async {
    var acc = findAccountByAddr(addr);
    if (acc == null) return 'Cannot find account';
    try {
      await acc.decrypt(pwd);
      return '';
    } on PlatformException catch (_) {
      return 'Invalid password';
    }
  }

  Future<void> deleteWallet(String addr) async {
    var w = findWalletByAddress(addr);
    if (w == null) return;
    _wallets.remove(w);
    if (_addr == addr) {
      if (_wallets.length > 0) {
        _addr = _wallets[0].accounts[0].address;
      } else {
        _addr = '';
      }
    }
    await save();
    observers.forEach((obsr) => obsr.onWalletDeleted(w));
  }
}
