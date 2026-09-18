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

Agora, payments, and real game providers are intentionally not connected. Supabase auth/database support is optional and credential-free by default. Games and wallet actions use local demo state unless a future production data flow is explicitly enabled. All visuals and code are original.

## Supabase Setup

The optional Supabase client reads values at build time; credentials are never stored in the repository:

```bash
flutter run \
	--dart-define=SUPABASE_URL=https://your-project.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Run `supabase/migrations/001_nimzo_schema.sql` in a Supabase project (or through the Supabase CLI) before enabling the configured client. The migration creates the core tables, relationships, indexes, and RLS policies. Auth uses Supabase email signup, password login, logout, `currentUser`, and `onAuthStateChange` through `AuthRepository`.

Wallet balances and wallet transactions have no client write policies. A future reviewed server-side function or Edge Function must perform coin operations; the Flutter repository deliberately refuses direct balance changes. Without the two defines, `RepositoryFactory` keeps the mock repositories and the existing demo UI remains usable.
