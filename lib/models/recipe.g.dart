// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      servings: json['servings'] as String? ?? '',
      country: json['country'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Ingredient>[],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RecipeStep>[],
      activeTime: (json['activeTime'] as num?)?.toInt(),
      passiveTime: (json['passiveTime'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      photo: json['photo'] as String?,
      source: json['source'] as String? ?? 'manual',
      sourceUrl: json['sourceUrl'] as String?,
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'servings': instance.servings,
      'country': instance.country,
      'tags': instance.tags,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
      'activeTime': instance.activeTime,
      'passiveTime': instance.passiveTime,
      'price': instance.price,
      'photo': instance.photo,
      'source': instance.source,
      'sourceUrl': instance.sourceUrl,
    };
