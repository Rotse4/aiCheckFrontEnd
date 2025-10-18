import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../payments_service.dart';

class AppShell extends StatelessWidget {
  final String title;
  final int selectedIndex; // 0: Dashboard, 1: History
  final Widget body;

  const AppShell({super.key, required this.title, required this.selectedIndex, required this.body});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/history');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/purchase');
        break;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {bool showMenuButton = false}) {
    return AppBar(
      title: Text(title),
      leading: showMenuButton ? Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ) : null,
      actions: [
        // Wallet balance chip
        FutureBuilder<int>(
          future: PaymentsService.instance.fetchWalletBalance(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(width: 1, height: 1);
            }
            if (snap.hasError) {
              return const SizedBox();
            }
            final bal = snap.data ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.account_balance_wallet, size: 18),
                label: Text('$bal'),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          tooltip: 'Buy Credits',
          onPressed: () => Navigator.of(context).pushNamed('/purchase'),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Login / Logout',
          onPressed: () async {
            final token = await AuthService.instance.getToken();
            if (token != null && token.isNotEmpty) {
              await AuthService.instance.clearAuth();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out')),
                );
                Navigator.of(context).pushReplacementNamed('/login');
              }
            } else {
              if (context.mounted) {
                Navigator.of(context).pushNamed('/login');
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('AI Essay Analyzer', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Navigation', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Analyze'),
              selected: selectedIndex == 0,
              onTap: () => _navigate(context, 0),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              selected: selectedIndex == 1,
              onTap: () => _navigate(context, 1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Buy Credits'),
              selected: selectedIndex == 2,
              onTap: () => _navigate(context, 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    if (!isWide) {
      // Mobile / narrow: use Drawer for navigation
      return Scaffold(
        appBar: _buildAppBar(context, showMenuButton: true),
        drawer: _buildDrawer(context),
        body: body,
      );
    }

    // Wide / desktop: use NavigationRail
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analyze'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Buy'),
              ),
            ],
            onDestinationSelected: (i) => _navigate(context, i),
            // When extended is true, labelType must be null/none per Flutter's assertion.
            extended: width >= 1400,
            labelType: (width >= 1400)
                ? NavigationRailLabelType.none
                : (width >= 1200 ? NavigationRailLabelType.all : NavigationRailLabelType.selected),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}