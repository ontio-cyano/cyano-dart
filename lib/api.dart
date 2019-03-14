import 'package:ontology_dart_sdk/network.dart';
import 'package:ontology_dart_sdk/Crypto.dart';
import 'model/network.dart';
import 'package:ontology_dart_sdk/neocore.dart';
import 'package:cyano_dart/model/wallet.dart';

class Balance {
  int ont = 0;
  double ong = 0;
  double unBoundOng = 0;
  double unClaimedOng = 0;
}

Future<String> rpcAddress() async {
  var nm = await NetworkManager.sington();
  return 'ws://' + nm.defaultNode + ':20335';
}

Future<Balance> queryBalance(String addr) async {
  var b = Balance();
  if (addr.isEmpty) return b;
  var rpc = WebsocketRpc(await rpcAddress());
  rpc.connect();
  var address = await Address.fromBase58(addr);
  var res = await rpc.getBalance(address);
  b.ont = int.parse(res['ont']);
  b.ong = int.parse(res['ong']) / 1e9;
  b.unClaimedOng = int.parse(await rpc.getUnclaimedOng(address)) / 1e9;
  b.unBoundOng = int.parse(await rpc.getUnboundOng(address)) / 1e9;
  rpc.close();
  return b;
}

Future<void> claimOng(String addr, String pwd) async {
  if (addr.isEmpty) return;

  var rpc = WebsocketRpc(await rpcAddress());
  rpc.connect();

  var wm = await WalletManager.sington();
  var acc = wm.findAccountByAddr(addr);
  var prikey = await acc.decrypt(pwd);

  var address = await Address.fromBase58(addr);
  var from = address;
  var to = address;

  var unclaimed = int.parse(await rpc.getUnboundOng(address));
  var ob = OntAssetTxBuilder();
  var tx = await ob.makeWithdrawOngTx(
      from, to, BigInt.from(unclaimed), 500, 2000000, from);

  var txb = TxBuilder();
  await txb.sign(tx, prikey);

  await rpc.sendRawTx(await tx.serialize(), preExec: false);
  rpc.close();
}
