import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../router/route_names.dart';

class KonsumenShell extends StatelessWidget {
  final Widget child;
  const KonsumenShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.consult)) return 1;
    if (location.startsWith(RouteNames.auction)) return 2;
    if (location.startsWith(RouteNames.analytics)) return 3;
    return 0; // home default
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: context.go(RouteNames.home); break;
            case 1: context.go(RouteNames.consult); break;
            case 2: context.go(RouteNames.auction); break;
            case 3: context.go(RouteNames.analytics); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Pasar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Lelang'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analitik'),
        ],
      ),
    );
  }
}
