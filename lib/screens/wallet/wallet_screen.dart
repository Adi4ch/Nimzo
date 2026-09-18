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

  @override
  void initState() { super.initState(); _loadWallet(); }

  Future<void> _loadWallet() async {
    final userId = RepositoryFactory.auth().currentUser?.id;
    if (userId == null) return;
    setState(() => loading = true);
    try {
      final wallet = await RepositoryFactory.wallet().getWallet(userId);
      if (mounted) setState(() { balance = wallet.balance; transactions = wallet.transactions; });
    } catch (_) {
      // Demo data remains available when Supabase has no wallet row yet.
    } finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const AppHeader('Wallet'),
        if (loading) const LinearProgressIndicator(color: mint),
        CoinBalanceCard(balance: balance, onRecharge: () => _recharge(context)),
        const SectionHeader('Recent Transactions'),
          for (final transaction in transactions) _transactionTile(transaction),
      ]);

        Widget _transactionTile(WalletTransaction transaction) => ListTile(leading: const CircleAvatar(backgroundColor: lightMint, child: Icon(Icons.receipt_long, color: mint)), title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w700)));

  void _recharge(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recharge demo coins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, children: [for (final amount in [500, 1000, 2500]) OutlinedButton(onPressed: () async {
            try {
              final userId = RepositoryFactory.auth().currentUser?.id;
              if (userId == null || !RepositoryFactory.usesSupabase) { setState(() => balance += amount); Navigator.pop(context); return; }
              final wallet = await RepositoryFactory.wallet().getWallet(userId);
              await RepositoryFactory.wallet().recharge(wallet.id, amount);
            } catch (exception) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo recharge server-side only: $exception'))); }
            if (context.mounted) Navigator.pop(context);
          }, child: Text('+$amount'))]),
          const SizedBox(height: 8),
          const Text('Payments are not connected. These are virtual coins.', style: TextStyle(color: muted)),
        ]))),
      );
}
