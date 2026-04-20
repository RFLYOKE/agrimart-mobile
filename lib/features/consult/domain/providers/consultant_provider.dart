import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/consultant_model.dart';

// Mock list or API interaction to fetch consultants
class ConsultantNotifier extends AsyncNotifier<List<ConsultantModel>> {
  @override
  Future<List<ConsultantModel>> build() async {
    // In a real app we fetch from `consultantRepository.getConsultants()`
    await Future.delayed(const Duration(seconds: 1)); // Mock network delay
    return [
      ConsultantModel(
        id: 'c1',
        name: 'Budi Santoso',
        expertise: 'Peternakan',
        rating: 4.8,
        bio: 'Ahli peternakan sapi perah dengan pengalaman 10 tahun.',
        photoUrl: '', // empty to use placeholder
        price: 50000,
        availableSlots: ['09:00', '10:00', '14:00', '16:00'],
      ),
      ConsultantModel(
        id: 'c2',
        name: 'Siti Aminah',
        expertise: 'Pertanian',
        rating: 4.9,
        bio: 'Pakar hidroponik dan pertanian organik terpadu.',
        photoUrl: '',
        price: 75000,
        availableSlots: ['08:00', '11:00', '13:00'],
      ),
      ConsultantModel(
        id: 'c3',
        name: 'Ahmad Rizal',
        expertise: 'Perikanan',
        rating: 4.7,
        bio: 'Spesialis budidaya ikan air tawar dan bioflok.',
        photoUrl: '',
        price: 60000,
        availableSlots: ['15:00', '19:00'],
      ),
    ];
  }
}

final consultantProvider = AsyncNotifierProvider<ConsultantNotifier, List<ConsultantModel>>(() {
  return ConsultantNotifier();
});
