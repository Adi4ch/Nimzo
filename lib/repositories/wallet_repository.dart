import '../models/wallet.dart';
import '../models/wallet_transaction.dart';

abstract class WalletRepository {
  Future<NimzoWallet> getWallet(String userId);
  Future<List<WalletTransaction>> getTransactions(String walletId);
  Future<NimzoWallet> recharge(String walletId, int amount);
}
