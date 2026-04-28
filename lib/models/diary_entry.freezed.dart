// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiaryEntry _$DiaryEntryFromJson(Map<String, dynamic> json) {
  return _DiaryEntry.fromJson(json);
}

/// @nodoc
mixin _$DiaryEntry {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get desc => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // ISO "YYYY-MM-DD"
  String get meal =>
      throw _privateConstructorUsedError; // Breakfast | Lunch | Dinner | Snack | Other
  List<String> get tags => throw _privateConstructorUsedError;
  int? get r1 => throw _privateConstructorUsedError;
  int? get r2 => throw _privateConstructorUsedError;
  int? get activeTime => throw _privateConstructorUsedError;
  int? get passiveTime => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get photo => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get linkedRecipeId => throw _privateConstructorUsedError;

  /// Serializes this DiaryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryEntryCopyWith<DiaryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryEntryCopyWith<$Res> {
  factory $DiaryEntryCopyWith(
          DiaryEntry value, $Res Function(DiaryEntry) then) =
      _$DiaryEntryCopyWithImpl<$Res, DiaryEntry>;
  @useResult
  $Res call(
      {String id,
      String title,
      String desc,
      String date,
      String meal,
      List<String> tags,
      int? r1,
      int? r2,
      int? activeTime,
      int? passiveTime,
      double? price,
      String? photo,
      String? country,
      String? linkedRecipeId});
}

/// @nodoc
class _$DiaryEntryCopyWithImpl<$Res, $Val extends DiaryEntry>
    implements $DiaryEntryCopyWith<$Res> {
  _$DiaryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? desc = null,
    Object? date = null,
    Object? meal = null,
    Object? tags = null,
    Object? r1 = freezed,
    Object? r2 = freezed,
    Object? activeTime = freezed,
    Object? passiveTime = freezed,
    Object? price = freezed,
    Object? photo = freezed,
    Object? country = freezed,
    Object? linkedRecipeId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      meal: null == meal
          ? _value.meal
          : meal // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      r1: freezed == r1
          ? _value.r1
          : r1 // ignore: cast_nullable_to_non_nullable
              as int?,
      r2: freezed == r2
          ? _value.r2
          : r2 // ignore: cast_nullable_to_non_nullable
              as int?,
      activeTime: freezed == activeTime
          ? _value.activeTime
          : activeTime // ignore: cast_nullable_to_non_nullable
              as int?,
      passiveTime: freezed == passiveTime
          ? _value.passiveTime
          : passiveTime // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedRecipeId: freezed == linkedRecipeId
          ? _value.linkedRecipeId
          : linkedRecipeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiaryEntryImplCopyWith<$Res>
    implements $DiaryEntryCopyWith<$Res> {
  factory _$$DiaryEntryImplCopyWith(
          _$DiaryEntryImpl value, $Res Function(_$DiaryEntryImpl) then) =
      __$$DiaryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String desc,
      String date,
      String meal,
      List<String> tags,
      int? r1,
      int? r2,
      int? activeTime,
      int? passiveTime,
      double? price,
      String? photo,
      String? country,
      String? linkedRecipeId});
}

/// @nodoc
class __$$DiaryEntryImplCopyWithImpl<$Res>
    extends _$DiaryEntryCopyWithImpl<$Res, _$DiaryEntryImpl>
    implements _$$DiaryEntryImplCopyWith<$Res> {
  __$$DiaryEntryImplCopyWithImpl(
      _$DiaryEntryImpl _value, $Res Function(_$DiaryEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? desc = null,
    Object? date = null,
    Object? meal = null,
    Object? tags = null,
    Object? r1 = freezed,
    Object? r2 = freezed,
    Object? activeTime = freezed,
    Object? passiveTime = freezed,
    Object? price = freezed,
    Object? photo = freezed,
    Object? country = freezed,
    Object? linkedRecipeId = freezed,
  }) {
    return _then(_$DiaryEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      meal: null == meal
          ? _value.meal
          : meal // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      r1: freezed == r1
          ? _value.r1
          : r1 // ignore: cast_nullable_to_non_nullable
              as int?,
      r2: freezed == r2
          ? _value.r2
          : r2 // ignore: cast_nullable_to_non_nullable
              as int?,
      activeTime: freezed == activeTime
          ? _value.activeTime
          : activeTime // ignore: cast_nullable_to_non_nullable
              as int?,
      passiveTime: freezed == passiveTime
          ? _value.passiveTime
          : passiveTime // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedRecipeId: freezed == linkedRecipeId
          ? _value.linkedRecipeId
          : linkedRecipeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryEntryImpl implements _DiaryEntry {
  const _$DiaryEntryImpl(
      {required this.id,
      required this.title,
      this.desc = '',
      required this.date,
      required this.meal,
      final List<String> tags = const <String>[],
      this.r1,
      this.r2,
      this.activeTime,
      this.passiveTime,
      this.price,
      this.photo,
      this.country,
      this.linkedRecipeId})
      : _tags = tags;

  factory _$DiaryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String desc;
  @override
  final String date;
// ISO "YYYY-MM-DD"
  @override
  final String meal;
// Breakfast | Lunch | Dinner | Snack | Other
  final List<String> _tags;
// Breakfast | Lunch | Dinner | Snack | Other
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final int? r1;
  @override
  final int? r2;
  @override
  final int? activeTime;
  @override
  final int? passiveTime;
  @override
  final double? price;
  @override
  final String? photo;
  @override
  final String? country;
  @override
  final String? linkedRecipeId;

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, desc: $desc, date: $date, meal: $meal, tags: $tags, r1: $r1, r2: $r2, activeTime: $activeTime, passiveTime: $passiveTime, price: $price, photo: $photo, country: $country, linkedRecipeId: $linkedRecipeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.meal, meal) || other.meal == meal) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.r1, r1) || other.r1 == r1) &&
            (identical(other.r2, r2) || other.r2 == r2) &&
            (identical(other.activeTime, activeTime) ||
                other.activeTime == activeTime) &&
            (identical(other.passiveTime, passiveTime) ||
                other.passiveTime == passiveTime) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.linkedRecipeId, linkedRecipeId) ||
                other.linkedRecipeId == linkedRecipeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      desc,
      date,
      meal,
      const DeepCollectionEquality().hash(_tags),
      r1,
      r2,
      activeTime,
      passiveTime,
      price,
      photo,
      country,
      linkedRecipeId);

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      __$$DiaryEntryImplCopyWithImpl<_$DiaryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryEntryImplToJson(
      this,
    );
  }
}

abstract class _DiaryEntry implements DiaryEntry {
  const factory _DiaryEntry(
      {required final String id,
      required final String title,
      final String desc,
      required final String date,
      required final String meal,
      final List<String> tags,
      final int? r1,
      final int? r2,
      final int? activeTime,
      final int? passiveTime,
      final double? price,
      final String? photo,
      final String? country,
      final String? linkedRecipeId}) = _$DiaryEntryImpl;

  factory _DiaryEntry.fromJson(Map<String, dynamic> json) =
      _$DiaryEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get desc;
  @override
  String get date; // ISO "YYYY-MM-DD"
  @override
  String get meal; // Breakfast | Lunch | Dinner | Snack | Other
  @override
  List<String> get tags;
  @override
  int? get r1;
  @override
  int? get r2;
  @override
  int? get activeTime;
  @override
  int? get passiveTime;
  @override
  double? get price;
  @override
  String? get photo;
  @override
  String? get country;
  @override
  String? get linkedRecipeId;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
