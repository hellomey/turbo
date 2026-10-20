import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../sign_in/application/desk_sign_in_controller.dart';

/// Plain-English role names (§16).
const deskRoleLabels = {
  'CREATOR': 'Creator',
  'REVIEWER': 'Reviewer',
  'PUBLISHER': 'Publisher partner',
  'INSTITUTION_ADMIN': 'Institution admin',
  'SUPPORT_AGENT': 'Support agent',
  'MODERATOR': 'Moderator',
  'OPS': 'Ops',
  'ADMIN': 'Admin',
};

/// The eight Desk areas (§15). Built in Phase 4; the server decides access.
const deskAreas = [
  ('Support Desk', 'Reply to help tickets.', Icons.support_agent),
  ('Moderation Desk', 'Act on reports.', Icons.shield_outlined),
  ('Review Desk', 'Check questions and lessons.', Icons.fact_check_outlined),
  ('Ops Desk', 'Exam data, alerts and events.', Icons.event_note_outlined),
  (
    'Admin Desk',
    'Prices, payouts, roles and refunds.',
    Icons.admin_panel_settings_outlined,
  ),
  ('Institution Desk', 'Students, seats and mocks.', Icons.school_outlined),
  ('Studio', 'Create and upload content.', Icons.edit_note_outlined),
  (
    'Partner Desk',
    'Catalogue, stock and orders.',
    Icons.local_shipping_outlined,
  ),
];

class DeskHome extends ConsumerWidget {
  const DeskHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deskSignInProvider);
    final me = state.me;
    final text = Theme.of(context).textTheme;
    final roles = [
      for (final r in me?.roles ?? const <String>[])
        if (deskRoleLabels.containsKey(r)) deskRoleLabels[r]!,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('HeyMey Desk'),
        actions: [
          TextButton(
            key: const Key('desk-logout'),
            onPressed: ref.read(deskSignInProvider.notifier).logout,
            child: const Text('Log out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Signed in as ${me?.email ?? ''}', style: text.bodyLarge),
          const SizedBox(height: 4),
          Text(
            roles.isEmpty
                ? 'Your role: none'
                : 'Your role: ${roles.join(', ')}',
            key: const Key('desk-roles'),
            style: text.titleMedium,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, c) {
              final columns = (c.maxWidth / 280).floor().clamp(1, 4);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  for (final (title, body, icon) in deskAreas)
                    HmCard(
                      semanticLabel: '$title. Coming in a later update.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon),
                          const SizedBox(height: 8),
                          Text(title, style: text.titleMedium),
                          Text(body, style: text.bodySmall),
                          const Spacer(),
                          Text('Coming soon', style: text.labelMedium),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
