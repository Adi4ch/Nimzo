import 'package:flutter/material.dart';

import '../../models/wallet_transaction.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/coin_balance_card.dart';
import '../../widgets/section_header.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int balance = DemoData.wallet.balance;
  List<WalletTransaction> transactions = DemoData.walletTransactions;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final userId = RepositoryFactory.auth().currentUser?.id;
    if (userId == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final wallet = await RepositoryFactory.wallet().getWallet(userId);
      if (mounted)
        setState(() {
          balance = wallet.balance;
          transactions = wallet.transactions;
        });
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: _loadWallet,
        color: mint,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const AppHeader('Wallet'),
          if (loading) const LinearProgressIndicator(color: mint),
          if (error != null)
            Card(
                child: ListTile(
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                    title: const Text('Wallet could not refresh'),
                    subtitle: Text(error!),
                    trailing: IconButton(
                        onPressed: _loadWallet,
                        icon: const Icon(Icons.refresh)))),
          CoinBalanceCard(
              balance: balance, onRecharge: () => _recharge(context)),
          const SectionHeader('Transaction history'),
          if (transactions.isEmpty)
            const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Text('No transactions yet.',
                        style: TextStyle(color: muted))))
          else
            ...transactions.map(_transactionTile),
        ]),
      );

  Widget _transactionTile(WalletTransaction transaction) => ListTile(
        leading: CircleAvatar(
            backgroundColor:
                transaction.amount >= 0 ? lightMint : const Color(0xFFFFEBEE),
            child: Icon(
                transaction.amount >= 0
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.amount >= 0 ? mint : Colors.red)),
        title: Text(transaction.description,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: transaction.createdAt == null
            ? null
            : Text(transaction.createdAt!.split('T').first,
                style: const TextStyle(color: muted)),
        trailing: Text(
            '${transaction.amount >= 0 ? '+' : ''}${transaction.amount}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: transaction.amount >= 0 ? mint : Colors.red)),
      );

  void _recharge(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recharge demo coins',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ink)),
                      const SizedBox(height: 14),
                      Wrap(spacing: 10, children: [
                        for (final amount in [500, 1000, 2500])
                          OutlinedButton(
                              onPressed: () async {
                                try {
                                  final userId =
                                      RepositoryFactory.auth().currentUser?.id;
                                  if (userId == null ||
                                      !RepositoryFactory.usesSupabase) {
                                    setState(() => balance += amount);
                                    Navigator.pop(context);
                                    return;
                                  }
                                  final wallet =
                                      await RepositoryFactory.wallet()
                                          .getWallet(userId);
                                  final updated =
                                      await RepositoryFactory.wallet()
                                          .recharge(wallet.id, amount);
                                  if (context.mounted)
                                    setState(() {
                                      balance = updated.balance;
                                      transactions = updated.transactions;
                                    });
                                } catch (exception) {
                                  if (context.mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Demo recharge server-side only: $exception')));
                                }
                                if (context.mounted) Navigator.pop(context);
                                if (mounted) await _loadWallet();
                              },
                              child: Text('+$amount'))
                      ]),
                      const SizedBox(height: 8),
                      const Text(
                          'Payments are not connected. These are virtual coins.',
                          style: TextStyle(color: muted)),
                    ]))),
      );
}
