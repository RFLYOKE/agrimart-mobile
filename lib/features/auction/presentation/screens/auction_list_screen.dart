import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/auction_provider.dart';
import 'auction_detail_screen.dart';

class AuctionListScreen extends ConsumerWidget {
  const AuctionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctions = ref.watch(auctionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Auction LIVE'),
        backgroundColor: AppColors.errorRed,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final auction = auctions[index];
          return Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AuctionDetailScreen(auction: auction),
                ));
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: auction.photoUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 1.0, end: 0.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: (value < 0.5) ? 1.0 : 0.2, // blinking effect
                              child: child,
                            );
                          },
                          onEnd: () {
                             // Re-run animation would need a StatefulWidget or explicit controller
                             // Doing simple blink simulation for UI
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: Colors.white, size: 10),
                                SizedBox(width: 4),
                                Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auction.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Harga Saat Ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(
                                  CurrencyFormatter.formatRupiah(auction.startingPrice), // Will be updated via provider if detailed tracking
                                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
                                )
                              ],
                            ),
                            TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
                              final now = DateTime.now();
                              final remaining = auction.endTime.difference(now);
                              
                              if (remaining.isNegative) {
                                return const Text('Selesai', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
                              }

                              String twoDigits(int n) => n.toString().padLeft(2, '0');
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  '${twoDigits(remaining.inMinutes)}:${twoDigits(remaining.inSeconds.remainder(60))}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: remaining.inMinutes < 5 ? Colors.red : Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('12 penawar aktif', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
