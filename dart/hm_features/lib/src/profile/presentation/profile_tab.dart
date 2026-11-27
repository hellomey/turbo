import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../progress/application/progress_controller.dart';
import '../../study_map/application/study_providers.dart';
import '../application/profile_controller.dart';
import 'name_screen.dart';

/// Profile (§10.5). Phase 1: who you are, Calm Mode, log out, log out of all devices, delete account.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({
    super.key,
    this.onOpenReadiness,
    this.onOpenReports,
    this.onOpenAlerts,
    this.onOpenAlertSettings,
    this.onReplayStory,
    this.onOpenSticker,
    this.onOpenLeaderboard,
  });

  /// Profile links (§10.5 Profile: Readiness Meter, reports, Exam Alerts, settings). Hidden when null.
  final VoidCallback? onOpenReadiness;
  final VoidCallback? onOpenReports;
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenAlertSettings;

  /// Replays "The Lamplighter" story (BOLT-0111). Hidden when null.
  final VoidCallback? onReplayStory;

  /// Opens "Collect your sticker". Hidden when null.
  final VoidCallback? onOpenSticker;

  /// BOLT-0113: shows Trophies and the weekly leaderboard link when set.
  final VoidCallback? onOpenLeaderboard;

  /// Profile links that have somewhere to go (a null callback hides its tile).
  List<(String, String, IconData, VoidCallback)> get _links => [
    (
      'profile-readiness',
      'Readiness',
      Icons.insights_outlined,
      onOpenReadiness,
    ),
    (
      'profile-reports',
      'Sunday Reports',
      Icons.event_note_outlined,
      onOpenReports,
    ),
    ('profile-alerts', 'Exam Alerts', Icons.campaign_outlined, onOpenAlerts),
    (
      'profile-alert-settings',
      'Alert settings',
      Icons.notifications_outlined,
      onOpenAlertSettings,
    ),
    (
      'profile-replay-story',
      'Replay the story',
      Icons.auto_stories_outlined,
      onReplayStory,
    ),
    (
      'profile-sticker',
      'Your sticker code',
      Icons.confirmation_number_outlined,
      onOpenSticker,
    ),
  ].where((l) => l.$4 != null).map((l) => (l.$1, l.$2, l.$3, l.$4!)).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final progress = ref.watch(myProgressProvider).value;
    final exam = ref.watch(mainExamCodeProvider).value;
    final map = exam == null ? null : ref.watch(studyMapProvider(exam)).value;
    final lit = map?.subjects
        .expand((s) => s.topics)
        .where((t) => t.lamp.lit)
        .length;
    return me.when(
      loading: () => const HmSkeletonList(label: 'Loading your profile'),
      error: (e, _) => HmErrorView(
        message: messageOf(e),
        onRetry: () => ref.invalidate(meProvider),
      ),
      data: (user) {
        final name = (user.nickname ?? '').trim().isNotEmpty
            ? user.nickname!.trim()
            : (user.isGuest ? 'Guest' : 'Add your name');
        final examName = switch (exam) {
          'tnpsc-group-4' => 'Group 4',
          'tnpsc-group-2' || 'tnpsc-group-2a' => 'Group 2/2A',
          'tnpsc-group-1' => 'Group 1',
          _ => null,
        };
        final header = HmCard(
          key: const Key('profile-header'),
          child: Row(
            children: [
              HmAvatar(
                id: ref.watch(avatarProvider).value,
                name: name,
                size: 84,
              ),
              const SizedBox(width: HmSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        name,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      [
                        ?examName,
                        if (progress != null) 'Level ${progress.level}',
                      ].join(' · '),
                      style: text.bodyLarge,
                    ),
                    if (user.email case final email?)
                      Text(
                        email,
                        key: const Key('profile-email'),
                        style: text.bodySmall?.copyWith(color: p.textMuted),
                      ),
                    if (progress != null) ...[
                      const SizedBox(height: HmSpace.sm),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${progress.xp}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' / ${progress.nextLevelXp} XP to Level ${progress.level + 1}',
                            ),
                          ],
                        ),
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: HmSpace.xs),
                      HmProgressBar(
                        value: progress.levelFraction,
                        semanticLabel:
                            '${(progress.levelFraction * 100).round()}% of the way to level ${progress.level + 1}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );

        final trophies = HmCard(
          key: const Key('profile-trophies'),
          onTap: onOpenLeaderboard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trophies',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: HmSpace.sm),
              if (progress == null || progress.trophies.isEmpty)
                Text(
                  'Light your first lamp to earn your first trophy.',
                  style: text.bodyMedium,
                )
              else
                Wrap(
                  spacing: HmSpace.sm,
                  runSpacing: HmSpace.sm,
                  children: [
                    for (final (i, t) in progress.trophies.take(3).indexed)
                      _TrophyBadge(
                        title: t.title,
                        pic: const [
                          HmPic.icTrophy,
                          HmPic.icShieldCheck,
                          HmPic.icTrophyGold,
                        ][i % 3],
                        tint: const [
                          HmTint.coral,
                          HmTint.mint,
                          HmTint.amber,
                        ][i % 3],
                      ),
                    if (progress.trophies.length > 3)
                      _MoreBadge(count: progress.trophies.length - 3),
                  ],
                ),
            ],
          ),
        );
        final stats = Column(
          children: [
            _StatTile(
              key: const Key('profile-lamps'),
              pic: HmPic.icDiya,
              value: lit == null ? '…' : '$lit',
              label: lit == 1 ? 'Lamp lit' : 'Lamps lit',
              color: HmTint.amber,
            ),
            const SizedBox(height: HmSpace.md),
            _StatTile(
              key: const Key('profile-points'),
              pic: HmPic.coin,
              value: progress == null ? '…' : '${progress.points}',
              label: 'Points',
              color: HmTint.sky,
            ),
          ],
        );

        final menu = HmCard(
          padding: const EdgeInsets.symmetric(vertical: HmSpace.sm),
          child: Column(
            children: [
              _MenuRow(
                key: const Key('profile-edit-name'),
                icon: Icons.face_rounded,
                label: 'Name and avatar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const NameScreen()),
                ),
              ),
              for (final (key, label, icon, onTap) in _links)
                _MenuRow(key: Key(key), icon: icon, label: label, onTap: onTap),
              if (onOpenLeaderboard != null)
                _MenuRow(
                  key: const Key('profile-open-leaderboard'),
                  icon: Icons.leaderboard_outlined,
                  label: 'Weekly leaderboard',
                  onTap: onOpenLeaderboard!,
                ),
              _MenuRow(
                key: const Key('logout'),
                icon: Icons.logout_rounded,
                label: 'Sign out',
                danger: true,
                onTap: () => ref.read(meProvider.notifier).logout(),
              ),
            ],
          ),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            HmSpace.lg,
            HmSpace.lg,
            HmSpace.lg,
            120,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HmEnter(child: header),
                    if (user.isGuest) ...[
                      const SizedBox(height: HmSpace.md),
                      HmCard(
                        color: HmTint.amber,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save your progress',
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: HmSpace.sm),
                            Text(
                              'You are trying HeyMey as a guest. Sign in with your email to keep your progress. '
                              'A guest account that is not saved is deleted after a while.',
                              style: text.bodyMedium,
                            ),
                            const SizedBox(height: HmSpace.md),
                            HmPrimaryButton(
                              key: const Key('profile-save-progress'),
                              label: 'Save your progress',
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SaveProgressScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: HmSpace.md),
                    HmEnter(
                      index: 1,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: trophies),
                            const SizedBox(width: HmSpace.md),
                            Expanded(child: stats),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: HmSpace.md),
                    HmEnter(index: 2, child: menu),
                    const SizedBox(height: HmSpace.md),
                    HmCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HmSpace.sm,
                      ),
                      child: SwitchListTile(
                        key: const Key('calm-mode'),
                        title: const Text(
                          'Calm Mode',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'Simpler screens and fewer games. Same account, same progress.',
                        ),
                        activeTrackColor: p.primary,
                        activeThumbColor: Colors.white,
                        value: user.calmMode,
                        onChanged: (on) async {
                          try {
                            await ref.read(meProvider.notifier).setCalmMode(on);
                          } on Exception catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(messageOf(e))),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: HmSpace.md),
                    const HmCard(child: DataChoicesSection()),
                    const SizedBox(height: HmSpace.md),
                    const LegalLinks(),
                    const SizedBox(height: HmSpace.md),
                    HmSecondaryButton(
                      key: const Key('logout-all'),
                      label: 'Sign out of all devices',
                      onPressed: () => ref
                          .read(meProvider.notifier)
                          .logout(allDevices: true),
                    ),
                    const SizedBox(height: HmSpace.sm),
                    // A guest has no email to confirm deletion with; unsaved guest accounts are deleted automatically.
                    if (user.email case final email?)
                      TextButton(
                        key: const Key('delete-account'),
                        style: TextButton.styleFrom(
                          foregroundColor: p.error,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DeleteAccountScreen(email: email),
                          ),
                        ),
                        child: const Text('Delete account'),
                      ),
                    const SizedBox(height: HmSpace.md),
                    Center(
                      child: Text(
                        "HeyMey is still being built. Thanks for trying it early.",
                        style: text.bodySmall?.copyWith(color: p.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  const _TrophyBadge({
    required this.title,
    required this.pic,
    required this.tint,
  });

  final String title;
  final HmPic pic;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(HmRadius.md),
            ),
            child: HmPicture(pic),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _MoreBadge extends StatelessWidget {
  const _MoreBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.hm.surface,
        borderRadius: BorderRadius.circular(HmRadius.md),
        border: Border.all(color: context.hm.outline, width: 1.5),
      ),
      child: Text(
        '+$count\nmore',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.pic,
    required this.value,
    required this.label,
    required this.color,
  });

  final HmPic pic;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HmCard(
      color: color,
      semanticLabel: '$value $label',
      child: Row(
        children: [
          HmPicture(pic, width: 48, height: 48),
          const SizedBox(width: HmSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(label, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final color = danger ? p.error : p.text;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: danger ? p.error : p.textMuted),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: danger ? p.error : p.textMuted,
      ),
    );
  }
}

/// Explains the 7-day grace period in simple English, then confirms with an email code (§38 step 7).
class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key, required this.email});

  final String email;

  static const explanation =
      'When you delete your account, we wait 7 days first. '
      'If you sign in again within 7 days, your account comes back and nothing is lost. '
      'After 7 days, we erase your personal data for good. '
      'We keep payment records only because the law asks us to.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deleteAccountProvider);
    final c = ref.read(deleteAccountProvider.notifier);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: switch (state.step) {
          DeleteStep.explain => [
            Text(explanation, style: text.bodyLarge),
            const SizedBox(height: 16),
            Text(
              'We will send a code to $email to confirm.',
              style: text.bodyLarge,
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            HmPrimaryButton(
              key: const Key('delete-send-code'),
              label: 'Send code',
              busy: state.busy,
              onPressed: () => c.sendCode(email),
            ),
            const SizedBox(height: 8),
            HmSecondaryButton(
              label: 'Not now',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          DeleteStep.code => [
            Text('Enter the code we sent to $email.', style: text.bodyLarge),
            const SizedBox(height: 16),
            HmCodeEntry(
              onSubmit: c.confirm,
              onResend: () => c.sendCode(email),
              resendAfter: Duration(seconds: state.resendAfterSeconds),
              errorText: state.error,
              busy: state.busy,
              submitLabel: 'Delete my account',
            ),
          ],
          DeleteStep.scheduled => [
            Text(
              'Your account will be deleted on ${_date(state.scheduledFor!)}. '
              'Sign in before then if you change your mind.',
              key: const Key('delete-scheduled'),
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            HmPrimaryButton(
              label: 'Done',
              onPressed: () {
                c.finish();
                Navigator.of(context).maybePop();
              },
            ),
          ],
        },
      ),
    );
  }

  static String _date(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final ist = d.toUtc().add(const Duration(hours: 5, minutes: 30));
    return '${ist.day} ${months[ist.month - 1]} ${ist.year}';
  }
}

/// "Your data choices": each OPTIONAL purpose as a switch, saved at once.
class DataChoicesSection extends ConsumerWidget {
  const DataChoicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choices = ref.watch(dataChoicesProvider);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('Your data choices', style: text.titleMedium),
        ),
        const SizedBox(height: 4),
        Text(
          'Switch these on or off any time. The app works either way.',
          style: text.bodyMedium,
        ),
        choices.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: HmLoadingView(label: 'Loading your data choices'),
          ),
          error: (e, _) => HmErrorView(
            message: messageOf(e),
            onRetry: () => ref.invalidate(dataChoicesProvider),
          ),
          data: (c) => Column(
            children: [
              for (final p in c.optional)
                SwitchListTile(
                  key: Key('data-choice-${p.purpose}'),
                  title: Text(p.title),
                  subtitle: Text(p.description),
                  value: c.granted(p.purpose),
                  onChanged: (on) async {
                    try {
                      await ref
                          .read(dataChoicesProvider.notifier)
                          .setOptional(p.purpose, on);
                    } on Exception catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(messageOf(e))));
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Privacy Policy, Terms of Use and the grievance contact.
class LegalLinks extends ConsumerWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opener = ref.read(linkOpenerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          key: const Key('privacy-link'),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => opener.open(privacyUrl),
          child: const Text('Privacy Policy'),
        ),
        TextButton(
          key: const Key('terms-link'),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => opener.open(termsUrl),
          child: const Text('Terms of Use'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: SelectableText('Questions or complaints: $grievanceEmail'),
        ),
      ],
    );
  }
}

/// Guest mode "Save your progress": email, then the 6-digit code. Same account when the email is new;
/// when the email already has an account, the app says plainly that the guest progress was not moved.
class SaveProgressScreen extends ConsumerStatefulWidget {
  const SaveProgressScreen({super.key});

  @override
  ConsumerState<SaveProgressScreen> createState() => _SaveProgressScreenState();
}

class _SaveProgressScreenState extends ConsumerState<SaveProgressScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saveProgressProvider);
    final c = ref.read(saveProgressProvider.notifier);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Save your progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: switch (state.step) {
          SaveProgressStep.email => [
            Text(
              'We will send a 6-digit code to your email. You do not need a password.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('save-progress-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.mail_outline_rounded),
                errorText: state.error,
              ),
              onSubmitted: c.sendCode,
            ),
            const SizedBox(height: 16),
            HmPrimaryButton(
              key: const Key('save-progress-send'),
              label: 'Send code',
              busy: state.busy,
              onPressed: () => c.sendCode(_email.text),
            ),
          ],
          SaveProgressStep.code => [
            Text(
              'Enter the code we sent to ${state.email}.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 16),
            HmCodeEntry(
              onSubmit: c.confirm,
              onResend: () => c.sendCode(state.email),
              resendAfter: Duration(seconds: state.resendAfterSeconds),
              errorText: state.error,
              busy: state.busy,
            ),
          ],
          SaveProgressStep.done => [
            Text(
              state.merged
                  ? 'Your progress is saved. Sign in with ${state.email} on any phone to continue.'
                  : '${state.email} already has a HeyMey account, so you are now signed in to it. '
                        'Your guest progress was not moved into that account.',
              key: const Key('save-progress-result'),
              style: text.bodyLarge,
            ),
            const SizedBox(height: 16),
            HmPrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        },
      ),
    );
  }
}
