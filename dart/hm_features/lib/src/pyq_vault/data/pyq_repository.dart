import 'package:hm_core/hm_core.dart';

import '../../practice/data/practice_repository.dart';
import '../../practice/domain/practice_models.dart';

/// PYQ Vault (§19.4 Q31, §11, INT-002-S09) over `GET /v1/pyq` and `/v1/pyq/facets`.
abstract interface class PyqRepository {
  Future<PyqFacetsView> facets(String examCode);
  Future<PyqPageView> search(
    String examCode,
    PyqFilter filter, {
    String? cursor,
  });
}

class ApiPyqRepository implements PyqRepository {
  ApiPyqRepository(this._api);
  final HmApi _api;

  @override
  Future<PyqFacetsView> facets(String examCode) async =>
      pyqFacetsFromJson(await _api.getPyqFacets(examCode));

  @override
  Future<PyqPageView> search(
    String examCode,
    PyqFilter filter, {
    String? cursor,
  }) async => pyqPageFromJson(
    await _api.searchPyqs(
      examCode,
      year: filter.year,
      subjectCode: filter.subjectCode,
      difficulty: filter.difficulty,
      cursor: cursor,
    ),
  );
}
