import '../../models/comment.dart';
import '../../models/game.dart';
import '../../models/gift.dart';
import '../../models/host_profile.dart';
import '../../models/room.dart';
import '../../models/room_seat.dart';
import '../../models/social_post.dart';
import '../../models/user.dart';
import '../../models/wallet.dart';
import '../../models/wallet_transaction.dart';

class DemoData {
  static const currentUser = NimzoUser(id: 'user-1', displayName: 'Nimzo User', level: 5, friendsCount: 256, followersCount: 4200, followingCount: 1800);

  static const featuredRooms = [
    NimzoRoom(id: 'room-chill', name: 'Chill Vibes', category: 'Popular', listenerCount: 1200, featured: true),
    NimzoRoom(id: 'room-music', name: 'Music Zone', category: 'Music', listenerCount: 1200, featured: true),
    NimzoRoom(id: 'room-friends', name: 'Friends Talk', category: 'Chat', listenerCount: 1200, featured: true),
  ];

  static const rooms = [
    NimzoRoom(id: 'room-chill', name: 'Chill Vibes', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'Popular', listenerCount: 2400),
    NimzoRoom(id: 'room-music', name: 'Music Room', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'Music', listenerCount: 2400),
    NimzoRoom(id: 'room-friendship', name: 'Friendship Room', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'Chat', listenerCount: 2400),
    NimzoRoom(id: 'room-gaming', name: 'Gaming Zone', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'New', listenerCount: 2400),
    NimzoRoom(id: 'room-love', name: 'Love & Relationship', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'Chat', listenerCount: 2400),
    NimzoRoom(id: 'room-study', name: 'Study & Career', subtitle: 'Sing  |  Dance  |  Enjoy', category: 'New', listenerCount: 2400),
  ];

  static const moreRooms = [
    NimzoRoom(id: 'room-ludo-lounge', name: 'Ludo Lounge', category: 'Gaming', listenerCount: 1200),
    NimzoRoom(id: 'room-carrom-club', name: 'Carrom Club', category: 'Gaming', listenerCount: 1200),
    NimzoRoom(id: 'room-8-ball', name: '8 Ball Pool', category: 'Gaming', listenerCount: 1200),
    NimzoRoom(id: 'room-study-circle', name: 'Study Circle', category: 'Chat', listenerCount: 1200),
  ];

  static const games = [
    NimzoGame(id: 'ludo', name: 'Ludo', category: 'Board'),
    NimzoGame(id: 'carrom', name: 'Carrom', category: 'Board'),
    NimzoGame(id: '8-ball-pool', name: '8 Ball Pool', category: 'Classic'),
    NimzoGame(id: 'fruit-party', name: 'Fruit Party', category: 'Classic'),
    NimzoGame(id: 'teen-patti', name: 'Teen Patti', category: 'Classic'),
    NimzoGame(id: 'luck-77', name: 'Luck 77', category: 'Classic'),
  ];

  static const posts = [
    SocialPost(id: 'post-1', userId: 'user-1', text: 'Life is better when you smile', likes: 342, comments: 56),
    SocialPost(id: 'post-2', userId: 'user-1', text: 'Good vibes only', likes: 342, comments: 56),
  ];

  static const walletTransactions = [
    WalletTransaction(id: 'tx-1', walletId: 'wallet-1', type: 'recharge', amount: 1000, description: 'Recharge  +1,000 Coins'),
    WalletTransaction(id: 'tx-2', walletId: 'wallet-1', type: 'game_win', amount: 250, description: 'Game Win  +250 Coins'),
    WalletTransaction(id: 'tx-3', walletId: 'wallet-1', type: 'room_gift', amount: 500, description: 'Room Gift  +500 Coins'),
    WalletTransaction(id: 'tx-4', walletId: 'wallet-1', type: 'withdraw', amount: -3000, description: 'Withdraw  -3,000 Coins'),
  ];

  static const wallet = NimzoWallet(id: 'wallet-1', userId: 'user-1', balance: 12450, transactions: walletTransactions);
  static const gifts = [NimzoGift(id: 'gift-1', name: 'Rose', coinCost: 10, iconName: 'favorite')];
  static const hostProfile = HostProfile(id: 'host-1', userId: 'user-1', level: 5, agencyName: 'Nimzo Agency', earningsCoins: 0);
  static const comments = <NimzoComment>[];

  static List<RoomSeat> seatsForRoom(String roomId) => List.generate(10, (index) => RoomSeat(id: '$roomId-seat-${index + 1}', position: index, active: index < 5));
}
