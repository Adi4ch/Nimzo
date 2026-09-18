import 'wallet_transaction.dart';

class NimzoWallet {
  final String id;
  final String userId;
  final int balance;
  final List<WalletTransaction> transactions;

  const NimzoWallet({required this.id, required this.userId, this.balance = 0, this.transactions = const []});

  NimzoWallet copyWith({String? id, String? userId, int? balance, List<WalletTransaction>? transactions}) => NimzoWallet(id: id ?? this.id, userId: userId ?? this.userId, balance: balance ?? this.balance, transactions: transactions ?? this.transactions);

  factory NimzoWallet.fromMap(Map<String, dynamic> map) => NimzoWallet(id: map['id'] as String, userId: map['user_id'] as String? ?? '', balance: map['balance'] as int? ?? 0, transactions: ((map['transactions'] ?? map['wallet_transactions']) as List<dynamic>? ?? []).map((item) => WalletTransaction.fromMap(Map<String, dynamic>.from(item as Map))).toList());

  Map<String, dynamic> toMap() => {'id': id, 'user_id': userId, 'balance': balance, 'transactions': transactions.map((item) => item.toMap()).toList()};
}
