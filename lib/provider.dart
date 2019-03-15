import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:cyano_dart/model/wallet.dart';
import 'package:cyano_dart/widget/wallet/password.dart';
import 'package:ontology_dart_sdk/crypto.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ontology_dart_sdk/common.dart';
import 'package:ontology_dart_sdk/neocore.dart';
import 'package:ontology_dart_sdk/network.dart';
import 'package:cyano_dart/api.dart';

class Providor {
  final BuildContext _context;

  Providor(this._context);

  var _senders = Set<ResponseSender>();

  void addSender(ResponseSender sender) {
    if (_senders.contains(sender)) return;
    _senders.add(sender);
  }

  Future<void> _send(Response resp) async {
    for (var sender in _senders) {
      await sender.send(resp);
    }
  }

  bool isRequest(String uri) {
    try {
      var u = Uri.parse(uri);
      return u.scheme == 'ontprovider';
    } catch (e) {
      return false;
    }
  }

  Future<Response> _getAccount(Request req) async {
    var wm = await WalletManager.sington();
    var resp = Response.fromReq(req);
    resp.result = wm.defaultAddress;
    return resp;
  }

  Future<Response> _getIdentity(Request req) async {
    var wm = await WalletManager.sington();
    var resp = Response.fromReq(req);
    resp.result = wm.hasOntId ? wm.ontid : '';
    return resp;
  }

  Future<Response> _login(Request req) async {
    var resp = Response.fromReq(req);
    var expire = req.params['expire'];
    if (expire != null && expire < new DateTime.now().millisecondsSinceEpoch) {
      resp.error = 1;
      resp.desc = 'expired';
      return resp;
    }
    var wm = await WalletManager.sington();
    var pwd = await askUserPassword(_context);
    var acc = wm.findAccountByAddr(wm.defaultAddress);
    var prikey = await acc.decrypt(pwd);
    var user = '';
    var publickey = acc.publicKey;
    if (req.params['type'] == 'account') {
      user = acc.address;
    } else {
      var pubkey = PublicKey.fromHex(publickey);
      user = await Address.generateOntId(pubkey);
    }
    var msg = Convert.strToBytes(req.params['message']);
    var sig = await prikey.sign(msg);
    resp.result = {
      'type': req.params['type'],
      'user': user,
      'message': Convert.bytesToHexStr(msg),
      'publickey': publickey,
      'signature': sig.hexEncoded
    };
    return resp;
  }

  Future<Response> _invoke(Request req) async {
    var resp = Response.fromReq(req);
    var wm = await WalletManager.sington();

    var b = TxBuilder();
    var cfg = req.params['invokeConfig'];
    var contractHash = cfg['contractHash'];
    var contract =
        Address(Uint8List.fromList(Convert.hexStrToBytes(contractHash)));

    // only one call per invoking now
    var fn = cfg['functions'][0];
    var args = <dynamic>[];
    for (var arg in fn['args']) {
      args.add(await parseParam(arg['value']));
    }
    var payer;
    if (cfg['payer'] != null && !cfg['payer'].isEmpty) {
      payer = cfg['payer'];
    } else {
      payer = wm.defaultAddress;
    }
    var payerAcc = wm.findAccountByAddr(payer);
    var payerAddr = await Address.fromBase58(payer);
    var pwd = await askUserPassword(_context);
    var prikey = await payerAcc.decrypt(pwd);

    var tx;
    if (contractHash == '0100000000000000000000000000000000000000' ||
        contractHash == '0200000000000000000000000000000000000000') {
      var struct = Struct();
      struct.list.addAll(args);

      var pb = VmParamsBuilder();
      if (fn['operation'] == 'transfer') {
        pb.pushNativeCodeScript([
          [struct]
        ]);
      } else {
        pb.pushNativeCodeScript([struct]);
      }
      tx = await b.makeNativeContractTx(fn['operation'], pb.buf.bytes, contract,
          gasPrice: cfg['gasPrice'],
          gasLimit: cfg['gasLimit'],
          payer: payerAddr);
    } else {
      tx = await b.makeInvokeTx(fn['operation'], args, contract,
          gasPrice: cfg['gasPrice'],
          gasLimit: cfg['gasLimit'],
          payer: payerAddr);
    }

    await b.sign(tx, prikey);

    var rpc = WebsocketRpc(await rpcAddress());
    rpc.connect();
    var result = await rpc.sendRawTx(await tx.serialize(), preExec: false);
    resp.result = result['Result'];
    rpc.close();
    return resp;
  }

  Future<Response> _invokeRead(Request req) async {
    var resp = Response.fromReq(req);

    var b = TxBuilder();
    var cfg = req.params['invokeConfig'];
    var contractHash = cfg['contractHash'];
    var contract = Address(Convert.hexStrToBytes(contractHash));

    // only one call per invoking now
    var fn = cfg['functions'][0];
    var args = <dynamic>[];
    for (var arg in fn['args']) {
      args.add(await parseParam(arg['value']));
    }
    var tx;
    if (contractHash == '0100000000000000000000000000000000000000' ||
        contractHash == '0200000000000000000000000000000000000000') {
      var struct = Struct();
      struct.list.addAll(args);

      var pb = VmParamsBuilder();
      if (fn['operation'] == 'transfer') {
        pb.pushNativeCodeScript([
          [struct]
        ]);
      } else {
        pb.pushNativeCodeScript([struct]);
      }
      tx =
          await b.makeNativeContractTx(fn['operation'], pb.buf.bytes, contract);
    } else {
      tx = await b.makeInvokeTx(fn['operation'], args, contract);
    }

    var rpc = WebsocketRpc(await rpcAddress());
    rpc.connect();
    var result = await rpc.sendRawTx(await tx.serialize());
    resp.result = result['Result'];
    rpc.close();
    return resp;
  }

  Future<Response> _process(Request req) async {
    var resp = Response.fromReq(req);
    var wm = await WalletManager.sington();
    if (wm.isEmpty) return null;

    print(req.action);
    switch (req.action) {
      case 'getAccount':
        return _getAccount(req);
      case 'getIdentity':
        return _getIdentity(req);
      case 'login':
        return _login(req);
      case 'invoke':
        return _invoke(req);
      case 'invokeRead':
        return _invokeRead(req);
      default:
        break;
    }
    return resp;
  }

  Future<void> process(String uri) async {
    if (!isRequest(uri)) return;

    var req = Request.fromUri(uri);
    Response resp;
    try {
      resp = await _process(req);
    } catch (e) {
      resp = Response.fromReq(req);
      resp.error = 1;
      resp.desc = e.toString();
    }
    if (resp != null) await _send(resp);
  }
}

class Request {
  String id;
  String action;
  String version;
  bool needTimeout;
  Map<String, dynamic> params;

  Request({this.id, this.action, this.version, this.needTimeout, this.params});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
        id: json['id'],
        action: json['action'],
        version: json['version'],
        needTimeout: json['needTimeout'],
        params: json['params']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'version': version,
        'needTimeout': needTimeout,
        'params': params
      };

  factory Request.fromUri(String uri) {
    var u = Uri.parse(uri);
    var params = u.queryParameters['params'];
    var sig64 = base64Decode(params);
    var json =
        jsonDecode(Uri.decodeQueryComponent(Utf8Decoder().convert(sig64)));
    return Request.fromJson(json);
  }
}

abstract class ResponseSender {
  Future<dynamic> send(Response resp);
}

class JsResponseSender extends ResponseSender {
  final FlutterWebviewPlugin wv;

  JsResponseSender(this.wv);

  Future<void> send(Response resp) async {
    var data = base64Encode(
        Utf8Codec().encode(Uri.encodeQueryComponent(jsonEncode(resp))));

    var js = """
    (function () {
      var evt = new MessageEvent('message', {
        data : '$data'
      });
      document.dispatchEvent(evt);
    })();
    """;

    await wv.evalJavascript(js);
  }
}

class JsResponseSender1 extends ResponseSender {
  final WebViewController wv;

  JsResponseSender1(this.wv);

  Future<void> send(Response resp) async {
    var data = base64Encode(
        Utf8Codec().encode(Uri.encodeQueryComponent(jsonEncode(resp))));

    var js = """
    (function () {
      var evt = new MessageEvent('message', {
        data : '$data'
      });
      document.dispatchEvent(evt);
    })();
    """;

    await wv.evaluateJavascript(js);
  }
}

class HttpResponseSender extends ResponseSender {
  @override
  Future<http.Response> send(Response resp) async {
    if (resp.rep.params == null) return null;
    var cb = resp.rep.params['callback'];
    if (cb == null || cb.isEmpty) return null;
    var params = {
      'action': resp.action,
      'version': resp.version,
      'id': resp.id,
      'params': resp.result
    };
    return http.post(cb, body: params);
  }
}

class Response {
  String id;
  String action;
  String version;
  String desc;
  int error;
  dynamic result;

  Request rep;

  Response(
      {this.id,
      this.action,
      this.version,
      this.desc = 'SUCCESS',
      this.error = 0,
      this.result,
      this.rep});

  factory Response.fromReq(Request req) {
    return Response(
        id: req.id, action: req.action, version: req.version, rep: req);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'version': version,
        'desc': desc,
        'error': error,
        'result': result
      };
}

Future<dynamic> _parseStringParam(String param) async {
  var prefixes = [
    'String:',
    'ByteArray:',
    'Long:',
    'Address:',
  ];
  var prefix =
      prefixes.firstWhere((p) => param.startsWith(p), orElse: () => '');
  if (prefix.isEmpty) throw Exception('Unsupported type: ' + param);
  param = param.substring(prefix.length);
  switch (prefix) {
    case 'String:':
      return param;
    case 'ByteArray:':
      return Convert.hexStrToBytes(param);
    case 'Long:':
      return BigInt.parse(param);
    case 'Address:':
      return await Address.fromBase58(param);
    default:
      break;
  }
}

Future<dynamic> parseParam(dynamic param) async {
  if (param is String) return _parseStringParam(param);
  if (param is List<dynamic>) {
    var ret = <dynamic>[];
    for (var item in param) {
      ret.add(await parseParam(item));
    }
    return ret;
  }
  if (param is Map<String, dynamic>) {
    var ret = Map<String, dynamic>();
    for (var kv in param.entries) {
      ret[kv.key] = await parseParam(kv.value);
    }
    return ret;
  }
  if (param is int) {
    return param;
  }
  throw Exception('Unsupported type: ' + param.runtimeType.toString());
}
