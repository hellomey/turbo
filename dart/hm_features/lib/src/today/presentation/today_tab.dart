import 'package:flutter/material.dart';
import 'package:hm_design/hm_design.dart';

/// Today (§10.5). Phase 1: one card that leads to the Study Map. Check-in, Today Card, relight queue
/// and games arrive in Phase 2/3.
class TodayTab extends StatelessWidget {
  const TodayTab({super.key, required this.onOpenStudyMap});

  final VoidCallback onOpenStudyMap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text('Today', style: text.headlineSmall),
        ),
        const SizedBox(height: 16),
        HmCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExcludeSemantics(child: Lamp(label: 'Lamp', size: 40)),
              const SizedBox(height: 8),
              Text('Start with your Study Map', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                'See every subject of your exam. Open a topic and read its lesson.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: 16),
              HmPrimaryButton(
                key: const Key('today-open-map'),
                label: 'Open Study Map',
                onPressed: onOpenStudyMap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
