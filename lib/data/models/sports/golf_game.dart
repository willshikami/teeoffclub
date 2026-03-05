import 'package:json_annotation/json_annotation.dart';

part 'golf_game.g.dart';

/// [GameFormat] determines the scoring rules for a golf round.
enum GameFormat { stroke, match }

/// [GolfGame] represents the complete data for a single golf round session.
/// It tracks course details, players, their scores, and the round's metadata.
@JsonSerializable()
class GolfGame {
  /// Unique database identifier assigned by SQLite after the first save.
  final int? id;

  /// The UUID of the selected Kenyan course if it exists in the [DatabaseHelper.courses] table.
  final String? courseId;

  /// Display name of the golf course for this round.
  final String courseName;

  /// The timestamp of when the round was initialized.
  final DateTime dateCreated;

  /// List of [Player] objects participating in this specific round.
  final List<Player> players;

  /// The official scoring format for this round (default is [GameFormat.stroke]).
  final GameFormat format;

  /// Specifies if this is a standard 18-hole round or a shorter 9-hole session.
  final int totalHoles;

  /// A flag indicating if the round is currently being played (unimplemented logic placeholder).
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

  /// Creates a copy of [GolfGame] with updated fields.
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

/// [Player] contains the individual records and scores for a participants in a [GolfGame].
@JsonSerializable()
class Player {
  /// Internal UUID assigned during synchronization or round setup.
  final String id;

  /// The display name of the player.
  final String name;

  /// Optional link to a player's profile image (currently unused).
  final String? avatarUrl;

  /// A collection of [HoleScore] objects documenting individual hole performance.
  final List<HoleScore> scores;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.scores,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  /// Calculated getter for the sum of all recorded shots.
  int get totalStrokes => scores.fold(0, (sum, item) => sum + item.score);

  /// Calculated getter for the cumulative score relative to the par of recorded holes.
  int get scoreToPar => scores.fold(0, (sum, item) => sum + (item.score - item.par));

  /// Indicates the highest hole number for which a score has been recorded.
  int get currentHole => scores.length;

  /// Creates a copy of [Player] with updated fields.
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

/// [HoleScore] records the performance of a single player on a specific hole.
@JsonSerializable()
class HoleScore {
  /// The numerical identifier (1-indexed) of the hole.
  final int holeNumber;

  /// The standard number of strokes for the hole according to course data.
  final int par;

  /// The actual number of strokes taken by the player.
  final int score;

  HoleScore({
    required this.holeNumber,
    required this.par,
    required this.score,
  });

  factory HoleScore.fromJson(Map<String, dynamic> json) => _$HoleScoreFromJson(json);
  Map<String, dynamic> toJson() => _$HoleScoreToJson(this);
}
