//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiClient {
  ApiClient({this.basePath = 'https://api.heymey.app', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType,
  ) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = StreamedRequest(method, uri);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = MultipartRequest(method, uri);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      switch(method) {
        case 'POST': return await _client.post(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PUT': return await _client.put(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'DELETE': return await _client.delete(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PATCH': return await _client.patch(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'HEAD': return await _client.head(uri, headers: nullableHeaderParams,);
        case 'GET': return await _client.get(uri, headers: nullableHeaderParams,);
      }
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }

    throw ApiException(
      HttpStatus.badRequest,
      'Invalid HTTP operation: $method $path',
    );
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'AlertSettings':
          return AlertSettings.fromJson(value);
        case 'AlertSettingsQuietHours':
          return AlertSettingsQuietHours.fromJson(value);
        case 'AnswerInput':
          return AnswerInput.fromJson(value);
        case 'ApproveExamChangeBody':
          return ApproveExamChangeBody.fromJson(value);
        case 'ApproveExamChangeBodyNewStageDate':
          return ApproveExamChangeBodyNewStageDate.fromJson(value);
        case 'CheckKind':
          return CheckKindTypeTransformer().decode(value);
        case 'CheckResult':
          return CheckResult.fromJson(value);
        case 'ClientKind':
          return ClientKindTypeTransformer().decode(value);
        case 'Community':
          return CommunityTypeTransformer().decode(value);
        case 'ConceptDrill':
          return ConceptDrill.fromJson(value);
        case 'ConceptDrillList':
          return ConceptDrillList.fromJson(value);
        case 'ConsentChoicesBody':
          return ConsentChoicesBody.fromJson(value);
        case 'ConsentChoicesBodyChoicesInner':
          return ConsentChoicesBodyChoicesInner.fromJson(value);
        case 'ConsentNotice':
          return ConsentNotice.fromJson(value);
        case 'ConsentNoticePurposesInner':
          return ConsentNoticePurposesInner.fromJson(value);
        case 'ConsentPurpose':
          return ConsentPurposeTypeTransformer().decode(value);
        case 'ConsentState':
          return ConsentState.fromJson(value);
        case 'ConsentStateChoicesInner':
          return ConsentStateChoicesInner.fromJson(value);
        case 'ContentLanguage':
          return ContentLanguageTypeTransformer().decode(value);
        case 'ContentPack':
          return ContentPack.fromJson(value);
        case 'ContentPackList':
          return ContentPackList.fromJson(value);
        case 'DeleteAccountBody':
          return DeleteAccountBody.fromJson(value);
        case 'DeleteAccountResponse':
          return DeleteAccountResponse.fromJson(value);
        case 'DeskChallenge':
          return DeskChallenge.fromJson(value);
        case 'DeskTotpEnrollBody':
          return DeskTotpEnrollBody.fromJson(value);
        case 'DeskTotpEnrollResponse':
          return DeskTotpEnrollResponse.fromJson(value);
        case 'DeskTotpVerifyBody':
          return DeskTotpVerifyBody.fromJson(value);
        case 'District':
          return DistrictTypeTransformer().decode(value);
        case 'EligibilityCheckBody':
          return EligibilityCheckBody.fromJson(value);
        case 'EligibilityReason':
          return EligibilityReason.fromJson(value);
        case 'EligibilityResult':
          return EligibilityResult.fromJson(value);
        case 'ErrorEnvelope':
          return ErrorEnvelope.fromJson(value);
        case 'ErrorEnvelopeError':
          return ErrorEnvelopeError.fromJson(value);
        case 'ExamAlert':
          return ExamAlert.fromJson(value);
        case 'ExamAlertPage':
          return ExamAlertPage.fromJson(value);
        case 'ExamAttemptCycle':
          return ExamAttemptCycle.fromJson(value);
        case 'ExamAttemptCycleStageDatesInner':
          return ExamAttemptCycleStageDatesInner.fromJson(value);
        case 'ExamChange':
          return ExamChange.fromJson(value);
        case 'ExamChangePage':
          return ExamChangePage.fromJson(value);
        case 'ExamChangeStatus':
          return ExamChangeStatusTypeTransformer().decode(value);
        case 'ExamDetail':
          return ExamDetail.fromJson(value);
        case 'ExamDetailAllOfPattern':
          return ExamDetailAllOfPattern.fromJson(value);
        case 'ExamEligibility':
          return ExamEligibility.fromJson(value);
        case 'ExamEligibilityAgeLimit':
          return ExamEligibilityAgeLimit.fromJson(value);
        case 'ExamList':
          return ExamList.fromJson(value);
        case 'ExamPaper':
          return ExamPaper.fromJson(value);
        case 'ExamStage':
          return ExamStage.fromJson(value);
        case 'ExamStructure':
          return ExamStructure.fromJson(value);
        case 'ExamStructureFamily':
          return ExamStructureFamily.fromJson(value);
        case 'ExamSummary':
          return ExamSummary.fromJson(value);
        case 'GlossaryList':
          return GlossaryList.fromJson(value);
        case 'GlossaryListItemsInner':
          return GlossaryListItemsInner.fromJson(value);
        case 'GradedAnswer':
          return GradedAnswer.fromJson(value);
        case 'HealthResponse':
          return HealthResponse.fromJson(value);
        case 'LampRing':
          return LampRing.fromJson(value);
        case 'Lesson':
          return Lesson.fromJson(value);
        case 'LessonCompleteBody':
          return LessonCompleteBody.fromJson(value);
        case 'LessonSource':
          return LessonSource.fromJson(value);
        case 'MarkingScheme':
          return MarkingScheme.fromJson(value);
        case 'MarkingSection':
          return MarkingSection.fromJson(value);
        case 'Marks':
          return Marks.fromJson(value);
        case 'MasterySummary':
          return MasterySummary.fromJson(value);
        case 'MasterySummaryByExamInner':
          return MasterySummaryByExamInner.fromJson(value);
        case 'Me':
          return Me.fromJson(value);
        case 'Mistake':
          return Mistake.fromJson(value);
        case 'MistakePage':
          return MistakePage.fromJson(value);
        case 'MockAllowance':
          return MockAllowance.fromJson(value);
        case 'MockAnswersSaved':
          return MockAnswersSaved.fromJson(value);
        case 'MockAttemptListItem':
          return MockAttemptListItem.fromJson(value);
        case 'MockAttemptPage':
          return MockAttemptPage.fromJson(value);
        case 'MockAttemptState':
          return MockAttemptState.fromJson(value);
        case 'MockKind':
          return MockKindTypeTransformer().decode(value);
        case 'MockList':
          return MockList.fromJson(value);
        case 'MockMode':
          return MockModeTypeTransformer().decode(value);
        case 'MockReport':
          return MockReport.fromJson(value);
        case 'MockSectionView':
          return MockSectionView.fromJson(value);
        case 'MockSummary':
          return MockSummary.fromJson(value);
        case 'OkResponse':
          return OkResponse.fromJson(value);
        case 'OtpPurpose':
          return OtpPurposeTypeTransformer().decode(value);
        case 'OtpRequestBody':
          return OtpRequestBody.fromJson(value);
        case 'OtpRequestResponse':
          return OtpRequestResponse.fromJson(value);
        case 'OtpVerifyBody':
          return OtpVerifyBody.fromJson(value);
        case 'OtpVerifyResponse':
          return OtpVerifyResponse.fromJson(value);
        case 'PaperType':
          return PaperTypeTypeTransformer().decode(value);
        case 'Plan':
          return Plan.fromJson(value);
        case 'PlanDays':
          return PlanDays.fromJson(value);
        case 'PlanDaysDaysInner':
          return PlanDaysDaysInner.fromJson(value);
        case 'PlanExam':
          return PlanExam.fromJson(value);
        case 'PlanItem':
          return PlanItem.fromJson(value);
        case 'PlanItemKind':
          return PlanItemKindTypeTransformer().decode(value);
        case 'PlanItemStatus':
          return PlanItemStatusTypeTransformer().decode(value);
        case 'PracticeAnswerBody':
          return PracticeAnswerBody.fromJson(value);
        case 'PracticeAnswerResult':
          return PracticeAnswerResult.fromJson(value);
        case 'PracticeMode':
          return PracticeModeTypeTransformer().decode(value);
        case 'PracticeSession':
          return PracticeSession.fromJson(value);
        case 'PracticeUsage':
          return PracticeUsage.fromJson(value);
        case 'ProfileAnswers':
          return ProfileAnswers.fromJson(value);
        case 'PushTokenAck':
          return PushTokenAck.fromJson(value);
        case 'PutAlertSettingsBody':
          return PutAlertSettingsBody.fromJson(value);
        case 'PutPlanBody':
          return PutPlanBody.fromJson(value);
        case 'PyqFacets':
          return PyqFacets.fromJson(value);
        case 'PyqFacetsSubjectsInner':
          return PyqFacetsSubjectsInner.fromJson(value);
        case 'PyqFacetsYearsInner':
          return PyqFacetsYearsInner.fromJson(value);
        case 'PyqItem':
          return PyqItem.fromJson(value);
        case 'PyqPage':
          return PyqPage.fromJson(value);
        case 'Qualification':
          return QualificationTypeTransformer().decode(value);
        case 'Question':
          return Question.fromJson(value);
        case 'QuestionKind':
          return QuestionKindTypeTransformer().decode(value);
        case 'QuestionOption':
          return QuestionOption.fromJson(value);
        case 'QuestionReportAck':
          return QuestionReportAck.fromJson(value);
        case 'QuestionReportBody':
          return QuestionReportBody.fromJson(value);
        case 'QuestionSource':
          return QuestionSource.fromJson(value);
        case 'QuestionSourcePyq':
          return QuestionSourcePyq.fromJson(value);
        case 'Rank':
          return Rank.fromJson(value);
        case 'RankChange':
          return RankChange.fromJson(value);
        case 'ReadinessBar':
          return ReadinessBar.fromJson(value);
        case 'ReadinessLabel':
          return ReadinessLabelTypeTransformer().decode(value);
        case 'ReadinessMeter':
          return ReadinessMeter.fromJson(value);
        case 'ReadinessMeterCoverage':
          return ReadinessMeterCoverage.fromJson(value);
        case 'ReadinessTrend':
          return ReadinessTrend.fromJson(value);
        case 'ReadinessTrendPointsInner':
          return ReadinessTrendPointsInner.fromJson(value);
        case 'RefreshBody':
          return RefreshBody.fromJson(value);
        case 'RegisterPushTokenBody':
          return RegisterPushTokenBody.fromJson(value);
        case 'RejectExamChangeBody':
          return RejectExamChangeBody.fromJson(value);
        case 'RelightItem':
          return RelightItem.fromJson(value);
        case 'RelightQueue':
          return RelightQueue.fromJson(value);
        case 'RingCounts':
          return RingCounts.fromJson(value);
        case 'Role':
          return RoleTypeTransformer().decode(value);
        case 'SaveMockAnswersBody':
          return SaveMockAnswersBody.fromJson(value);
        case 'SaveMockAnswersBodyAnswersInner':
          return SaveMockAnswersBodyAnswersInner.fromJson(value);
        case 'SavedMockAnswer':
          return SavedMockAnswer.fromJson(value);
        case 'SectionResult':
          return SectionResult.fromJson(value);
        case 'SessionGranted':
          return SessionGranted.fromJson(value);
        case 'SiteChangeAck':
          return SiteChangeAck.fromJson(value);
        case 'SiteChangeWebhookBody':
          return SiteChangeWebhookBody.fromJson(value);
        case 'SpecialCategory':
          return SpecialCategoryTypeTransformer().decode(value);
        case 'StartCheckBody':
          return StartCheckBody.fromJson(value);
        case 'StartMockBody':
          return StartMockBody.fromJson(value);
        case 'StartPracticeBody':
          return StartPracticeBody.fromJson(value);
        case 'StateMockInfo':
          return StateMockInfo.fromJson(value);
        case 'StateMockInfoMock':
          return StateMockInfoMock.fromJson(value);
        case 'StatewideRank':
          return StatewideRank.fromJson(value);
        case 'StretchPhase':
          return StretchPhaseTypeTransformer().decode(value);
        case 'StudyMap':
          return StudyMap.fromJson(value);
        case 'StudyMapSubjectsInner':
          return StudyMapSubjectsInner.fromJson(value);
        case 'StudyMapTopic':
          return StudyMapTopic.fromJson(value);
        case 'SubmitCheckBody':
          return SubmitCheckBody.fromJson(value);
        case 'SundayReport':
          return SundayReport.fromJson(value);
        case 'SundayReportPage':
          return SundayReportPage.fromJson(value);
        case 'SundayReportSummary':
          return SundayReportSummary.fromJson(value);
        case 'SyncAction':
          return SyncAction.fromJson(value);
        case 'SyncActionOneOf':
          return SyncActionOneOf.fromJson(value);
        case 'SyncActionOneOf1':
          return SyncActionOneOf1.fromJson(value);
        case 'SyncActionOneOf2':
          return SyncActionOneOf2.fromJson(value);
        case 'SyncActionOneOf3':
          return SyncActionOneOf3.fromJson(value);
        case 'SyncActionResult':
          return SyncActionResult.fromJson(value);
        case 'SyncBatchBody':
          return SyncBatchBody.fromJson(value);
        case 'SyncBatchResult':
          return SyncBatchResult.fromJson(value);
        case 'TextbookRef':
          return TextbookRef.fromJson(value);
        case 'TodayScreen':
          return TodayScreen.fromJson(value);
        case 'TodayScreenRelight':
          return TodayScreenRelight.fromJson(value);
        case 'TokenPair':
          return TokenPair.fromJson(value);
        case 'TopicCheck':
          return TopicCheck.fromJson(value);
        case 'TopicState':
          return TopicState.fromJson(value);
        case 'TopicStatePage':
          return TopicStatePage.fromJson(value);
        case 'UpdateMeBody':
          return UpdateMeBody.fromJson(value);
        case 'UpdatePlanItemBody':
          return UpdatePlanItemBody.fromJson(value);
        case 'UserExams':
          return UserExams.fromJson(value);
        case 'UserExamsBody':
          return UserExamsBody.fromJson(value);
        case 'UserExamsMain':
          return UserExamsMain.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
