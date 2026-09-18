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
    throw UnsupportedError('Wallet changes require a reviewed server-side function or Edge Function.');
  }
}
