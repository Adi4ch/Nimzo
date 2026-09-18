# Nimzo Flutter UI v1

Nimzo is a Flutter UI foundation for social voice rooms. The current build includes Home, Rooms, Discover, Wallet, Profile, Host Center, a 10-seat voice room, room Gift/Music/Game actions, and the demo game-list flow.

## Structure

- `lib/app.dart` and `lib/theme/`: app bootstrap and shared visual defaults.
- `lib/navigation/`: bottom navigation shell for Home, Rooms, Discover, Wallet, and Profile.
- `lib/screens/`: feature screens, including the voice room and games.
- `lib/widgets/`: reusable room, seat, social, wallet, navigation, and menu components.
- `lib/models/`: dependency-free entities with `fromMap`, `toMap`, and `copyWith` support.
- `lib/repositories/`: backend-ready abstract contracts and local implementations under `mock/`.

## Data Flow

The intended production boundary is `Flutter UI -> repository interfaces -> future Supabase implementation`. The current app uses the mock repositories and `DemoData`, so no credentials or backend connection are needed while the UI is being developed.

Supabase, Agora, authentication, payments, and real game providers are intentionally not connected. Games and wallet actions use local demo state only. All visuals and code are original.
