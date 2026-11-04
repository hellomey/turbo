import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../practice/domain/practice_models.dart';
import '../../practice/domain/study_rules.dart';
import '../../practice/presentation/study_widgets.dart';
import '../application/pyq_providers.dart';

/// PYQ Vault (§19.4 Q31, §11, INT-002-S09): filters by year, subject, difficulty. Older years are Pro and
/// marked before a tap (§19.9 Q82, D-2026-10-22-20).
class PyqVaultScreen extends ConsumerWidget {
  const PyqVaultScreen({
    super.key,
    required this.examCode,
    required this.onPractise,
  });

  final String examCode;
  final ValueChanged<PyqFilter> onPractise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facets = ref.watch(pyqFacetsProvider(examCode));
    final filter = ref.watch(pyqFilterProvider);
    final page = ref.watch(pyqPageProvider((examCode, filter)));
    return Scaffold(
      appBar: AppBar(title: const Text('PYQ Vault')),
      body: facets.when(
        loading: () => const HmSkeletonList(label: 'Loading the PYQ Vault'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(pyqFacetsProvider(examCode)),
        ),
        data: (f) => PyqVaultBody(
          facets: f,
          filter: filter,
          page: page.value,
          loadingPage: page.isLoading,
          pageError: page.hasError ? messageOf(page.error!) : null,
          onFilter: ref.read(pyqFilterProvider.notifier).set,
          onPractise: () => onPractise(filter),
        ),
      ),
    );
  }
}

class PyqVaultBody extends StatelessWidget {
  const PyqVaultBody({
    super.key,
    required this.facets,
    required this.filter,
    required this.onFilter,
    required this.onPractise,
    this.page,
    this.loadingPage = false,
    this.pageError,
  });

  final PyqFacetsView facets;
  final PyqFilter filter;
  final PyqPageView? page;
  final bool loadingPage;
  final String? pageError;
  final ValueChanged<PyqFilter> onFilter;
  final VoidCallback onPractise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final yearLocked = facets.years.any(
      (y) => y.year == filter.year && y.locked,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(header: true, child: Text('Year', style: text.titleSmall)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All years'),
              selected: filter.year == null,
              onSelected: (_) => onFilter(filter.copyWith(year: () => null)),
            ),
            for (final y in facets.years)
              ChoiceChip(
                key: Key('pyq-year-${y.year}'),
                avatar: y.locked
                    ? const Icon(Icons.lock_outline, size: 16)
                    : null,
                label: Text(y.locked ? '${y.year} · Pro' : '${y.year}'),
                tooltip: y.locked ? '${y.year}, Pro' : '${y.year}, Free',
                selected: filter.year == y.year,
                onSelected: (_) =>
                    onFilter(filter.copyWith(year: () => y.year)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(header: true, child: Text('Subject', style: text.titleSmall)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All subjects'),
              selected: filter.subjectCode == null,
              onSelected: (_) =>
                  onFilter(filter.copyWith(subjectCode: () => null)),
            ),
            for (final s in facets.subjects)
              ChoiceChip(
                label: Text(s.name),
                selected: filter.subjectCode == s.code,
                onSelected: (_) =>
                    onFilter(filter.copyWith(subjectCode: () => s.code)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text('Difficulty', style: text.titleSmall),
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Any'),
              selected: filter.difficulty == null,
              onSelected: (_) =>
                  onFilter(filter.copyWith(difficulty: () => null)),
            ),
            for (var d = 1; d <= 5; d++)
              ChoiceChip(
                label: Text('$d'),
                tooltip: 'Difficulty $d of 5',
                selected: filter.difficulty == d,
                onSelected: (_) =>
                    onFilter(filter.copyWith(difficulty: () => d)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (yearLocked)
          const HmCard(
            child: Row(
              children: [
                TierChip(pro: true),
                SizedBox(width: 12),
                Expanded(child: Text(StudyCopy.pyqLocked)),
              ],
            ),
          )
        else
          HmPrimaryButton(
            key: const Key('pyq-practise'),
            label: 'Practise these',
            onPressed: onPractise,
          ),
        const SizedBox(height: 16),
        if (loadingPage) const HmLoadingView(label: 'Loading questions'),
        if (pageError != null) Text(pageError!),
        for (final item in page?.items ?? const <PyqItemView>[])
          ListTile(
            minTileHeight: 48,
            contentPadding: EdgeInsets.zero,
            leading: TierChip(pro: item.locked),
            title: Text(
              item.locked ? StudyCopy.pyqLocked : item.question.stem,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: item.question.tamil && !item.locked
                  ? const TextStyle(fontFamily: HmFonts.tamilContentOnly)
                  : null,
            ),
            subtitle: Text(item.question.source.line),
          ),
      ],
    );
  }
}
