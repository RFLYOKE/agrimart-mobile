import 'package:flutter/material.dart';
import '../../data/models/admin_user_model.dart';

/// Admin User List — Daftar semua pengguna dengan search & filter
class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';
  bool _isLoading = true;
  List<AdminUserModel> _users = [];

  final List<Map<String, String>> _roleFilters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'koperasi', 'label': 'Koperasi'},
    {'key': 'konsumen', 'label': 'Konsumen'},
    {'key': 'hotel_restoran', 'label': 'Hotel'},
    {'key': 'eksportir', 'label': 'Eksportir'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _users = [
        AdminUserModel(id: '1', name: 'Budi Santoso', email: 'budi@email.com', phone: '+6281234567890', role: 'konsumen', status: 'active', joinDate: DateTime(2025, 3, 15), transactionCount: 24),
        AdminUserModel(id: '2', name: 'Koperasi Tani Makmur', email: 'koptani@email.com', role: 'koperasi', status: 'active', joinDate: DateTime(2025, 1, 10), transactionCount: 156),
        AdminUserModel(id: '3', name: 'Hotel Nusantara', email: 'hotel@nusantara.com', role: 'hotel_restoran', status: 'suspended', joinDate: DateTime(2025, 6, 1), transactionCount: 89),
        AdminUserModel(id: '4', name: 'PT Agri Export', email: 'export@agri.com', role: 'eksportir', status: 'active', joinDate: DateTime(2025, 2, 20), transactionCount: 45),
      ];
      _isLoading = false;
    });
  }

  List<AdminUserModel> get _filteredUsers {
    var filtered = _users;

    // Filter by role
    if (_selectedRole != 'all') {
      filtered = filtered.where((u) => u.role == _selectedRole).toList();
    }

    // Filter by search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((u) {
        return u.name.toLowerCase().contains(query) ||
            (u.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF22C55E)),
                ),
              ),
            ),
          ),

          // ─── Role Filter Chips ──────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _roleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _roleFilters[index];
                final isActive = _selectedRole == filter['key'];
                return FilterChip(
                  label: Text(filter['label']!),
                  selected: isActive,
                  onSelected: (_) => setState(() => _selectedRole = filter['key']!),
                  backgroundColor: const Color(0xFF1E293B),
                  selectedColor: const Color(0xFF22C55E).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isActive ? const Color(0xFF22C55E) : Colors.grey[400],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isActive ? const Color(0xFF22C55E) : const Color(0xFF334155),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── User List ──────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text('Tidak ada user ditemukan', style: TextStyle(color: Colors.grey[500])),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _UserAdminCard(
                            user: _filteredUsers[index],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/admin/users/detail',
                                arguments: _filteredUsers[index].id,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────

class _UserAdminCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onTap;

  const _UserAdminCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            // Avatar inisial
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor(user.role).withOpacity(0.2),
              child: Text(
                user.initials,
                style: TextStyle(
                  color: _roleColor(user.role),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _RoleBadge(role: user.roleLabel, color: _roleColor(user.role)),
                      const SizedBox(width: 6),
                      _StatusBadge(status: user.status),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.transactionCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'transaksi',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 14),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'koperasi':
        return const Color(0xFF22C55E);
      case 'konsumen':
        return const Color(0xFF3B82F6);
      case 'hotel_restoran':
        return const Color(0xFFF59E0B);
      case 'eksportir':
        return const Color(0xFF8B5CF6);
      case 'admin':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;
  const _RoleBadge({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(role, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'active'
        ? const Color(0xFF22C55E)
        : status == 'suspended'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final label = status == 'active' ? 'Aktif' : status == 'suspended' ? 'Suspended' : 'Banned';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
