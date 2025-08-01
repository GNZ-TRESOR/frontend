// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Clinic _$ClinicFromJson(Map<String, dynamic> json) {
  return _Clinic.fromJson(json);
}

/// @nodoc
mixin _$Clinic {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  List<String> get services => throw _privateConstructorUsedError;
  String get workingHours => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // public, private, clinic, hospital
  List<String> get specialties => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get sector => throw _privateConstructorUsedError;
  String? get cell => throw _privateConstructorUsedError;

  /// Serializes this Clinic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicCopyWith<Clinic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicCopyWith<$Res> {
  factory $ClinicCopyWith(Clinic value, $Res Function(Clinic) then) =
      _$ClinicCopyWithImpl<$Res, Clinic>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    double latitude,
    double longitude,
    String phone,
    String? email,
    String? website,
    List<String> services,
    String workingHours,
    bool isActive,
    String? description,
    double rating,
    int reviewCount,
    String? imageUrl,
    String type,
    List<String> specialties,
    String? district,
    String? sector,
    String? cell,
  });
}

/// @nodoc
class _$ClinicCopyWithImpl<$Res, $Val extends Clinic>
    implements $ClinicCopyWith<$Res> {
  _$ClinicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? phone = null,
    Object? email = freezed,
    Object? website = freezed,
    Object? services = null,
    Object? workingHours = null,
    Object? isActive = null,
    Object? description = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? specialties = null,
    Object? district = freezed,
    Object? sector = freezed,
    Object? cell = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            address:
                null == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String,
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            phone:
                null == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            website:
                freezed == website
                    ? _value.website
                    : website // ignore: cast_nullable_to_non_nullable
                        as String?,
            services:
                null == services
                    ? _value.services
                    : services // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            workingHours:
                null == workingHours
                    ? _value.workingHours
                    : workingHours // ignore: cast_nullable_to_non_nullable
                        as String,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as double,
            reviewCount:
                null == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            specialties:
                null == specialties
                    ? _value.specialties
                    : specialties // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            district:
                freezed == district
                    ? _value.district
                    : district // ignore: cast_nullable_to_non_nullable
                        as String?,
            sector:
                freezed == sector
                    ? _value.sector
                    : sector // ignore: cast_nullable_to_non_nullable
                        as String?,
            cell:
                freezed == cell
                    ? _value.cell
                    : cell // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClinicImplCopyWith<$Res> implements $ClinicCopyWith<$Res> {
  factory _$$ClinicImplCopyWith(
    _$ClinicImpl value,
    $Res Function(_$ClinicImpl) then,
  ) = __$$ClinicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    double latitude,
    double longitude,
    String phone,
    String? email,
    String? website,
    List<String> services,
    String workingHours,
    bool isActive,
    String? description,
    double rating,
    int reviewCount,
    String? imageUrl,
    String type,
    List<String> specialties,
    String? district,
    String? sector,
    String? cell,
  });
}

/// @nodoc
class __$$ClinicImplCopyWithImpl<$Res>
    extends _$ClinicCopyWithImpl<$Res, _$ClinicImpl>
    implements _$$ClinicImplCopyWith<$Res> {
  __$$ClinicImplCopyWithImpl(
    _$ClinicImpl _value,
    $Res Function(_$ClinicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? phone = null,
    Object? email = freezed,
    Object? website = freezed,
    Object? services = null,
    Object? workingHours = null,
    Object? isActive = null,
    Object? description = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? specialties = null,
    Object? district = freezed,
    Object? sector = freezed,
    Object? cell = freezed,
  }) {
    return _then(
      _$ClinicImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        address:
            null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String,
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        phone:
            null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        website:
            freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                    as String?,
        services:
            null == services
                ? _value._services
                : services // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        workingHours:
            null == workingHours
                ? _value.workingHours
                : workingHours // ignore: cast_nullable_to_non_nullable
                    as String,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as double,
        reviewCount:
            null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        specialties:
            null == specialties
                ? _value._specialties
                : specialties // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        district:
            freezed == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                    as String?,
        sector:
            freezed == sector
                ? _value.sector
                : sector // ignore: cast_nullable_to_non_nullable
                    as String?,
        cell:
            freezed == cell
                ? _value.cell
                : cell // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicImpl implements _Clinic {
  const _$ClinicImpl({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.email,
    this.website,
    final List<String> services = const [],
    this.workingHours = '08:00-17:00',
    this.isActive = true,
    this.description,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrl,
    this.type = 'public',
    final List<String> specialties = const [],
    this.district,
    this.sector,
    this.cell,
  }) : _services = services,
       _specialties = specialties;

  factory _$ClinicImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String phone;
  @override
  final String? email;
  @override
  final String? website;
  final List<String> _services;
  @override
  @JsonKey()
  List<String> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  @JsonKey()
  final String workingHours;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? description;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final String type;
  // public, private, clinic, hospital
  final List<String> _specialties;
  // public, private, clinic, hospital
  @override
  @JsonKey()
  List<String> get specialties {
    if (_specialties is EqualUnmodifiableListView) return _specialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialties);
  }

  @override
  final String? district;
  @override
  final String? sector;
  @override
  final String? cell;

  @override
  String toString() {
    return 'Clinic(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, website: $website, services: $services, workingHours: $workingHours, isActive: $isActive, description: $description, rating: $rating, reviewCount: $reviewCount, imageUrl: $imageUrl, type: $type, specialties: $specialties, district: $district, sector: $sector, cell: $cell)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.workingHours, workingHours) ||
                other.workingHours == workingHours) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._specialties,
              _specialties,
            ) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.sector, sector) || other.sector == sector) &&
            (identical(other.cell, cell) || other.cell == cell));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    address,
    latitude,
    longitude,
    phone,
    email,
    website,
    const DeepCollectionEquality().hash(_services),
    workingHours,
    isActive,
    description,
    rating,
    reviewCount,
    imageUrl,
    type,
    const DeepCollectionEquality().hash(_specialties),
    district,
    sector,
    cell,
  ]);

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicImplCopyWith<_$ClinicImpl> get copyWith =>
      __$$ClinicImplCopyWithImpl<_$ClinicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicImplToJson(this);
  }
}

abstract class _Clinic implements Clinic {
  const factory _Clinic({
    required final String id,
    required final String name,
    required final String address,
    required final double latitude,
    required final double longitude,
    required final String phone,
    final String? email,
    final String? website,
    final List<String> services,
    final String workingHours,
    final bool isActive,
    final String? description,
    final double rating,
    final int reviewCount,
    final String? imageUrl,
    final String type,
    final List<String> specialties,
    final String? district,
    final String? sector,
    final String? cell,
  }) = _$ClinicImpl;

  factory _Clinic.fromJson(Map<String, dynamic> json) = _$ClinicImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  List<String> get services;
  @override
  String get workingHours;
  @override
  bool get isActive;
  @override
  String? get description;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  String? get imageUrl;
  @override
  String get type; // public, private, clinic, hospital
  @override
  List<String> get specialties;
  @override
  String? get district;
  @override
  String? get sector;
  @override
  String? get cell;

  /// Create a copy of Clinic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicImplCopyWith<_$ClinicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClinicWithDistance {
  Clinic get clinic => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  String get distanceText => throw _privateConstructorUsedError;

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicWithDistanceCopyWith<ClinicWithDistance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicWithDistanceCopyWith<$Res> {
  factory $ClinicWithDistanceCopyWith(
    ClinicWithDistance value,
    $Res Function(ClinicWithDistance) then,
  ) = _$ClinicWithDistanceCopyWithImpl<$Res, ClinicWithDistance>;
  @useResult
  $Res call({Clinic clinic, double distanceKm, String distanceText});

  $ClinicCopyWith<$Res> get clinic;
}

/// @nodoc
class _$ClinicWithDistanceCopyWithImpl<$Res, $Val extends ClinicWithDistance>
    implements $ClinicWithDistanceCopyWith<$Res> {
  _$ClinicWithDistanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clinic = null,
    Object? distanceKm = null,
    Object? distanceText = null,
  }) {
    return _then(
      _value.copyWith(
            clinic:
                null == clinic
                    ? _value.clinic
                    : clinic // ignore: cast_nullable_to_non_nullable
                        as Clinic,
            distanceKm:
                null == distanceKm
                    ? _value.distanceKm
                    : distanceKm // ignore: cast_nullable_to_non_nullable
                        as double,
            distanceText:
                null == distanceText
                    ? _value.distanceText
                    : distanceText // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClinicCopyWith<$Res> get clinic {
    return $ClinicCopyWith<$Res>(_value.clinic, (value) {
      return _then(_value.copyWith(clinic: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClinicWithDistanceImplCopyWith<$Res>
    implements $ClinicWithDistanceCopyWith<$Res> {
  factory _$$ClinicWithDistanceImplCopyWith(
    _$ClinicWithDistanceImpl value,
    $Res Function(_$ClinicWithDistanceImpl) then,
  ) = __$$ClinicWithDistanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Clinic clinic, double distanceKm, String distanceText});

  @override
  $ClinicCopyWith<$Res> get clinic;
}

/// @nodoc
class __$$ClinicWithDistanceImplCopyWithImpl<$Res>
    extends _$ClinicWithDistanceCopyWithImpl<$Res, _$ClinicWithDistanceImpl>
    implements _$$ClinicWithDistanceImplCopyWith<$Res> {
  __$$ClinicWithDistanceImplCopyWithImpl(
    _$ClinicWithDistanceImpl _value,
    $Res Function(_$ClinicWithDistanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clinic = null,
    Object? distanceKm = null,
    Object? distanceText = null,
  }) {
    return _then(
      _$ClinicWithDistanceImpl(
        clinic:
            null == clinic
                ? _value.clinic
                : clinic // ignore: cast_nullable_to_non_nullable
                    as Clinic,
        distanceKm:
            null == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                    as double,
        distanceText:
            null == distanceText
                ? _value.distanceText
                : distanceText // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$ClinicWithDistanceImpl implements _ClinicWithDistance {
  const _$ClinicWithDistanceImpl({
    required this.clinic,
    required this.distanceKm,
    required this.distanceText,
  });

  @override
  final Clinic clinic;
  @override
  final double distanceKm;
  @override
  final String distanceText;

  @override
  String toString() {
    return 'ClinicWithDistance(clinic: $clinic, distanceKm: $distanceKm, distanceText: $distanceText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicWithDistanceImpl &&
            (identical(other.clinic, clinic) || other.clinic == clinic) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.distanceText, distanceText) ||
                other.distanceText == distanceText));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, clinic, distanceKm, distanceText);

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicWithDistanceImplCopyWith<_$ClinicWithDistanceImpl> get copyWith =>
      __$$ClinicWithDistanceImplCopyWithImpl<_$ClinicWithDistanceImpl>(
        this,
        _$identity,
      );
}

abstract class _ClinicWithDistance implements ClinicWithDistance {
  const factory _ClinicWithDistance({
    required final Clinic clinic,
    required final double distanceKm,
    required final String distanceText,
  }) = _$ClinicWithDistanceImpl;

  @override
  Clinic get clinic;
  @override
  double get distanceKm;
  @override
  String get distanceText;

  /// Create a copy of ClinicWithDistance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicWithDistanceImplCopyWith<_$ClinicWithDistanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
