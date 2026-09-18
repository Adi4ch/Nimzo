class WalletTransaction {
  final String id;
  final String walletId;
  final String type;
  final int amount;
  final String description;
  final String? createdAt;

  const WalletTransaction({required this.id, required this.walletId, required this.type, required this.amount, required this.description, this.createdAt});

  WalletTransaction copyWith({String? id, String? walletId, String? type, int? amount, String? description, String? createdAt}) => WalletTransaction(id: id ?? this.id, walletId: walletId ?? this.walletId, type: type ?? this.type, amount: amount ?? this.amount, description: description ?? this.description, createdAt: createdAt ?? this.createdAt);

  factory WalletTransaction.fromMap(Map<String, dynamic> map) => WalletTransaction(id: map['id'] as String, walletId: map['wallet_id'] as String? ?? '', type: map['type'] as String? ?? '', amount: map['amount'] as int? ?? 0, description: map['description'] as String? ?? '', createdAt: map['created_at'] as String?);

  Map<String, dynamic> toMap() => {'id': id, 'wallet_id': walletId, 'type': type, 'amount': amount, 'description': description, 'created_at': createdAt};
}
