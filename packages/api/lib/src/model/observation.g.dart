// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Observation extends Observation {
  @override
  final String id;
  @override
  final String plantName;
  @override
  final DateTime date;
  @override
  final String? imageUrl;
  @override
  final String? notes;
  @override
  final ObservationLocation? location;
  @override
  final double? identificationScore;

  factory _$Observation([void Function(ObservationBuilder)? updates]) =>
      (ObservationBuilder()..update(updates))._build();

  _$Observation._(
      {required this.id,
      required this.plantName,
      required this.date,
      this.imageUrl,
      this.notes,
      this.location,
      this.identificationScore})
      : super._();
  @override
  Observation rebuild(void Function(ObservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ObservationBuilder toBuilder() => ObservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Observation &&
        id == other.id &&
        plantName == other.plantName &&
        date == other.date &&
        imageUrl == other.imageUrl &&
        notes == other.notes &&
        location == other.location &&
        identificationScore == other.identificationScore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plantName.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, identificationScore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Observation')
          ..add('id', id)
          ..add('plantName', plantName)
          ..add('date', date)
          ..add('imageUrl', imageUrl)
          ..add('notes', notes)
          ..add('location', location)
          ..add('identificationScore', identificationScore))
        .toString();
  }
}

class ObservationBuilder implements Builder<Observation, ObservationBuilder> {
  _$Observation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _plantName;
  String? get plantName => _$this._plantName;
  set plantName(String? plantName) => _$this._plantName = plantName;

  DateTime? _date;
  DateTime? get date => _$this._date;
  set date(DateTime? date) => _$this._date = date;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ObservationLocationBuilder? _location;
  ObservationLocationBuilder get location =>
      _$this._location ??= ObservationLocationBuilder();
  set location(ObservationLocationBuilder? location) =>
      _$this._location = location;

  double? _identificationScore;
  double? get identificationScore => _$this._identificationScore;
  set identificationScore(double? identificationScore) =>
      _$this._identificationScore = identificationScore;

  ObservationBuilder() {
    Observation._defaults(this);
  }

  ObservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plantName = $v.plantName;
      _date = $v.date;
      _imageUrl = $v.imageUrl;
      _notes = $v.notes;
      _location = $v.location?.toBuilder();
      _identificationScore = $v.identificationScore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Observation other) {
    _$v = other as _$Observation;
  }

  @override
  void update(void Function(ObservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Observation build() => _build();

  _$Observation _build() {
    _$Observation _$result;
    try {
      _$result = _$v ??
          _$Observation._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Observation', 'id'),
            plantName: BuiltValueNullFieldError.checkNotNull(
                plantName, r'Observation', 'plantName'),
            date: BuiltValueNullFieldError.checkNotNull(
                date, r'Observation', 'date'),
            imageUrl: imageUrl,
            notes: notes,
            location: _location?.build(),
            identificationScore: identificationScore,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Observation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
