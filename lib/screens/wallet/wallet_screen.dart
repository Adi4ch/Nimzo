import 'package:flutter/material.dart';

import '../../models/wallet_transaction.dart';
import '../../repositories/mock/demo_data.dart';
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

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const AppHeader('Wallet'),
        CoinBalanceCard(balance: balance, onRecharge: () => _recharge(context)),
        const SectionHeader('Recent Transactions'),
          for (final transaction in DemoData.walletTransactions) _transactionTile(transaction),
      ]);

        Widget _transactionTile(WalletTransaction transaction) => ListTile(leading: const CircleAvatar(backgroundColor: lightMint, child: Icon(Icons.receipt_long, color: mint)), title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w700)));

  void _recharge(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recharge demo coins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, children: [for (final amount in [500, 1000, 2500]) OutlinedButton(onPressed: () { setState(() => balance += amount); Navigator.pop(context); }, child: Text('+$amount'))]),
          const SizedBox(height: 8),
          const Text('Payments are not connected. These are virtual coins.', style: TextStyle(color: muted)),
        ]))),
      );
}
