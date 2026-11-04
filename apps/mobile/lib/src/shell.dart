import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

/// The five tabs (blueprint §10.5). Signed in, it starts the BOLT-0016 sync triggers and shows the outbox
/// note ("Will sync when online" / "Couldn't save", §39).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const tabs = [
    HmNavItem(
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny_rounded,
    ),
    HmNavItem(
      label: 'Study Map',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    HmNavItem(
      label: 'Play',
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports_rounded,
    ),
    HmNavItem(
      label: 'Squad',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    HmNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(syncStatusProvider.notifier).start();
      // Push token (BOLT-0018): a no-op until Firebase is set up (U-notifications, D-…-33).
      unawaited(ref.read(pushRegistrarProvider).registerIfAvailable());
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SyncStatusBar(),
            Expanded(child: shell),
          ],
        ),
      ),
      bottomNavigationBar: HmBottomNav(
        items: AppShell.tabs,
        currentIndex: shell.currentIndex,
        onSelect: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
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
