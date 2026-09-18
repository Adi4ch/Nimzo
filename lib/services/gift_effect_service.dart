enum GiftEffectTier { basic, rare, epic, legendary }

class GiftEffect {
  final GiftEffectTier tier;
  final String icon;
  final Duration duration;

  const GiftEffect({required this.tier, required this.icon, this.duration = const Duration(milliseconds: 1300)});
}

class GiftEffectService {
  static GiftEffect forCost(int coins) => coins >= 500 ? const GiftEffect(tier: GiftEffectTier.legendary, icon: '✨', duration: Duration(milliseconds: 2400)) : coins >= 100 ? const GiftEffect(tier: GiftEffectTier.epic, icon: '🌟', duration: Duration(milliseconds: 1800)) : coins >= 50 ? const GiftEffect(tier: GiftEffectTier.rare, icon: '💫') : const GiftEffect(tier: GiftEffectTier.basic, icon: '💚');
}