import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_bootstrap.dart';
import 'auth_repository.dart';
import 'chat_repository.dart';
import 'game_repository.dart';
import 'gift_repository.dart';
import 'host_repository.dart';
import 'mock/mock_auth_repository.dart';
import 'mock/mock_chat_repository.dart';
import 'mock/mock_game_repository.dart';
import 'mock/mock_gift_repository.dart';
import 'mock/mock_host_repository.dart';
import 'mock/mock_room_repository.dart';
import 'mock/mock_social_repository.dart';
import 'mock/mock_user_repository.dart';
import 'mock/mock_wallet_repository.dart';
import 'room_repository.dart';
import 'social_repository.dart';
import 'supabase/supabase_auth_repository.dart';
import 'supabase/supabase_chat_repository.dart';
import 'supabase/supabase_game_repository.dart';
import 'supabase/supabase_gift_repository.dart';
import 'supabase/supabase_host_repository.dart';
import 'supabase/supabase_room_repository.dart';
import 'supabase/supabase_social_repository.dart';
import 'supabase/supabase_user_repository.dart';
import 'supabase/supabase_wallet_repository.dart';
import 'user_repository.dart';
import 'wallet_repository.dart';

class RepositoryFactory {
  static bool get usesSupabase => SupabaseBootstrap.isConfigured;

  static AuthRepository auth() => usesSupabase ? SupabaseAuthRepository() : MockAuthRepository();
  static ChatRepository chat() => usesSupabase ? SupabaseChatRepository() : MockChatRepository();
  static UserRepository users() => usesSupabase ? SupabaseUserRepository() : MockUserRepository();
  static RoomRepository rooms() => usesSupabase ? SupabaseRoomRepository() : MockRoomRepository();
  static SocialRepository social() => usesSupabase ? SupabaseSocialRepository() : MockSocialRepository();
  static WalletRepository wallet() => usesSupabase ? SupabaseWalletRepository() : MockWalletRepository();
  static GameRepository games() => usesSupabase ? SupabaseGameRepository() : MockGameRepository();
  static GiftRepository gifts() => usesSupabase ? SupabaseGiftRepository() : MockGiftRepository();
  static HostRepository host() => usesSupabase ? SupabaseHostRepository() : MockHostRepository();

  static SupabaseClient? get client => SupabaseBootstrap.client;
}
