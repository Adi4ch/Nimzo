import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/user.dart';
import '../user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  SupabaseClient get _client =>
      SupabaseBootstrap.client ??
      (throw StateError('Supabase is not configured.'));

  @override
  Future<NimzoUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user == null ? null : getById(user.id);
  }

  @override
  Future<NimzoUser?> ensureCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final existing = await getById(authUser.id);
    if (existing != null) return existing;

    final profile = await _client
        .from('profiles')
        .upsert({
          'id': authUser.id,
          'display_name':
              authUser.userMetadata?['display_name']?.toString() ?? '',
        })
        .select()
        .single();
    await _client
        .from('wallets')
        .upsert({'user_id': authUser.id}, onConflict: 'user_id');
    return NimzoUser.fromMap(profile);
  }

  @override
  Future<NimzoUser?> getById(String id) async {
    final row =
        await _client.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : NimzoUser.fromMap(row);
  }

  @override
  Future<List<NimzoUser>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];
    final rows = await _client
        .from('profiles')
        .select()
        .or('display_name.ilike.%$normalized%,username.ilike.%$normalized%,nimzo_id.ilike.%$normalized%')
        .limit(30);
    return rows.map((row) => NimzoUser.fromMap(row)).toList();
  }

  @override
  Future<bool> isFollowing(String userId) async {
    final currentId = _client.auth.currentUser?.id;
    if (currentId == null) return false;
    final row = await _client
        .from('user_follows')
        .select('follower_id')
        .eq('follower_id', currentId)
        .eq('following_id', userId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<void> follow(String userId) async {
    final currentId = _client.auth.currentUser?.id;
    if (currentId == null)
      throw StateError('An authenticated user is required.');
    await _client
        .from('user_follows')
        .upsert({'follower_id': currentId, 'following_id': userId});
  }

  @override
  Future<void> unfollow(String userId) async {
    final currentId = _client.auth.currentUser?.id;
    if (currentId == null)
      throw StateError('An authenticated user is required.');
    await _client
        .from('user_follows')
        .delete()
        .eq('follower_id', currentId)
        .eq('following_id', userId);
  }

  @override
  Future<NimzoUser> updateProfile(
      {required String displayName,
      String? username,
      String? bio,
      String? avatarUrl,
      String? country,
      String? gender}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client
        .from('profiles')
        .update({
          'display_name': displayName,
          'username': username,
          'bio': bio,
          'avatar_url': avatarUrl,
          'country': country,
          'gender': gender
        })
        .eq('id', userId)
        .select()
        .single();
    return NimzoUser.fromMap(row);
  }
}
