import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = new FlutterSecureStorage();

mixin DebugHistoryObserver {
  onRecordsUpdated();
}

class DebugHistory {
  static final observers = Set<DebugHistoryObserver>();

  static subscribe(DebugHistoryObserver obsr) {
    if (observers.contains(obsr)) return;
    observers.add(obsr);
  }

  static unsubscribe(DebugHistoryObserver obsr) {
    observers.remove(obsr);
  }

  static final storeKey = 'debug.history';
  static DebugHistory _inst;

  var _records = <String>[];

  List<String> get records {
    return _records.sublist(0);
  }

  DebugHistory._internal();

  DebugHistory.fromJson(Map<String, dynamic> json) {
    var records = json['records'] as List<dynamic>;
    _records = records.map((r) => r as String).toList();
  }

  Map<String, dynamic> toJson() => {
        'records': _records,
      };

  static Future<DebugHistory> sington() async {
    if (_inst != null) return _inst;

    var raw = await _storage.read(key: storeKey);
    if (raw == null) {
      _inst = DebugHistory._internal();
      await _inst.save();
    } else {
      _inst = DebugHistory.fromJson(jsonDecode(raw));
    }
    return _inst;
  }

  Future<void> save() async {
    await _storage.write(key: storeKey, value: jsonEncode(this));
  }

  bool get isEmpty {
    return _records.length == 0;
  }

  Future<void> addRecord(String url) async {
    if (_records.contains(url)) return;
    _records.add(url);
    await save();
    observers.forEach((obsr) => obsr.onRecordsUpdated());
  }

  Future<void> removeRecord(String url) async {
    if (!_records.contains(url)) return;
    _records.remove(url);
    await save();
    observers.forEach((obsr) => obsr.onRecordsUpdated());
  }
}
