import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/profile_controller.dart';

/// Profile (§10.5). Phase 1: who you are, Calm Mode, log out, log out of all devices, delete account.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({
    super.key,
    this.onOpenReadiness,
    this.onOpenReports,
    this.onOpenAlerts,
    this.onOpenAlertSettings,
  });

  /// Profile links (§10.5 Profile: Readiness Meter, reports, Exam Alerts, settings). Hidden when null.
  final VoidCallback? onOpenReadiness;
  final VoidCallback? onOpenReports;
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenAlertSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final text = Theme.of(context).textTheme;
    return me.when(
      loading: () => const HmSkeletonList(label: 'Loading your profile'),
      error: (e, _) => HmErrorView(
        message: messageOf(e),
        onRetry: () => ref.invalidate(meProvider),
      ),
      data: (user) => ListView(
        padding: const EdgeInsets.fromLTRB(
          HmSpace.lg,
          HmSpace.lg,
          HmSpace.lg,
          HmSpace.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Profile', style: text.headlineMedium),
          ),
          const SizedBox(height: HmSpace.lg),
          HmCard(
            child: Row(
              children: [
                ExcludeSemantics(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: context.hm.primary,
                    foregroundColor: context.hm.onPrimary,
                    child: Text(
                      (user.nickname ?? user.email).isEmpty
                          ? '?'
                          : (user.nickname ?? user.email)[0].toUpperCase(),
                      style: text.titleLarge?.copyWith(
                        color: context.hm.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: HmSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.nickname != null)
                        Text(user.nickname!, style: text.titleMedium),
                      Text(
                        user.email,
                        key: const Key('profile-email'),
                        style: text.bodyLarge?.copyWith(
                          color: context.hm.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const HmSectionTitle('Settings', icon: Icons.tune_rounded),
          SwitchListTile(
            key: const Key('calm-mode'),
            title: const Text('Calm Mode'),
            subtitle: const Text(
              'Simpler screens and fewer games. Same account, same progress.',
            ),
            value: user.calmMode,
            onChanged: (on) async {
              try {
                await ref.read(meProvider.notifier).setCalmMode(on);
              } on Exception catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(messageOf(e))));
                }
              }
            },
          ),
          for (final (key, label, icon, onTap) in [
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
            (
              'profile-alerts',
              'Exam Alerts',
              Icons.campaign_outlined,
              onOpenAlerts,
            ),
            (
              'profile-alert-settings',
              'Alert settings',
              Icons.notifications_outlined,
              onOpenAlertSettings,
            ),
          ])
            if (onTap != null)
              ListTile(
                key: Key(key),
                leading: HmIconBadge(icon: icon, size: 40),
                title: Text(label, style: text.titleSmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: onTap,
              ),
          const Divider(height: 32),
          const DataChoicesSection(),
          const Divider(height: 32),
          const LegalLinks(),
          const SizedBox(height: 16),
          HmSecondaryButton(
            key: const Key('logout'),
            label: 'Log out',
            onPressed: () => ref.read(meProvider.notifier).logout(),
          ),
          const SizedBox(height: 8),
          HmSecondaryButton(
            key: const Key('logout-all'),
            label: 'Log out of all devices',
            onPressed: () =>
                ref.read(meProvider.notifier).logout(allDevices: true),
          ),
          const SizedBox(height: 24),
          TextButton(
            key: const Key('delete-account'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(48, 48),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DeleteAccountScreen(email: user.email),
              ),
            ),
            child: const Text('Delete account'),
          ),
        ],
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
