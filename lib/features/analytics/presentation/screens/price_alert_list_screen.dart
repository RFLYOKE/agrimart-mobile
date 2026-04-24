import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class PriceAlert {
  final String id;
  final String commodity;
  final num targetPrice;
  final String status; // 'active' | 'triggered'
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.commodity,
    required this.targetPrice,
    required this.status,
    required this.createdAt,
  });
}

class PriceAlertListScreen extends StatefulWidget {
  const PriceAlertListScreen({super.key});

  @override
  State<PriceAlertListScreen> createState() => _PriceAlertListScreenState();
}

class _PriceAlertListScreenState extends State<PriceAlertListScreen> {
  // Mock data; in production, fetch from API
  final List<PriceAlert> _alerts = [
    PriceAlert(id: '1', commodity: 'Cabai Merah', targetPrice: 45000, status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    PriceAlert(id: '2', commodity: 'Udang Vannamei', targetPrice: 85000, status: 'triggered', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    PriceAlert(id: '3', commodity: 'Bawang Putih', targetPrice: 32000, status: 'active', createdAt: DateTime.now().subtract(const Duration(hours: 10))),
  ];

  void _removeAlert(String id) {
    setState(() => _alerts.removeWhere((a) => a.id == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert berhasil dinonaktifkan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts Saya'),
      ),
      body: _alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada price alert aktif', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final isActive = alert.status == 'active';

                return Dismissible(
                  key: Key(alert.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Nonaktifkan Alert?'),
                        content: Text('Alert untuk ${alert.commodity} akan dihapus.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _removeAlert(alert.id),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryGreen.withValues(alpha: 0.1) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: isActive ? AppColors.primaryGreen : Colors.grey,
                        ),
                      ),
                      title: Text(alert.commodity, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Target: ${CurrencyFormatter.formatRupiah(alert.targetPrice)}', style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text('Dipasang: ${DateFormatter.formatRelative(alert.createdAt)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.successGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isActive ? AppColors.successGreen : Colors.orange),
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Triggered',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColors.successGreen : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
