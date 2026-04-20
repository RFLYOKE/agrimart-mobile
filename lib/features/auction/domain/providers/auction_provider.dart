import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auction_socket_service.dart';
import '../../../auth/domain/providers/auth_provider.dart';

class AuctionModel {
  final String id;
  final String productName;
  final String photoUrl;
  final num startingPrice;
  final DateTime endTime;
  
  AuctionModel({
    required this.id, required this.productName, required this.photoUrl,
    required this.startingPrice, required this.endTime,
  });
}

class BidModel {
  final String bidderName;
  final num amount;
  final DateTime time;
  
  BidModel({required this.bidderName, required this.amount, required this.time});
}

class AuctionState {
  final AuctionModel? auction;
  final List<BidModel> bids;
  final num currentHighestBid;
  final bool isUserWinning;
  final int totalBidders;
  
  AuctionState({
    this.auction,
    this.bids = const [],
    this.currentHighestBid = 0,
    this.isUserWinning = false,
    this.totalBidders = 0,
  });
  
  AuctionState copyWith({
    AuctionModel? auction,
    List<BidModel>? bids,
    num? currentHighestBid,
    bool? isUserWinning,
    int? totalBidders,
  }) {
    return AuctionState(
      auction: auction ?? this.auction,
      bids: bids ?? this.bids,
      currentHighestBid: currentHighestBid ?? this.currentHighestBid,
      isUserWinning: isUserWinning ?? this.isUserWinning,
      totalBidders: totalBidders ?? this.totalBidders,
    );
  }
}

class AuctionNotifier extends StateNotifier<AuctionState> {
  final AuctionSocketService _service = AuctionSocketService();
  final Ref ref;
  
  AuctionNotifier(this.ref) : super(AuctionState()) {
    _initSocket();
  }
  
  Future<void> _initSocket() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access_token') ?? '';
    _service.connect(token);
    
    _service.bidStream.listen((update) {
      final user = ref.read(authProvider.notifier).currentUser;
      final isWinning = update.bidderName == user?.name;
      
      final newBid = BidModel(
        bidderName: update.bidderName, 
        amount: update.amount, 
        time: DateTime.now()
      );
      
      state = state.copyWith(
        bids: [newBid, ...state.bids],
        currentHighestBid: update.amount,
        isUserWinning: isWinning,
        totalBidders: update.totalBidders,
      );
    });
  }

  void loadAuction(AuctionModel auction) {
    state = state.copyWith(
      auction: auction,
      currentHighestBid: auction.startingPrice,
      bids: [],
    );
    _service.joinAuction(auction.id);
  }

  void placeBid(num amount) {
    if (state.auction != null) {
      _service.placeBid(state.auction!.id, amount);
      // Wait for server acknowledgment via bidStream for UI update to prevent race conditions
    }
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}

final auctionProvider = StateNotifierProvider.autoDispose<AuctionNotifier, AuctionState>((ref) {
  return AuctionNotifier(ref);
});

// Mock Provider for Auction List
class AuctionListNotifier extends StateNotifier<List<AuctionModel>> {
  AuctionListNotifier() : super([
    AuctionModel(
      id: 'a1',
      productName: 'Kopi Arabica Gayo Premium 50kg',
      photoUrl: 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      startingPrice: 3500000,
      endTime: DateTime.now().add(const Duration(minutes: 15)),
    ),
    AuctionModel(
      id: 'a2',
      productName: 'Kakao Fermentasi Super 100kg',
      photoUrl: 'https://images.unsplash.com/photo-1611181267885-fb405fcb8bdf?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      startingPrice: 4200000,
      endTime: DateTime.now().add(const Duration(hours: 1)),
    )
  ]);
}

final auctionListProvider = StateNotifierProvider<AuctionListNotifier, List<AuctionModel>>((ref) {
  return AuctionListNotifier();
});
