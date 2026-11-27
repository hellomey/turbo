import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

/// The tab shell (blueprint §10.5; four tabs since BOLT-0117). Signed in, it starts the BOLT-0016 sync triggers and shows the outbox
/// note ("Will sync when online" / "Couldn't save", §39).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Four tabs, as in the approved design (BOLT-0117): Today, Map, Play, Me.
  static const tabs = [
    HmNavItem(
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny_rounded,
    ),
    HmNavItem(
      label: 'Map',
      icon: Icons.local_fire_department_outlined,
      selectedIcon: Icons.local_fire_department_rounded,
    ),
    HmNavItem(
      label: 'Play',
      icon: Icons.casino_outlined,
      selectedIcon: Icons.casino_rounded,
    ),
    HmNavItem(
      label: 'Me',
      icon: Icons.person_outline_rounded,
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
