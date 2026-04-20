import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/auction_provider.dart';
import 'winner_screen.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final AuctionModel auction;

  const AuctionDetailScreen({super.key, required this.auction});

  @override
  ConsumerState<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  final _manualBidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auctionProvider.notifier).loadAuction(widget.auction);
    });
  }

  @override
  void dispose() {
    _manualBidController.dispose();
    super.dispose();
  }

  void _placeBid(num increment) {
    final currentBid = ref.read(auctionProvider).currentHighestBid;
    ref.read(auctionProvider.notifier).placeBid(currentBid + increment);
  }

  void _placeManualBid() {
    final val = num.tryParse(_manualBidController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (val != null) {
      final currentBid = ref.read(auctionProvider).currentHighestBid;
      if (val > currentBid) {
        ref.read(auctionProvider.notifier).placeBid(val);
        _manualBidController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid harus lebih tinggi dari saat ini')));
      }
    }
  }

  void _timerFinished() {
    final state = ref.read(auctionProvider);
    if (state.isUserWinning) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => WinnerScreen(auction: widget.auction, finalPrice: state.currentHighestBid),
      ));
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Lelang Selesai'),
          content: Text('Pemenang lelang ini adalah ${state.bids.isNotEmpty ? state.bids.first.bidderName : 'Tidak ada'}.'),
          actions: [
            ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Kembali ke Menu'))
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auctionProvider);
    final currentBid = state.currentHighestBid;

    // Listen to outbid updates for snackbar (if implementing full socket)
    // ref.listen(auctionProvider, (previous, next) {
    //   if (previous?.isUserWinning == true && next.isUserWinning == false) {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamu kalah bid!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    //   }
    // });

    return Scaffold(
      body: Column(
        children: [
          // Hero Image
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.auction.photoUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ),
              Positioned(
                top: 50,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('${state.totalBidders} Penawar', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(widget.auction.productName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                
                TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
                  final now = DateTime.now();
                  final remaining = widget.auction.endTime.difference(now);
                  
                  if (remaining.isNegative) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                       if(mounted) _timerFinished();
                    });
                    return const Text('LELANG BERAKHIR', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold));
                  }

                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  final h = twoDigits(remaining.inHours);
                  final m = twoDigits(remaining.inMinutes.remainder(60));
                  final s = twoDigits(remaining.inSeconds.remainder(60));
                  
                  final isCritical = remaining.inMinutes < 5;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCritical ? Colors.red[100] : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isCritical ? Colors.red : AppColors.primaryGreen, width: 2)
                    ),
                    child: Text(
                      '$h : $m : $s',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.red : AppColors.primaryGreen,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                const Text('Current Highest Bid', style: TextStyle(color: Colors.grey)),
                Text(
                  CurrencyFormatter.formatRupiah(currentBid),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                if (state.bids.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('oleh ${state.bids.first.bidderName}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),

          // Bid History (Animated ListView)
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bids.length > 5 ? 5 : state.bids.length,
                itemBuilder: (context, index) {
                  final bid = state.bids[index];
                  // If we wanted true slide-in, we'd use AnimatedList. Standard ListView for simplicity as requested, 
                  // but we added visually appealing tiles
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(bid.bidderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${bid.time.hour}:${bid.time.minute.toString().padLeft(2,'0')} WIB'),
                    trailing: Text(CurrencyFormatter.formatRupiahCompact(bid.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => _placeBid(500), child: const Text('+ Rp500'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () => _placeBid(1000), child: const Text('+ Rp1rb'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () => _placeBid(5000), child: const Text('+ Rp5rb'))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualBidController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Bid Manual (Rp)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed, // red to show urgency/auction style
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: _placeManualBid,
                    child: const Text('BID SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
