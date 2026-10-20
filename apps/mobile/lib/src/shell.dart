import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hm_design/hm_design.dart';

/// The five tabs (blueprint §10.5).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const tabs = [
    (label: 'Today', icon: Icons.wb_sunny_outlined),
    (label: 'Study Map', icon: Icons.map_outlined),
    (label: 'Play', icon: Icons.sports_esports_outlined),
    (label: 'Squad', icon: Icons.groups_outlined),
    (label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: shell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              label: t.label,
              tooltip: t.label,
            ),
        ],
      ),
    );
  }
}

/// Shown when the server needs a newer app (X-Min-App-Version, §37).
class UpdateRequiredView extends StatelessWidget {
  const UpdateRequiredView({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: HmErrorView(message: 'Please update HeyMey to continue.'),
  );
}
