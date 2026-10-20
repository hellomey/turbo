//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/auth_api.dart';
part 'api/content_api.dart';
part 'api/desk_api.dart';
part 'api/exams_api.dart';
part 'api/platform_api.dart';
part 'api/syllabus_api.dart';
part 'api/users_api.dart';

part 'model/client_kind.dart';
part 'model/community.dart';
part 'model/consent_choices_body.dart';
part 'model/consent_choices_body_choices_inner.dart';
part 'model/consent_notice.dart';
part 'model/consent_notice_purposes_inner.dart';
part 'model/consent_purpose.dart';
part 'model/consent_state.dart';
part 'model/consent_state_choices_inner.dart';
part 'model/delete_account_body.dart';
part 'model/delete_account_response.dart';
part 'model/desk_challenge.dart';
part 'model/desk_totp_enroll_body.dart';
part 'model/desk_totp_enroll_response.dart';
part 'model/desk_totp_verify_body.dart';
part 'model/district.dart';
part 'model/eligibility_check_body.dart';
part 'model/eligibility_reason.dart';
part 'model/eligibility_result.dart';
part 'model/error_envelope.dart';
part 'model/error_envelope_error.dart';
part 'model/exam_detail.dart';
part 'model/exam_detail_all_of_pattern.dart';
part 'model/exam_eligibility.dart';
part 'model/exam_eligibility_age_limit.dart';
part 'model/exam_list.dart';
part 'model/exam_summary.dart';
part 'model/glossary_list.dart';
part 'model/glossary_list_items_inner.dart';
part 'model/health_response.dart';
part 'model/lamp_ring.dart';
part 'model/lesson.dart';
part 'model/lesson_source.dart';
part 'model/me.dart';
part 'model/ok_response.dart';
part 'model/otp_purpose.dart';
part 'model/otp_request_body.dart';
part 'model/otp_request_response.dart';
part 'model/otp_verify_body.dart';
part 'model/otp_verify_response.dart';
part 'model/profile_answers.dart';
part 'model/qualification.dart';
part 'model/refresh_body.dart';
part 'model/role.dart';
part 'model/session_granted.dart';
part 'model/special_category.dart';
part 'model/study_map.dart';
part 'model/study_map_subjects_inner.dart';
part 'model/study_map_topic.dart';
part 'model/textbook_ref.dart';
part 'model/token_pair.dart';
part 'model/update_me_body.dart';
part 'model/user_exams.dart';
part 'model/user_exams_body.dart';
part 'model/user_exams_main.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
