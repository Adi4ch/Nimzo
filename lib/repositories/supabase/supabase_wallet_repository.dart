import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/wallet.dart';
import '../../models/wallet_transaction.dart';
import '../wallet_repository.dart';

class SupabaseWalletRepository implements WalletRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<NimzoWallet> getWallet(String userId) async {
    final row = await _client.from('wallets').select('*, wallet_transactions(*)').eq('user_id', userId).single();
    return NimzoWallet.fromMap(row);
  }

  @override
  Future<List<WalletTransaction>> getTransactions(String walletId) async {
    final rows = await _client.from('wallet_transactions').select().eq('wallet_id', walletId).order('created_at', ascending: false);
    return rows.map(WalletTransaction.fromMap).toList();
  }

  @override
  Future<NimzoWallet> recharge(String walletId, int amount) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'must be positive');
    await _client.rpc('recharge_virtual_coins', params: {'p_wallet_id': walletId, 'p_amount': amount});
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    return getWallet(userId);
  }
}
