import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/auction_provider.dart';

class WinnerScreen extends StatefulWidget {
  final AuctionModel auction;
  final num finalPrice;

  const WinnerScreen({super.key, required this.auction, required this.finalPrice});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final DateTime _paymentDeadline = DateTime.now().add(const Duration(minutes: 10));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Stack(
        children: [
          // Custom Confetti Painter
          Positioned.fill(
            child: AnimatedBuilder(
               animation: _controller,
               builder: (context, child) {
                 return CustomPaint(
                   painter: ConfettiPainter(_controller.value),
                 );
               },
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, size: 80, color: AppColors.accentGold),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SELAMAT!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kamu memenangkan lelang:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.auction.productName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Text('Total yang harus dibayar:', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.formatRupiah(widget.finalPrice),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.errorRed), // Red for urgency to pay
                            ),
                            const Divider(height: 32),
                            const Text('Selesaikan pembayaran dalam:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
                               final remaining = _paymentDeadline.difference(DateTime.now());
                               if (remaining.isNegative) {
                                  return const Text('Waktu Habis!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
                               }
                               String twoDigits(int n) => n.toString().padLeft(2, '0');
                               return Text(
                                 '${twoDigits(remaining.inMinutes)}:${twoDigits(remaining.inSeconds.remainder(60))}',
                                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                               );
                            }),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                onPressed: () {
                                  // Navigate to Payment Screen logic here
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka gateway pembayaran...')));
                                },
                                child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Simple Custom Painter for Confetti
class ConfettiPainter extends CustomPainter {
  final double progress;
  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42); // fixed seed for consistent positions
    final paint = Paint()..style = PaintingStyle.fill;
    
    final colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.orange, Colors.purple];

    for (int i = 0; i < 50; i++) {
        paint.color = colors[rand.nextInt(colors.length)];
        
        // Random starting positions
        final startX = rand.nextDouble() * size.width;
        final startY = rand.nextDouble() * size.height;
        
        // Falling effect
        final speed = 1.0 + (rand.nextDouble() * 2);
        double yPos = (startY + (progress * 1000 * speed)) % size.height;
        
        // Wobbly x axis
        final xPos = startX + sin((progress * 2 * pi) + rand.nextDouble()) * 20;

        canvas.drawRect(Rect.fromCenter(center: Offset(xPos, yPos), width: 8, height: 8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
