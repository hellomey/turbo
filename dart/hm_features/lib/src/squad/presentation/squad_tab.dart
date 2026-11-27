import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// Squad (§10.5, design/ui/27): squads arrive in Phase 3. Three lamps together, a "Coming soon" tag and a way back.
class SquadTab extends StatelessWidget {
  const SquadTab({super.key, this.onBackToToday});

  /// Leaves for Today. Hidden when null.
  final VoidCallback? onBackToToday;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(HmSpace.lg),
            child: Column(
              children: [
                const Spacer(),
                const HmMey(HmPic.meySquad, size: 300),
                const SizedBox(height: HmSpace.lg),
                HmTag(
                  label: 'Coming soon',
                  color: p.primary,
                  textColor: p.onPrimary,
                ),
                const SizedBox(height: HmSpace.md),
                Semantics(
                  header: true,
                  child: Text(
                    'Study with friends',
                    textAlign: TextAlign.center,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: HmSpace.sm),
                Text(
                  "Squads are being built. We'll tell you when they're ready.",
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: p.textMuted),
                ),
                const Spacer(flex: 2),
                if (onBackToToday != null)
                  HmSecondaryButton(
                    key: const Key('squad-back-today'),
                    label: 'Back to Today',
                    expand: true,
                    onPressed: onBackToToday,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
