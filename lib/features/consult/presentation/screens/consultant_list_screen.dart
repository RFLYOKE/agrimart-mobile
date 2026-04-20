import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/consultant_provider.dart';
import 'consultant_profile_screen.dart';

class ConsultantListScreen extends ConsumerStatefulWidget {
  const ConsultantListScreen({super.key});

  @override
  ConsumerState<ConsultantListScreen> createState() => _ConsultantListScreenState();
}

class _ConsultantListScreenState extends ConsumerState<ConsultantListScreen> {
  final List<String> categories = ['Semua', 'Pertanian', 'Perikanan', 'Peternakan', 'Bisnis'];
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final asyncConsultants = ref.watch(consultantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriConsult'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: asyncConsultants.when(
              data: (consultants) {
                final filtered = _selectedCategory == 'Semua' 
                    ? consultants 
                    : consultants.where((c) => c.expertise.toLowerCase() == _selectedCategory.toLowerCase()).toList();
                
                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada konsultan di kategori ini.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ConsultantProfileScreen(consultant: c),
                          ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: c.photoUrl.isNotEmpty ? CachedNetworkImageProvider(c.photoUrl) : null,
                                child: c.photoUrl.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(c.expertise, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: AppColors.accentGold, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${c.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text('${CurrencyFormatter.formatRupiah(c.price)} / sesi', 
                                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          )
        ],
      ),
    );
  }
}
