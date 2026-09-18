# Nimzo Flutter UI v1

Nimzo is a Flutter UI foundation for social voice rooms. The current build includes Home, Rooms, Discover, Wallet, Profile, Host Center, a 10-seat voice room, room Gift/Music/Game actions, and the demo game-list flow.

## Structure

- `lib/app.dart` and `lib/theme/`: app bootstrap and shared visual defaults.
- `lib/navigation/`: bottom navigation shell for Home, Rooms, Discover, Wallet, and Profile.
- `lib/screens/`: feature screens, including the voice room and games.
- `lib/widgets/`: reusable room, seat, social, wallet, navigation, and menu components.
- `lib/models/`: lightweight local demo models.

Supabase, Agora, authentication, payments, and real game providers are intentionally not connected. Games and wallet actions use local demo state only. All visuals and code are original.
