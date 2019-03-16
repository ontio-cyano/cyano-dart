import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ontology_dart_sdk/neocore.dart';
import 'package:ontology_dart_sdk/crypto.dart';
import 'package:ontology_dart_sdk/network.dart';
import 'package:cyano_dart/api.dart';
import 'wallet.dart';

const oep4listUrl =
    'https://explorer.ont.io/api/v1/explorer/oepcontract/oep4/20/1/';

class Oep4Token {
  String description;
  String symbol;
  int createTime;
  String abi;
  String creator;
  int totalSupply;
  int decimals;
  String code;
  String contractHash;
  String name;
  String logo;
  String ongCount;
  int updateTime;
  int addressCount;
  String contactInfo;
  String ontCount;
  int txCount;

  Oep4Token(
      {this.description,
      this.symbol,
      this.createTime,
      this.abi,
      this.creator,
      this.totalSupply,
      this.decimals,
      this.code,
      this.contractHash,
      this.name,
      this.logo,
      this.ongCount,
      this.updateTime,
      this.addressCount,
      this.contactInfo,
      this.ontCount,
      this.txCount});

  factory Oep4Token.fromJson(Map<String, dynamic> json) {
    return Oep4Token(
        description: json['Description'],
        symbol: json['Symbol'],
        createTime: json['CreateTime'],
        abi: json['ABI'],
        creator: json['Creator'],
        totalSupply: json['TotalSupply'],
        decimals: json['Decimals'],
        code: json['Code'],
        contractHash: json['ContractHash'],
        name: json['Name'],
        logo: json['Logo'],
        ongCount: json['OngCount'],
        updateTime: json['UpdateTime'],
        addressCount: json['Addresscount'],
        contactInfo: json['ContactInfo'],
        ontCount: json['OntCount'],
        txCount: json['TxCount']);
  }

  static List<Oep4Token> _listCache = [];

  static Future<List<Oep4Token>> fetchList() async {
    if (_listCache.length > 0) return _listCache;

    final response = await http.get(oep4listUrl);
    if (response.statusCode != 200)
      throw Exception('Failed to laod oep4 tokens');

    var resp = json.decode(response.body);
    if (resp['Error'] != 0) throw Exception('Service error: ' + resp['Desc']);

    var list = resp['Result']['ContractList'] as List<dynamic>;
    _listCache = list.map((t) => Oep4Token.fromJson(t)).toList();
    return _listCache;
  }

  Future<BigInt> queryBalance(String addr) async {
    var b = Oep4TxBuilder(await Address.fromValue(contractHash));
    var tx = await b.makeQueryBalanceOfTx(await Address.fromBase58(addr));
    var rpc = WebsocketRpc(await rpcAddress());
    rpc.connect();
    var res = await rpc.sendRawTx(await tx.serialize());
    rpc.close();
    return res['Result'] == null || res['Result'] == ''
        ? BigInt.from(0)
        : BigInt.parse(res['Result']);
  }

  Future<void> transfer(
      String from, String pwd, String to, String amount) async {
    var ad = double.parse(amount);
    var ai = BigInt.from(ad) * BigInt.from(decimals);

    var wm = await WalletManager.sington();
    var fromAddr = await Address.fromBase58(from);
    var toAddr = await Address.fromBase58(to);
    var fromAcc = wm.findAccountByAddr(from);
    var prikey = await fromAcc.decrypt(pwd);

    var b = Oep4TxBuilder(await Address.fromValue(contractHash));
    var tx =
        await b.makeTransferTx(fromAddr, toAddr, ai, 500, 300000000, fromAddr);

    var txb = TxBuilder();
    await txb.sign(tx, prikey);

    var rpc = WebsocketRpc(await rpcAddress());
    rpc.connect();
    await rpc.sendRawTx(await tx.serialize(), preExec: false);
    rpc.close();
  }
}
