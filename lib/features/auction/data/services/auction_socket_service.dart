import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class BidUpdate {
  final String bidderName;
  final num amount;
  final int totalBidders;
  
  BidUpdate({required this.bidderName, required this.amount, required this.totalBidders});
  
  factory BidUpdate.fromJson(Map<String, dynamic> json) {
    return BidUpdate(
      bidderName: json['bidder_name'] ?? 'Anonim',
      amount: json['amount'] ?? 0,
      totalBidders: json['total_bidders'] ?? 1,
    );
  }
}

class AuctionSocketService {
  static final AuctionSocketService _instance = AuctionSocketService._internal();
  factory AuctionSocketService() => _instance;
  AuctionSocketService._internal();

  IO.Socket? _socket;
  final _bidController = StreamController<BidUpdate>.broadcast();
  final _outbidController = StreamController<bool>.broadcast();

  Stream<BidUpdate> get bidStream => _bidController.stream;
  Stream<bool> get outbidStream => _outbidController.stream;

  void connect(String token) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io('$baseUrl/auction', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Auction Socket Connected');
    });

    _socket!.on('bid_update', (data) {
      if (!_bidController.isClosed) {
        _bidController.sink.add(BidUpdate.fromJson(data));
      }
    });

    _socket!.on('outbid', (data) {
      if (!_outbidController.isClosed) {
        _outbidController.sink.add(true);
      }
    });
  }

  void joinAuction(String auctionId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_auction', auctionId);
    }
  }

  void placeBid(String auctionId, num amount) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('place_bid', {
        'auction_id': auctionId,
        'amount': amount,
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
