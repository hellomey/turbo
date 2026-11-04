import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../practice/domain/practice_models.dart';
import '../data/pyq_repository.dart';

final pyqRepositoryProvider = Provider<PyqRepository>(
  (ref) => ApiPyqRepository(ref.watch(hmApiProvider)),
);

final pyqFacetsProvider = FutureProvider.family<PyqFacetsView, String>(
  (ref, examCode) => ref.watch(pyqRepositoryProvider).facets(examCode),
);

/// The chosen filters (year, subject, difficulty).
final pyqFilterProvider = NotifierProvider<PyqFilterController, PyqFilter>(
  PyqFilterController.new,
);

class PyqFilterController extends Notifier<PyqFilter> {
  @override
  PyqFilter build() => const PyqFilter();

  void set(PyqFilter filter) => state = filter;
}

/// First page for the exam and the current filter (cursor-paginated on the server, §37).
final pyqPageProvider = FutureProvider.family<PyqPageView, (String, PyqFilter)>(
  (ref, key) => ref.watch(pyqRepositoryProvider).search(key.$1, key.$2),
);
