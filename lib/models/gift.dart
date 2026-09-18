class NimzoGift {
  final String id;
  final String name;
  final int coinCost;
  final String? iconName;

  const NimzoGift({required this.id, required this.name, required this.coinCost, this.iconName});

  NimzoGift copyWith({String? id, String? name, int? coinCost, String? iconName}) => NimzoGift(id: id ?? this.id, name: name ?? this.name, coinCost: coinCost ?? this.coinCost, iconName: iconName ?? this.iconName);

  factory NimzoGift.fromMap(Map<String, dynamic> map) => NimzoGift(id: map['id'] as String, name: map['name'] as String? ?? '', coinCost: map['coin_cost'] as int? ?? 0, iconName: map['icon_name'] as String?);

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'coin_cost': coinCost, 'icon_name': iconName};
}
