// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ClinicState {
  List<Clinic> get allClinics => throw _privateConstructorUsedError;
  List<ClinicWithDistance> get nearbyClinics =>
      throw _privateConstructorUsedError;
  List<Clinic> get filteredClinics => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingLocation => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Position? get userLocation => throw _privateConstructorUsedError;
  double get searchRadius => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  String get selectedType => throw _privateConstructorUsedError;
  String get selectedService => throw _privateConstructorUsedError;
  Clinic? get selectedClinic => throw _privateConstructorUsedError;

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicStateCopyWith<ClinicState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicStateCopyWith<$Res> {
  factory $ClinicStateCopyWith(
    ClinicState value,
    $Res Function(ClinicState) then,
  ) = _$ClinicStateCopyWithImpl<$Res, ClinicState>;
  @useResult
  $Res call({
    List<Clinic> allClinics,
    List<ClinicWithDistance> nearbyClinics,
    List<Clinic> filteredClinics,
    bool isLoading,
    bool isLoadingLocation,
    String? error,
    Position? userLocation,
    double searchRadius,
    String searchQuery,
    String selectedType,
    String selectedService,
    Clinic? selectedClinic,
  });

  $ClinicCopyWith<$Res>? get selectedClinic;
}

/// @nodoc
class _$ClinicStateCopyWithImpl<$Res, $Val extends ClinicState>
    implements $ClinicStateCopyWith<$Res> {
  _$ClinicStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allClinics = null,
    Object? nearbyClinics = null,
    Object? filteredClinics = null,
    Object? isLoading = null,
    Object? isLoadingLocation = null,
    Object? error = freezed,
    Object? userLocation = freezed,
    Object? searchRadius = null,
    Object? searchQuery = null,
    Object? selectedType = null,
    Object? selectedService = null,
    Object? selectedClinic = freezed,
  }) {
    return _then(
      _value.copyWith(
            allClinics:
                null == allClinics
                    ? _value.allClinics
                    : allClinics // ignore: cast_nullable_to_non_nullable
                        as List<Clinic>,
            nearbyClinics:
                null == nearbyClinics
                    ? _value.nearbyClinics
                    : nearbyClinics // ignore: cast_nullable_to_non_nullable
                        as List<ClinicWithDistance>,
            filteredClinics:
                null == filteredClinics
                    ? _value.filteredClinics
                    : filteredClinics // ignore: cast_nullable_to_non_nullable
                        as List<Clinic>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoadingLocation:
                null == isLoadingLocation
                    ? _value.isLoadingLocation
                    : isLoadingLocation // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            userLocation:
                freezed == userLocation
                    ? _value.userLocation
                    : userLocation // ignore: cast_nullable_to_non_nullable
                        as Position?,
            searchRadius:
                null == searchRadius
                    ? _value.searchRadius
                    : searchRadius // ignore: cast_nullable_to_non_nullable
                        as double,
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedType:
                null == selectedType
                    ? _value.selectedType
                    : selectedType // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedService:
                null == selectedService
                    ? _value.selectedService
                    : selectedService // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedClinic:
                freezed == selectedClinic
                    ? _value.selectedClinic
                    : selectedClinic // ignore: cast_nullable_to_non_nullable
                        as Clinic?,
          )
          as $Val,
    );
  }

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClinicCopyWith<$Res>? get selectedClinic {
    if (_value.selectedClinic == null) {
      return null;
    }

    return $ClinicCopyWith<$Res>(_value.selectedClinic!, (value) {
      return _then(_value.copyWith(selectedClinic: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClinicStateImplCopyWith<$Res>
    implements $ClinicStateCopyWith<$Res> {
  factory _$$ClinicStateImplCopyWith(
    _$ClinicStateImpl value,
    $Res Function(_$ClinicStateImpl) then,
  ) = __$$ClinicStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Clinic> allClinics,
    List<ClinicWithDistance> nearbyClinics,
    List<Clinic> filteredClinics,
    bool isLoading,
    bool isLoadingLocation,
    String? error,
    Position? userLocation,
    double searchRadius,
    String searchQuery,
    String selectedType,
    String selectedService,
    Clinic? selectedClinic,
  });

  @override
  $ClinicCopyWith<$Res>? get selectedClinic;
}

/// @nodoc
class __$$ClinicStateImplCopyWithImpl<$Res>
    extends _$ClinicStateCopyWithImpl<$Res, _$ClinicStateImpl>
    implements _$$ClinicStateImplCopyWith<$Res> {
  __$$ClinicStateImplCopyWithImpl(
    _$ClinicStateImpl _value,
    $Res Function(_$ClinicStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allClinics = null,
    Object? nearbyClinics = null,
    Object? filteredClinics = null,
    Object? isLoading = null,
    Object? isLoadingLocation = null,
    Object? error = freezed,
    Object? userLocation = freezed,
    Object? searchRadius = null,
    Object? searchQuery = null,
    Object? selectedType = null,
    Object? selectedService = null,
    Object? selectedClinic = freezed,
  }) {
    return _then(
      _$ClinicStateImpl(
        allClinics:
            null == allClinics
                ? _value._allClinics
                : allClinics // ignore: cast_nullable_to_non_nullable
                    as List<Clinic>,
        nearbyClinics:
            null == nearbyClinics
                ? _value._nearbyClinics
                : nearbyClinics // ignore: cast_nullable_to_non_nullable
                    as List<ClinicWithDistance>,
        filteredClinics:
            null == filteredClinics
                ? _value._filteredClinics
                : filteredClinics // ignore: cast_nullable_to_non_nullable
                    as List<Clinic>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        isLoadingLocation:
            null == isLoadingLocation
                ? _value.isLoadingLocation
                : isLoadingLocation // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        userLocation:
            freezed == userLocation
                ? _value.userLocation
                : userLocation // ignore: cast_nullable_to_non_nullable
                    as Position?,
        searchRadius:
            null == searchRadius
                ? _value.searchRadius
                : searchRadius // ignore: cast_nullable_to_non_nullable
                    as double,
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedType:
            null == selectedType
                ? _value.selectedType
                : selectedType // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedService:
            null == selectedService
                ? _value.selectedService
                : selectedService // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedClinic:
            freezed == selectedClinic
                ? _value.selectedClinic
                : selectedClinic // ignore: cast_nullable_to_non_nullable
                    as Clinic?,
      ),
    );
  }
}

/// @nodoc

class _$ClinicStateImpl with DiagnosticableTreeMixin implements _ClinicState {
  const _$ClinicStateImpl({
    final List<Clinic> allClinics = const [],
    final List<ClinicWithDistance> nearbyClinics = const [],
    final List<Clinic> filteredClinics = const [],
    this.isLoading = false,
    this.isLoadingLocation = false,
    this.error,
    this.userLocation,
    this.searchRadius = 10.0,
    this.searchQuery = '',
    this.selectedType = 'all',
    this.selectedService = 'all',
    this.selectedClinic,
  }) : _allClinics = allClinics,
       _nearbyClinics = nearbyClinics,
       _filteredClinics = filteredClinics;

  final List<Clinic> _allClinics;
  @override
  @JsonKey()
  List<Clinic> get allClinics {
    if (_allClinics is EqualUnmodifiableListView) return _allClinics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allClinics);
  }

  final List<ClinicWithDistance> _nearbyClinics;
  @override
  @JsonKey()
  List<ClinicWithDistance> get nearbyClinics {
    if (_nearbyClinics is EqualUnmodifiableListView) return _nearbyClinics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nearbyClinics);
  }

  final List<Clinic> _filteredClinics;
  @override
  @JsonKey()
  List<Clinic> get filteredClinics {
    if (_filteredClinics is EqualUnmodifiableListView) return _filteredClinics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredClinics);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingLocation;
  @override
  final String? error;
  @override
  final Position? userLocation;
  @override
  @JsonKey()
  final double searchRadius;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String selectedType;
  @override
  @JsonKey()
  final String selectedService;
  @override
  final Clinic? selectedClinic;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ClinicState(allClinics: $allClinics, nearbyClinics: $nearbyClinics, filteredClinics: $filteredClinics, isLoading: $isLoading, isLoadingLocation: $isLoadingLocation, error: $error, userLocation: $userLocation, searchRadius: $searchRadius, searchQuery: $searchQuery, selectedType: $selectedType, selectedService: $selectedService, selectedClinic: $selectedClinic)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ClinicState'))
      ..add(DiagnosticsProperty('allClinics', allClinics))
      ..add(DiagnosticsProperty('nearbyClinics', nearbyClinics))
      ..add(DiagnosticsProperty('filteredClinics', filteredClinics))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isLoadingLocation', isLoadingLocation))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('userLocation', userLocation))
      ..add(DiagnosticsProperty('searchRadius', searchRadius))
      ..add(DiagnosticsProperty('searchQuery', searchQuery))
      ..add(DiagnosticsProperty('selectedType', selectedType))
      ..add(DiagnosticsProperty('selectedService', selectedService))
      ..add(DiagnosticsProperty('selectedClinic', selectedClinic));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicStateImpl &&
            const DeepCollectionEquality().equals(
              other._allClinics,
              _allClinics,
            ) &&
            const DeepCollectionEquality().equals(
              other._nearbyClinics,
              _nearbyClinics,
            ) &&
            const DeepCollectionEquality().equals(
              other._filteredClinics,
              _filteredClinics,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingLocation, isLoadingLocation) ||
                other.isLoadingLocation == isLoadingLocation) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.userLocation, userLocation) ||
                other.userLocation == userLocation) &&
            (identical(other.searchRadius, searchRadius) ||
                other.searchRadius == searchRadius) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedType, selectedType) ||
                other.selectedType == selectedType) &&
            (identical(other.selectedService, selectedService) ||
                other.selectedService == selectedService) &&
            (identical(other.selectedClinic, selectedClinic) ||
                other.selectedClinic == selectedClinic));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_allClinics),
    const DeepCollectionEquality().hash(_nearbyClinics),
    const DeepCollectionEquality().hash(_filteredClinics),
    isLoading,
    isLoadingLocation,
    error,
    userLocation,
    searchRadius,
    searchQuery,
    selectedType,
    selectedService,
    selectedClinic,
  );

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicStateImplCopyWith<_$ClinicStateImpl> get copyWith =>
      __$$ClinicStateImplCopyWithImpl<_$ClinicStateImpl>(this, _$identity);
}

abstract class _ClinicState implements ClinicState {
  const factory _ClinicState({
    final List<Clinic> allClinics,
    final List<ClinicWithDistance> nearbyClinics,
    final List<Clinic> filteredClinics,
    final bool isLoading,
    final bool isLoadingLocation,
    final String? error,
    final Position? userLocation,
    final double searchRadius,
    final String searchQuery,
    final String selectedType,
    final String selectedService,
    final Clinic? selectedClinic,
  }) = _$ClinicStateImpl;

  @override
  List<Clinic> get allClinics;
  @override
  List<ClinicWithDistance> get nearbyClinics;
  @override
  List<Clinic> get filteredClinics;
  @override
  bool get isLoading;
  @override
  bool get isLoadingLocation;
  @override
  String? get error;
  @override
  Position? get userLocation;
  @override
  double get searchRadius;
  @override
  String get searchQuery;
  @override
  String get selectedType;
  @override
  String get selectedService;
  @override
  Clinic? get selectedClinic;

  /// Create a copy of ClinicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicStateImplCopyWith<_$ClinicStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
