import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_entry.freezed.dart';
part 'diary_entry.g.dart';

@freezed
class DiaryEntry with _$DiaryEntry {
  const factory DiaryEntry({
    required String id,
    required String title,
    @Default('') String desc,
    required String date, // ISO "YYYY-MM-DD"
    required String meal, // Breakfast | Lunch | Dinner | Snack | Other
    @Default(<String>[]) List<String> tags,
    int? r1,
    int? r2,
    int? activeTime,
    int? passiveTime,
    double? price,
    String? photo,
    String? country,
    String? linkedRecipeId,
    @Default(0) int position,
  }) = _DiaryEntry;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFromJson(json);
}
