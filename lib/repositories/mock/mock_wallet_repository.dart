import '../../models/wallet.dart';
import '../../models/wallet_transaction.dart';
import '../wallet_repository.dart';
import 'demo_data.dart';

class MockWalletRepository implements WalletRepository {
  NimzoWallet wallet = DemoData.wallet;

  @override
  Future<NimzoWallet> getWallet(String userId) async => wallet;

  @override
  Future<List<WalletTransaction>> getTransactions(String walletId) async => wallet.transactions;

  @override
  Future<NimzoWallet> recharge(String walletId, int amount) async {
    final transaction = WalletTransaction(id: 'tx-${wallet.transactions.length + 1}', walletId: walletId, type: 'recharge', amount: amount, description: 'Recharge  +$amount Coins');
    wallet = wallet.copyWith(balance: wallet.balance + amount, transactions: [...wallet.transactions, transaction]);
    return wallet;
  }
}
