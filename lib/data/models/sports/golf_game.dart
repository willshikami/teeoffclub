import 'package:json_annotation/json_annotation.dart';

part 'golf_game.g.dart';

enum GameFormat { stroke, match }

@JsonSerializable()
class GolfGame {
  final int? id;
  final String? courseId;
  final String courseName;
  final DateTime dateCreated;
  final List<Player> players;
  final GameFormat format;
  final int totalHoles; // 9 or 18
  final bool isLive;

  GolfGame({
    this.id,
    this.courseId,
    required this.courseName,
    required this.dateCreated,
    required this.players,
    this.format = GameFormat.stroke,
    this.totalHoles = 18,
    this.isLive = false,
  });

  factory GolfGame.fromJson(Map<String, dynamic> json) => _$GolfGameFromJson(json);
  Map<String, dynamic> toJson() => _$GolfGameToJson(this);

  GolfGame copyWith({
    int? id,
    String? courseId,
    String? courseName,
    DateTime? dateCreated,
    List<Player>? players,
    GameFormat? format,
    int? totalHoles,
    bool? isLive,
  }) {
    return GolfGame(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dateCreated: dateCreated ?? this.dateCreated,
      players: players ?? this.players,
      format: format ?? this.format,
      totalHoles: totalHoles ?? this.totalHoles,
      isLive: isLive ?? this.isLive,
    );
  }
}

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final String? avatarUrl;
  final List<HoleScore> scores;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.scores,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  int get totalStrokes => scores.fold(0, (sum, item) => sum + item.score);
  int get scoreToPar => scores.fold(0, (sum, item) => sum + (item.score - item.par));
  int get currentHole => scores.length;

  Player copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    List<HoleScore>? scores,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      scores: scores ?? this.scores,
    );
  }
}

@JsonSerializable()
class HoleScore {
  final int holeNumber;
  final int par;
  final int score;

  HoleScore({
    required this.holeNumber,
    required this.par,
    required this.score,
  });

  factory HoleScore.fromJson(Map<String, dynamic> json) => _$HoleScoreFromJson(json);
  Map<String, dynamic> toJson() => _$HoleScoreToJson(this);
}
