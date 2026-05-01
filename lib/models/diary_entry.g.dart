// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryEntryImpl _$$DiaryEntryImplFromJson(Map<String, dynamic> json) =>
    _$DiaryEntryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String? ?? '',
      date: json['date'] as String,
      meal: json['meal'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      r1: (json['r1'] as num?)?.toInt(),
      r2: (json['r2'] as num?)?.toInt(),
      activeTime: (json['activeTime'] as num?)?.toInt(),
      passiveTime: (json['passiveTime'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      photo: json['photo'] as String?,
      country: json['country'] as String?,
      linkedRecipeId: json['linkedRecipeId'] as String?,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DiaryEntryImplToJson(_$DiaryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'desc': instance.desc,
      'date': instance.date,
      'meal': instance.meal,
      'tags': instance.tags,
      'r1': instance.r1,
      'r2': instance.r2,
      'activeTime': instance.activeTime,
      'passiveTime': instance.passiveTime,
      'price': instance.price,
      'photo': instance.photo,
      'country': instance.country,
      'linkedRecipeId': instance.linkedRecipeId,
      'position': instance.position,
    };
