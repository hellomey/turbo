// Ops Desk: review of official-page changes before any Exam Alert reaches users.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

/// Exam codes the Desk can attach an alert to (seeded catalogue).
const deskExamCodes = [
  'tnpsc-group-4',
  'tnpsc-group-2',
  'tnpsc-group-2a',
  'ssc-chsl',
  'ssc-mts',
];

/// Alert kinds (contract `ExamAlert.kind`), with plain labels.
const deskAlertKinds = {
  'notification': 'New notification',
  'date_change': 'Date change',
  'admit_card': 'Admit card',
  'result': 'Result',
  'answer_key': 'Answer key',
  'other': 'Other',
};

/// Status tab currently shown.
class ExamChangeStatus extends Notifier<String> {
  @override
  String build() => 'pending';
  void set(String status) => state = status;
}

final examChangeStatusProvider = NotifierProvider<ExamChangeStatus, String>(
  ExamChangeStatus.new,
);

/// One page of exam changes for the chosen status. Refreshed after every approve or reject.
final examChangesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final status = ref.watch(examChangeStatusProvider);
      final page = await ref
          .watch(hmApiProvider)
          .deskExamChanges(status: status);
      return [
        for (final item in (page['items'] as List? ?? const []))
          (item as Map).cast<String, dynamic>(),
      ];
    });

/// Ops Desk: official-page changes found by the watcher wait here. Nothing reaches users until staff approve it
/// (CLAUDE.md §6). Approving publishes one Exam Alert; rejecting publishes nothing.
class ExamChangesScreen extends ConsumerWidget {
  const ExamChangesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(examChangeStatusProvider);
    final changes = ref.watch(examChangesProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ops Desk: exam changes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Changes the watcher found on official pages. Check each one against the official site before you approve it.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pending', label: Text('Waiting')),
              ButtonSegment(value: 'approved', label: Text('Approved')),
              ButtonSegment(value: 'rejected', label: Text('Rejected')),
            ],
            selected: {status},
            onSelectionChanged: (s) =>
                ref.read(examChangeStatusProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 16),
          changes.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _Message(
              e is HmApiException ? e.message : 'Could not load changes.',
              onRetry: () => ref.invalidate(examChangesProvider),
            ),
            data: (items) => items.isEmpty
                ? const _Message('Nothing here right now.')
                : Column(
                    children: [
                      for (final c in items)
                        _ChangeCard(change: c, pending: status == 'pending'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.onRetry});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      children: [
        Text(text, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ],
    ),
  );
}

class _ChangeCard extends ConsumerWidget {
  const _ChangeCard({required this.change, required this.pending});
  final Map<String, dynamic> change;
  final bool pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final title = change['title'] as String? ?? 'Untitled change';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleMedium),
            const SizedBox(height: 4),
            SelectableText(
              change['watchUrl'] as String? ?? '',
              style: text.bodySmall,
            ),
            if (change['diffSummary'] != null) ...[
              const SizedBox(height: 8),
              Text(change['diffSummary'] as String),
            ],
            const SizedBox(height: 4),
            Text('Found ${change['receivedAt'] ?? ''}', style: text.labelSmall),
            if (pending) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => _approve(context, ref),
                    child: const Text('Approve and publish'),
                  ),
                  OutlinedButton(
                    onPressed: () => _reject(context, ref),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final body = await showDialog<Map<String, Object>>(
      context: context,
      builder: (_) => _ApproveDialog(change: change),
    );
    if (body == null || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref
          .read(hmApiProvider)
          .deskApproveExamChange(change['id'] as String, body),
      'Approved. The alert is published.',
    );
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref
          .read(hmApiProvider)
          .deskRejectExamChange(change['id'] as String, reason),
      'Rejected. Nothing was published.',
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<Object?> Function() action,
    String done,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } on HmApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    ref.invalidate(examChangesProvider);
  }
}

class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog({required this.change});
  final Map<String, dynamic> change;

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  final _form = GlobalKey<FormState>();
  late String _exam = deskExamCodes.contains(widget.change['examCode'])
      ? widget.change['examCode'] as String
      : deskExamCodes.first;
  String _kind = 'notification';
  late final _title = TextEditingController(
    text: widget.change['title'] as String? ?? '',
  );
  final _summary = TextEditingController();
  late final _url = TextEditingController(
    text: widget.change['watchUrl'] as String? ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _url.dispose();
    super.dispose();
  }

  String? _len(String? v, int min, int max) {
    final t = v?.trim() ?? '';
    if (t.length < min) return 'At least $min characters.';
    if (t.length > max) return 'At most $max characters.';
    return null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Publish an Exam Alert'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _exam,
                decoration: const InputDecoration(labelText: 'Exam'),
                items: [
                  for (final c in deskExamCodes)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _exam = v ?? _exam),
              ),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Kind'),
                items: [
                  for (final e in deskAlertKinds.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _kind = v ?? _kind),
              ),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title (what users see)',
                ),
                validator: (v) => _len(v, 5, 120),
              ),
              TextFormField(
                controller: _summary,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Summary in plain English',
                ),
                validator: (v) => _len(v, 5, 500),
              ),
              TextFormField(
                controller: _url,
                decoration: const InputDecoration(labelText: 'Official link'),
                validator: (v) {
                  final u = Uri.tryParse(v?.trim() ?? '');
                  return u != null && u.hasScheme && u.host.isNotEmpty
                      ? null
                      : 'Paste the official page link.';
                },
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_form.currentState?.validate() ?? false)) return;
          Navigator.pop(context, <String, Object>{
            'examCode': _exam,
            'kind': _kind,
            'title': _title.text.trim(),
            'summary': _summary.text.trim(),
            'officialUrl': _url.text.trim(),
          });
        },
        child: const Text('Publish'),
      ),
    ],
  );
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reject this change'),
    content: TextField(
      controller: _reason,
      decoration: InputDecoration(
        labelText: 'Why? (kept in the audit log)',
        errorText: _error,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final r = _reason.text.trim();
          if (r.length < 3) {
            setState(() => _error = 'Write a short reason.');
            return;
          }
          Navigator.pop(context, r);
        },
        child: const Text('Reject'),
      ),
    ],
  );
}
