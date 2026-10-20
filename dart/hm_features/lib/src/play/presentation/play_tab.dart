import 'package:flutter/material.dart';
import 'package:hm_design/hm_design.dart';

/// Play (§10.5): games arrive in Phase 3.
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) => const HmComingSoon(
    title: 'Games are coming soon',
    body: 'Study first. Games for learning will open in a later update.',
  );
}
