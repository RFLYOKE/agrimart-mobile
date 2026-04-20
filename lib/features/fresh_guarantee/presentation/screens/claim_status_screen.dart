import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class ClaimStatus {
  final String id;
  final String issueType;
  final String status; // 'pending' | 'processing' | 'approved' | 'rejected'
  final num refundAmount;
  final String? rejectReason;
  final DateTime createdAt;

  ClaimStatus({
    required this.id,
    required this.issueType,
    required this.status,
    required this.refundAmount,
    this.rejectReason,
    required this.createdAt,
  });
}

class ClaimStatusScreen extends StatelessWidget {
  final ClaimStatus claim;

  const ClaimStatusScreen({super.key, required this.claim});

  // Map status ke step index
  int get _currentStep {
    switch (claim.status) {
      case 'pending': return 0;
      case 'processing': return 1;
      case 'approved': return 2;
      case 'rejected': return 2;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = claim.status == 'approved';
    final isRejected = claim.status == 'rejected';
    final isPending = claim.status == 'pending';
    final isProcessing = claim.status == 'processing';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Klaim'),
        actions: [
          if (isPending || isProcessing)
            TextButton(onPressed: () {}, child: const Text('Bantuan', style: TextStyle(color: AppColors.primaryGreen))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ─── Status Header ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isApproved ? AppColors.successGreen
                    : isRejected ? AppColors.errorRed
                    : AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isApproved ? Icons.check_circle
                        : isRejected ? Icons.cancel
                        : Icons.hourglass_top,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isApproved ? 'Klaim Disetujui!'
                        : isRejected ? 'Klaim Ditolak'
                        : isProcessing ? 'Sedang Diproses'
                        : 'Klaim Diajukan',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diajukan: ${DateFormatter.formatDateTime(claim.createdAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── Horizontal Stepper ────────────────────────────
            _buildHorizontalStepper(isRejected),

            const SizedBox(height: 32),

            // ─── Refund Info ────────────────────────────────────
            if (isApproved) ...[
              Card(
                elevation: 0,
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.successGreen),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: AppColors.successGreen),
                          SizedBox(width: 8),
                          Text('Informasi Refund', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah Refund'),
                          Text(CurrencyFormatter.formatRupiah(claim.refundAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Estimasi Cair'),
                          Text('1-3 Hari Kerja', style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Metode'),
                          Text('Dikembalikan ke metode pembayaran asal', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ─── Reject Reason ─────────────────────────────────
            if (isRejected && claim.rejectReason != null) ...[
              Card(
                elevation: 0,
                color: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.errorRed),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.errorRed),
                          SizedBox(width: 8),
                          Text('Alasan Penolakan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(claim.rejectReason!, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],

            // ─── Estimation Time ────────────────────────────────
            if (isPending || isProcessing) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber[300]!),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.amber),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimasi Penyelesaian', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('2-5 Hari Kerja', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStepper(bool isRejected) {
    final steps = [
      ('Diajukan', Icons.send),
      ('Diproses', Icons.settings),
      (isRejected ? 'Ditolak' : 'Disetujui', isRejected ? Icons.cancel : Icons.check_circle),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = (i - 1) ~/ 2;
          final isCompleted = _currentStep > stepIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primaryGreen : Colors.grey[300],
            ),
          );
        }

        final stepIdx = i ~/ 2;
        final isCompleted = _currentStep > stepIdx;
        final isCurrent = _currentStep == stepIdx;
        final (label, icon) = steps[stepIdx];

        final bgColor = isCompleted
            ? AppColors.primaryGreen
            : isCurrent
                ? Colors.orange
                : Colors.grey[300]!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}
