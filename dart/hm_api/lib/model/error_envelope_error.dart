//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ErrorEnvelopeError {
  /// Returns a new [ErrorEnvelopeError] instance.
  ErrorEnvelopeError({
    required this.code,
    required this.message,
    this.details = const {},
  });

  ErrorEnvelopeErrorCodeEnum code;

  String message;

  Map<String, Object> details;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ErrorEnvelopeError &&
    other.code == code &&
    other.message == message &&
    _deepEquality.equals(other.details, details);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (message.hashCode) +
    (details.hashCode);

  @override
  String toString() => 'ErrorEnvelopeError[code=$code, message=$message, details=$details]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'message'] = this.message;
      json[r'details'] = this.details;
    return json;
  }

  /// Returns a new [ErrorEnvelopeError] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ErrorEnvelopeError? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ErrorEnvelopeError[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "ErrorEnvelopeError[code]" has a null value in JSON.');
        assert(json[r'message'] != null, 'Required key "ErrorEnvelopeError[message]" has a null value in JSON.');
        return true;
      }());

      return ErrorEnvelopeError(
        code: ErrorEnvelopeErrorCodeEnum.fromJson(json[r'code'])!,
        message: mapValueOfType<String>(json, r'message')!,
        details: mapCastOfType<String, Object>(json, r'details') ?? const {},
      );
    }
    return null;
  }

  static List<ErrorEnvelopeError> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ErrorEnvelopeError>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ErrorEnvelopeError.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ErrorEnvelopeError> mapFromJson(dynamic json) {
    final map = <String, ErrorEnvelopeError>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ErrorEnvelopeError.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ErrorEnvelopeError-objects as value to a dart map
  static Map<String, List<ErrorEnvelopeError>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ErrorEnvelopeError>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ErrorEnvelopeError.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'message',
  };
}


class ErrorEnvelopeErrorCodeEnum {
  /// Instantiate a new enum with the provided [value].
  const ErrorEnvelopeErrorCodeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const VALIDATION_FAILED = ErrorEnvelopeErrorCodeEnum._(r'VALIDATION_FAILED');
  static const UNAUTHENTICATED = ErrorEnvelopeErrorCodeEnum._(r'UNAUTHENTICATED');
  static const FORBIDDEN = ErrorEnvelopeErrorCodeEnum._(r'FORBIDDEN');
  static const NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'NOT_FOUND');
  static const RATE_LIMITED = ErrorEnvelopeErrorCodeEnum._(r'RATE_LIMITED');
  static const IDEMPOTENCY_KEY_REQUIRED = ErrorEnvelopeErrorCodeEnum._(r'IDEMPOTENCY_KEY_REQUIRED');
  static const IDEMPOTENCY_KEY_REUSED = ErrorEnvelopeErrorCodeEnum._(r'IDEMPOTENCY_KEY_REUSED');
  static const IDEMPOTENT_RESPONSE_UNAVAILABLE = ErrorEnvelopeErrorCodeEnum._(r'IDEMPOTENT_RESPONSE_UNAVAILABLE');
  static const IDEMPOTENCY_IN_PROGRESS = ErrorEnvelopeErrorCodeEnum._(r'IDEMPOTENCY_IN_PROGRESS');
  static const APP_UPDATE_REQUIRED = ErrorEnvelopeErrorCodeEnum._(r'APP_UPDATE_REQUIRED');
  static const FEATURE_PAUSED = ErrorEnvelopeErrorCodeEnum._(r'FEATURE_PAUSED');
  static const INTERNAL_ERROR = ErrorEnvelopeErrorCodeEnum._(r'INTERNAL_ERROR');
  static const OTP_INVALID = ErrorEnvelopeErrorCodeEnum._(r'OTP_INVALID');
  static const OTP_EXPIRED = ErrorEnvelopeErrorCodeEnum._(r'OTP_EXPIRED');
  static const OTP_LOCKED = ErrorEnvelopeErrorCodeEnum._(r'OTP_LOCKED');
  static const EMAIL_NOT_ALLOWED = ErrorEnvelopeErrorCodeEnum._(r'EMAIL_NOT_ALLOWED');
  static const uNDER18 = ErrorEnvelopeErrorCodeEnum._(r'UNDER_18');
  static const dESK2FAREQUIRED = ErrorEnvelopeErrorCodeEnum._(r'DESK_2FA_REQUIRED');
  static const TOTP_INVALID = ErrorEnvelopeErrorCodeEnum._(r'TOTP_INVALID');
  static const TOTP_LOCKED = ErrorEnvelopeErrorCodeEnum._(r'TOTP_LOCKED');
  static const CHALLENGE_EXPIRED = ErrorEnvelopeErrorCodeEnum._(r'CHALLENGE_EXPIRED');
  static const DESK_NOT_ALLOWED = ErrorEnvelopeErrorCodeEnum._(r'DESK_NOT_ALLOWED');
  static const SESSION_REVOKED = ErrorEnvelopeErrorCodeEnum._(r'SESSION_REVOKED');
  static const CONSENT_REQUIRED = ErrorEnvelopeErrorCodeEnum._(r'CONSENT_REQUIRED');
  static const EXAM_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'EXAM_NOT_FOUND');
  static const LESSON_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'LESSON_NOT_FOUND');
  static const PRACTICE_DAILY_LIMIT = ErrorEnvelopeErrorCodeEnum._(r'PRACTICE_DAILY_LIMIT');
  static const AI_LIMIT_REACHED = ErrorEnvelopeErrorCodeEnum._(r'AI_LIMIT_REACHED');
  static const AI_BUSY = ErrorEnvelopeErrorCodeEnum._(r'AI_BUSY');
  static const GAMES_SLEEPING = ErrorEnvelopeErrorCodeEnum._(r'GAMES_SLEEPING');
  static const RANKED_DAILY_CAP = ErrorEnvelopeErrorCodeEnum._(r'RANKED_DAILY_CAP');
  static const TOPIC_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'TOPIC_NOT_FOUND');
  static const QUESTION_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'QUESTION_NOT_FOUND');
  static const CHECK_NOT_AVAILABLE = ErrorEnvelopeErrorCodeEnum._(r'CHECK_NOT_AVAILABLE');
  static const CHECK_EXPIRED = ErrorEnvelopeErrorCodeEnum._(r'CHECK_EXPIRED');
  static const CHECK_ALREADY_SUBMITTED = ErrorEnvelopeErrorCodeEnum._(r'CHECK_ALREADY_SUBMITTED');
  static const GOLD_DAILY_LIMIT = ErrorEnvelopeErrorCodeEnum._(r'GOLD_DAILY_LIMIT');
  static const PRO_REQUIRED = ErrorEnvelopeErrorCodeEnum._(r'PRO_REQUIRED');
  static const PRACTICE_SESSION_CLOSED = ErrorEnvelopeErrorCodeEnum._(r'PRACTICE_SESSION_CLOSED');
  static const MOCK_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'MOCK_NOT_FOUND');
  static const MOCK_NOT_OPEN = ErrorEnvelopeErrorCodeEnum._(r'MOCK_NOT_OPEN');
  static const MOCK_CLOSED = ErrorEnvelopeErrorCodeEnum._(r'MOCK_CLOSED');
  static const MOCK_MONTHLY_LIMIT = ErrorEnvelopeErrorCodeEnum._(r'MOCK_MONTHLY_LIMIT');
  static const MOCK_DEADLINE_PASSED = ErrorEnvelopeErrorCodeEnum._(r'MOCK_DEADLINE_PASSED');
  static const MOCK_ALREADY_SUBMITTED = ErrorEnvelopeErrorCodeEnum._(r'MOCK_ALREADY_SUBMITTED');
  static const PAPER_TYPE_NOT_SUPPORTED = ErrorEnvelopeErrorCodeEnum._(r'PAPER_TYPE_NOT_SUPPORTED');
  static const RANK_NOT_READY = ErrorEnvelopeErrorCodeEnum._(r'RANK_NOT_READY');
  static const PLAN_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'PLAN_NOT_FOUND');
  static const REPORT_NOT_FOUND = ErrorEnvelopeErrorCodeEnum._(r'REPORT_NOT_FOUND');
  static const WEBHOOK_UNAUTHORIZED = ErrorEnvelopeErrorCodeEnum._(r'WEBHOOK_UNAUTHORIZED');
  static const WEBHOOK_REPLAYED = ErrorEnvelopeErrorCodeEnum._(r'WEBHOOK_REPLAYED');
  static const EXAM_CHANGE_ALREADY_REVIEWED = ErrorEnvelopeErrorCodeEnum._(r'EXAM_CHANGE_ALREADY_REVIEWED');
  static const SYNC_ACTION_TOO_OLD = ErrorEnvelopeErrorCodeEnum._(r'SYNC_ACTION_TOO_OLD');
  static const FIREWALL_VIOLATION = ErrorEnvelopeErrorCodeEnum._(r'FIREWALL_VIOLATION');
  static const PURCHASE_NOT_VERIFIED = ErrorEnvelopeErrorCodeEnum._(r'PURCHASE_NOT_VERIFIED');
  static const SPENDING_LIMIT_REACHED = ErrorEnvelopeErrorCodeEnum._(r'SPENDING_LIMIT_REACHED');

  /// List of all possible values in this [enum][ErrorEnvelopeErrorCodeEnum].
  static const values = <ErrorEnvelopeErrorCodeEnum>[
    VALIDATION_FAILED,
    UNAUTHENTICATED,
    FORBIDDEN,
    NOT_FOUND,
    RATE_LIMITED,
    IDEMPOTENCY_KEY_REQUIRED,
    IDEMPOTENCY_KEY_REUSED,
    IDEMPOTENT_RESPONSE_UNAVAILABLE,
    IDEMPOTENCY_IN_PROGRESS,
    APP_UPDATE_REQUIRED,
    FEATURE_PAUSED,
    INTERNAL_ERROR,
    OTP_INVALID,
    OTP_EXPIRED,
    OTP_LOCKED,
    EMAIL_NOT_ALLOWED,
    uNDER18,
    dESK2FAREQUIRED,
    TOTP_INVALID,
    TOTP_LOCKED,
    CHALLENGE_EXPIRED,
    DESK_NOT_ALLOWED,
    SESSION_REVOKED,
    CONSENT_REQUIRED,
    EXAM_NOT_FOUND,
    LESSON_NOT_FOUND,
    PRACTICE_DAILY_LIMIT,
    AI_LIMIT_REACHED,
    AI_BUSY,
    GAMES_SLEEPING,
    RANKED_DAILY_CAP,
    TOPIC_NOT_FOUND,
    QUESTION_NOT_FOUND,
    CHECK_NOT_AVAILABLE,
    CHECK_EXPIRED,
    CHECK_ALREADY_SUBMITTED,
    GOLD_DAILY_LIMIT,
    PRO_REQUIRED,
    PRACTICE_SESSION_CLOSED,
    MOCK_NOT_FOUND,
    MOCK_NOT_OPEN,
    MOCK_CLOSED,
    MOCK_MONTHLY_LIMIT,
    MOCK_DEADLINE_PASSED,
    MOCK_ALREADY_SUBMITTED,
    PAPER_TYPE_NOT_SUPPORTED,
    RANK_NOT_READY,
    PLAN_NOT_FOUND,
    REPORT_NOT_FOUND,
    WEBHOOK_UNAUTHORIZED,
    WEBHOOK_REPLAYED,
    EXAM_CHANGE_ALREADY_REVIEWED,
    SYNC_ACTION_TOO_OLD,
    FIREWALL_VIOLATION,
    PURCHASE_NOT_VERIFIED,
    SPENDING_LIMIT_REACHED,
  ];

  static ErrorEnvelopeErrorCodeEnum? fromJson(dynamic value) => ErrorEnvelopeErrorCodeEnumTypeTransformer().decode(value);

  static List<ErrorEnvelopeErrorCodeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ErrorEnvelopeErrorCodeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ErrorEnvelopeErrorCodeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ErrorEnvelopeErrorCodeEnum] to String,
/// and [decode] dynamic data back to [ErrorEnvelopeErrorCodeEnum].
class ErrorEnvelopeErrorCodeEnumTypeTransformer {
  factory ErrorEnvelopeErrorCodeEnumTypeTransformer() => _instance ??= const ErrorEnvelopeErrorCodeEnumTypeTransformer._();

  const ErrorEnvelopeErrorCodeEnumTypeTransformer._();

  String encode(ErrorEnvelopeErrorCodeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ErrorEnvelopeErrorCodeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ErrorEnvelopeErrorCodeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'VALIDATION_FAILED': return ErrorEnvelopeErrorCodeEnum.VALIDATION_FAILED;
        case r'UNAUTHENTICATED': return ErrorEnvelopeErrorCodeEnum.UNAUTHENTICATED;
        case r'FORBIDDEN': return ErrorEnvelopeErrorCodeEnum.FORBIDDEN;
        case r'NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.NOT_FOUND;
        case r'RATE_LIMITED': return ErrorEnvelopeErrorCodeEnum.RATE_LIMITED;
        case r'IDEMPOTENCY_KEY_REQUIRED': return ErrorEnvelopeErrorCodeEnum.IDEMPOTENCY_KEY_REQUIRED;
        case r'IDEMPOTENCY_KEY_REUSED': return ErrorEnvelopeErrorCodeEnum.IDEMPOTENCY_KEY_REUSED;
        case r'IDEMPOTENT_RESPONSE_UNAVAILABLE': return ErrorEnvelopeErrorCodeEnum.IDEMPOTENT_RESPONSE_UNAVAILABLE;
        case r'IDEMPOTENCY_IN_PROGRESS': return ErrorEnvelopeErrorCodeEnum.IDEMPOTENCY_IN_PROGRESS;
        case r'APP_UPDATE_REQUIRED': return ErrorEnvelopeErrorCodeEnum.APP_UPDATE_REQUIRED;
        case r'FEATURE_PAUSED': return ErrorEnvelopeErrorCodeEnum.FEATURE_PAUSED;
        case r'INTERNAL_ERROR': return ErrorEnvelopeErrorCodeEnum.INTERNAL_ERROR;
        case r'OTP_INVALID': return ErrorEnvelopeErrorCodeEnum.OTP_INVALID;
        case r'OTP_EXPIRED': return ErrorEnvelopeErrorCodeEnum.OTP_EXPIRED;
        case r'OTP_LOCKED': return ErrorEnvelopeErrorCodeEnum.OTP_LOCKED;
        case r'EMAIL_NOT_ALLOWED': return ErrorEnvelopeErrorCodeEnum.EMAIL_NOT_ALLOWED;
        case r'UNDER_18': return ErrorEnvelopeErrorCodeEnum.uNDER18;
        case r'DESK_2FA_REQUIRED': return ErrorEnvelopeErrorCodeEnum.dESK2FAREQUIRED;
        case r'TOTP_INVALID': return ErrorEnvelopeErrorCodeEnum.TOTP_INVALID;
        case r'TOTP_LOCKED': return ErrorEnvelopeErrorCodeEnum.TOTP_LOCKED;
        case r'CHALLENGE_EXPIRED': return ErrorEnvelopeErrorCodeEnum.CHALLENGE_EXPIRED;
        case r'DESK_NOT_ALLOWED': return ErrorEnvelopeErrorCodeEnum.DESK_NOT_ALLOWED;
        case r'SESSION_REVOKED': return ErrorEnvelopeErrorCodeEnum.SESSION_REVOKED;
        case r'CONSENT_REQUIRED': return ErrorEnvelopeErrorCodeEnum.CONSENT_REQUIRED;
        case r'EXAM_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.EXAM_NOT_FOUND;
        case r'LESSON_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.LESSON_NOT_FOUND;
        case r'PRACTICE_DAILY_LIMIT': return ErrorEnvelopeErrorCodeEnum.PRACTICE_DAILY_LIMIT;
        case r'AI_LIMIT_REACHED': return ErrorEnvelopeErrorCodeEnum.AI_LIMIT_REACHED;
        case r'AI_BUSY': return ErrorEnvelopeErrorCodeEnum.AI_BUSY;
        case r'GAMES_SLEEPING': return ErrorEnvelopeErrorCodeEnum.GAMES_SLEEPING;
        case r'RANKED_DAILY_CAP': return ErrorEnvelopeErrorCodeEnum.RANKED_DAILY_CAP;
        case r'TOPIC_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.TOPIC_NOT_FOUND;
        case r'QUESTION_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.QUESTION_NOT_FOUND;
        case r'CHECK_NOT_AVAILABLE': return ErrorEnvelopeErrorCodeEnum.CHECK_NOT_AVAILABLE;
        case r'CHECK_EXPIRED': return ErrorEnvelopeErrorCodeEnum.CHECK_EXPIRED;
        case r'CHECK_ALREADY_SUBMITTED': return ErrorEnvelopeErrorCodeEnum.CHECK_ALREADY_SUBMITTED;
        case r'GOLD_DAILY_LIMIT': return ErrorEnvelopeErrorCodeEnum.GOLD_DAILY_LIMIT;
        case r'PRO_REQUIRED': return ErrorEnvelopeErrorCodeEnum.PRO_REQUIRED;
        case r'PRACTICE_SESSION_CLOSED': return ErrorEnvelopeErrorCodeEnum.PRACTICE_SESSION_CLOSED;
        case r'MOCK_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.MOCK_NOT_FOUND;
        case r'MOCK_NOT_OPEN': return ErrorEnvelopeErrorCodeEnum.MOCK_NOT_OPEN;
        case r'MOCK_CLOSED': return ErrorEnvelopeErrorCodeEnum.MOCK_CLOSED;
        case r'MOCK_MONTHLY_LIMIT': return ErrorEnvelopeErrorCodeEnum.MOCK_MONTHLY_LIMIT;
        case r'MOCK_DEADLINE_PASSED': return ErrorEnvelopeErrorCodeEnum.MOCK_DEADLINE_PASSED;
        case r'MOCK_ALREADY_SUBMITTED': return ErrorEnvelopeErrorCodeEnum.MOCK_ALREADY_SUBMITTED;
        case r'PAPER_TYPE_NOT_SUPPORTED': return ErrorEnvelopeErrorCodeEnum.PAPER_TYPE_NOT_SUPPORTED;
        case r'RANK_NOT_READY': return ErrorEnvelopeErrorCodeEnum.RANK_NOT_READY;
        case r'PLAN_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.PLAN_NOT_FOUND;
        case r'REPORT_NOT_FOUND': return ErrorEnvelopeErrorCodeEnum.REPORT_NOT_FOUND;
        case r'WEBHOOK_UNAUTHORIZED': return ErrorEnvelopeErrorCodeEnum.WEBHOOK_UNAUTHORIZED;
        case r'WEBHOOK_REPLAYED': return ErrorEnvelopeErrorCodeEnum.WEBHOOK_REPLAYED;
        case r'EXAM_CHANGE_ALREADY_REVIEWED': return ErrorEnvelopeErrorCodeEnum.EXAM_CHANGE_ALREADY_REVIEWED;
        case r'SYNC_ACTION_TOO_OLD': return ErrorEnvelopeErrorCodeEnum.SYNC_ACTION_TOO_OLD;
        case r'FIREWALL_VIOLATION': return ErrorEnvelopeErrorCodeEnum.FIREWALL_VIOLATION;
        case r'PURCHASE_NOT_VERIFIED': return ErrorEnvelopeErrorCodeEnum.PURCHASE_NOT_VERIFIED;
        case r'SPENDING_LIMIT_REACHED': return ErrorEnvelopeErrorCodeEnum.SPENDING_LIMIT_REACHED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ErrorEnvelopeErrorCodeEnumTypeTransformer] instance.
  static ErrorEnvelopeErrorCodeEnumTypeTransformer? _instance;
}


