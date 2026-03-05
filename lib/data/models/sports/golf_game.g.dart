// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'golf_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GolfGame _$GolfGameFromJson(Map<String, dynamic> json) => GolfGame(
  id: (json['id'] as num?)?.toInt(),
  courseId: json['courseId'] as String?,
  courseName: json['courseName'] as String,
  dateCreated: DateTime.parse(json['dateCreated'] as String),
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  format:
      $enumDecodeNullable(_$GameFormatEnumMap, json['format']) ??
      GameFormat.stroke,
  totalHoles: (json['totalHoles'] as num?)?.toInt() ?? 18,
  isLive: json['isLive'] as bool? ?? false,
);

Map<String, dynamic> _$GolfGameToJson(GolfGame instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'courseName': instance.courseName,
  'dateCreated': instance.dateCreated.toIso8601String(),
  'players': instance.players,
  'format': _$GameFormatEnumMap[instance.format]!,
  'totalHoles': instance.totalHoles,
  'isLive': instance.isLive,
};

const _$GameFormatEnumMap = {
  GameFormat.stroke: 'stroke',
  GameFormat.match: 'match',
};

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  scores: (json['scores'] as List<dynamic>)
      .map((e) => HoleScore.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'scores': instance.scores,
};

HoleScore _$HoleScoreFromJson(Map<String, dynamic> json) => HoleScore(
  holeNumber: (json['holeNumber'] as num).toInt(),
  par: (json['par'] as num).toInt(),
  score: (json['score'] as num).toInt(),
);

Map<String, dynamic> _$HoleScoreToJson(HoleScore instance) => <String, dynamic>{
  'holeNumber': instance.holeNumber,
  'par': instance.par,
  'score': instance.score,
};
