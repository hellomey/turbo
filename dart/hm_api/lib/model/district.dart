//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class District {
  /// Instantiate a new enum with the provided [value].
  const District._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const ariyalur = District._(r'Ariyalur');
  static const chengalpattu = District._(r'Chengalpattu');
  static const chennai = District._(r'Chennai');
  static const coimbatore = District._(r'Coimbatore');
  static const cuddalore = District._(r'Cuddalore');
  static const dharmapuri = District._(r'Dharmapuri');
  static const dindigul = District._(r'Dindigul');
  static const erode = District._(r'Erode');
  static const kallakurichi = District._(r'Kallakurichi');
  static const kancheepuram = District._(r'Kancheepuram');
  static const kanyakumari = District._(r'Kanyakumari');
  static const karur = District._(r'Karur');
  static const krishnagiri = District._(r'Krishnagiri');
  static const madurai = District._(r'Madurai');
  static const mayiladuthurai = District._(r'Mayiladuthurai');
  static const nagapattinam = District._(r'Nagapattinam');
  static const namakkal = District._(r'Namakkal');
  static const nilgiris = District._(r'Nilgiris');
  static const perambalur = District._(r'Perambalur');
  static const pudukkottai = District._(r'Pudukkottai');
  static const ramanathapuram = District._(r'Ramanathapuram');
  static const ranipet = District._(r'Ranipet');
  static const salem = District._(r'Salem');
  static const sivaganga = District._(r'Sivaganga');
  static const tenkasi = District._(r'Tenkasi');
  static const thanjavur = District._(r'Thanjavur');
  static const theni = District._(r'Theni');
  static const thoothukudi = District._(r'Thoothukudi');
  static const tiruchirappalli = District._(r'Tiruchirappalli');
  static const tirunelveli = District._(r'Tirunelveli');
  static const tirupathur = District._(r'Tirupathur');
  static const tiruppur = District._(r'Tiruppur');
  static const tiruvallur = District._(r'Tiruvallur');
  static const tiruvannamalai = District._(r'Tiruvannamalai');
  static const tiruvarur = District._(r'Tiruvarur');
  static const vellore = District._(r'Vellore');
  static const viluppuram = District._(r'Viluppuram');
  static const virudhunagar = District._(r'Virudhunagar');

  /// List of all possible values in this [enum][District].
  static const values = <District>[
    ariyalur,
    chengalpattu,
    chennai,
    coimbatore,
    cuddalore,
    dharmapuri,
    dindigul,
    erode,
    kallakurichi,
    kancheepuram,
    kanyakumari,
    karur,
    krishnagiri,
    madurai,
    mayiladuthurai,
    nagapattinam,
    namakkal,
    nilgiris,
    perambalur,
    pudukkottai,
    ramanathapuram,
    ranipet,
    salem,
    sivaganga,
    tenkasi,
    thanjavur,
    theni,
    thoothukudi,
    tiruchirappalli,
    tirunelveli,
    tirupathur,
    tiruppur,
    tiruvallur,
    tiruvannamalai,
    tiruvarur,
    vellore,
    viluppuram,
    virudhunagar,
  ];

  static District? fromJson(dynamic value) => DistrictTypeTransformer().decode(value);

  static List<District> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <District>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = District.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [District] to String,
/// and [decode] dynamic data back to [District].
class DistrictTypeTransformer {
  factory DistrictTypeTransformer() => _instance ??= const DistrictTypeTransformer._();

  const DistrictTypeTransformer._();

  String encode(District data) => data.value;

  /// Decodes a [dynamic value][data] to a District.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  District? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'Ariyalur': return District.ariyalur;
        case r'Chengalpattu': return District.chengalpattu;
        case r'Chennai': return District.chennai;
        case r'Coimbatore': return District.coimbatore;
        case r'Cuddalore': return District.cuddalore;
        case r'Dharmapuri': return District.dharmapuri;
        case r'Dindigul': return District.dindigul;
        case r'Erode': return District.erode;
        case r'Kallakurichi': return District.kallakurichi;
        case r'Kancheepuram': return District.kancheepuram;
        case r'Kanyakumari': return District.kanyakumari;
        case r'Karur': return District.karur;
        case r'Krishnagiri': return District.krishnagiri;
        case r'Madurai': return District.madurai;
        case r'Mayiladuthurai': return District.mayiladuthurai;
        case r'Nagapattinam': return District.nagapattinam;
        case r'Namakkal': return District.namakkal;
        case r'Nilgiris': return District.nilgiris;
        case r'Perambalur': return District.perambalur;
        case r'Pudukkottai': return District.pudukkottai;
        case r'Ramanathapuram': return District.ramanathapuram;
        case r'Ranipet': return District.ranipet;
        case r'Salem': return District.salem;
        case r'Sivaganga': return District.sivaganga;
        case r'Tenkasi': return District.tenkasi;
        case r'Thanjavur': return District.thanjavur;
        case r'Theni': return District.theni;
        case r'Thoothukudi': return District.thoothukudi;
        case r'Tiruchirappalli': return District.tiruchirappalli;
        case r'Tirunelveli': return District.tirunelveli;
        case r'Tirupathur': return District.tirupathur;
        case r'Tiruppur': return District.tiruppur;
        case r'Tiruvallur': return District.tiruvallur;
        case r'Tiruvannamalai': return District.tiruvannamalai;
        case r'Tiruvarur': return District.tiruvarur;
        case r'Vellore': return District.vellore;
        case r'Viluppuram': return District.viluppuram;
        case r'Virudhunagar': return District.virudhunagar;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DistrictTypeTransformer] instance.
  static DistrictTypeTransformer? _instance;
}

