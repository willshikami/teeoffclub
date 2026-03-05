// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'golf_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GolfCourse _$GolfCourseFromJson(Map<String, dynamic> json) => GolfCourse(
  id: json['id'] as String,
  name: json['name'] as String,
  location: json['location'] as String,
  totalHoles: (json['totalHoles'] as num).toInt(),
  holes: (json['holes'] as List<dynamic>)
      .map((e) => HoleData.fromJson(e as Map<String, dynamic>))
      .toList(),
  difficulty: json['difficulty'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  slope: (json['slope'] as num?)?.toDouble(),
);

Map<String, dynamic> _$GolfCourseToJson(GolfCourse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'totalHoles': instance.totalHoles,
      'holes': instance.holes,
      'difficulty': instance.difficulty,
      'rating': instance.rating,
      'slope': instance.slope,
    };

HoleData _$HoleDataFromJson(Map<String, dynamic> json) => HoleData(
  number: (json['number'] as num).toInt(),
  par: (json['par'] as num).toInt(),
  length: (json['length'] as num?)?.toInt(),
  handicap: (json['handicap'] as num?)?.toInt(),
);

Map<String, dynamic> _$HoleDataToJson(HoleData instance) => <String, dynamic>{
  'number': instance.number,
  'par': instance.par,
  'length': instance.length,
  'handicap': instance.handicap,
};
