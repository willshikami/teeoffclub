import 'package:json_annotation/json_annotation.dart';

part 'golf_course.g.dart';

/// [GolfCourse] defines the structural and geographical metadata of a golfing venue.
/// It contains a collection of [HoleData] that dictates the standard pars for the course.
@JsonSerializable()
class GolfCourse {
  /// Unique identifier for the course, typically used for database linking.
  final String id;

  /// The official name of the golf club or course.
  final String name;

  /// The physical or regional location of the course (e.g., "Nairobi, Kenya").
  final String location;

  /// The total count of holes available on the course (e.g., 9 or 18).
  final int totalHoles;

  /// A detailed list of [HoleData] specifications for every hole on the course.
  final List<HoleData> holes;

  /// Categorization of the course's challenge level (e.g., "Championship").
  final String? difficulty;

  /// The USGA course rating (standard score a scratch golfer would expect).
  final double? rating;

  /// The USGA slope rating (relative difficulty for a bogey golfer).
  final double? slope;

  GolfCourse({
    required this.id,
    required this.name,
    required this.location,
    required this.totalHoles,
    required this.holes,
    this.difficulty,
    this.rating,
    this.slope,
  });

  factory GolfCourse.fromJson(Map<String, dynamic> json) => _$GolfCourseFromJson(json);
  Map<String, dynamic> toJson() => _$GolfCourseToJson(this);
}

/// [HoleData] represents the specific characteristics of a single hole.
@JsonSerializable()
class HoleData {
  /// The chronological index of the hole (e.g., 1 through 18).
  final int number;

  /// The standard number of strokes assigned to the hole.
  final int par;

  /// The physical distance of the hole from the back tees (in yards).
  final int? length;

  /// The handicap index of the hole (1 being most difficult, 18 being easiest).
  final int? handicap;

  HoleData({
    required this.number,
    required this.par,
    this.length,
    this.handicap,
  });

  factory HoleData.fromJson(Map<String, dynamic> json) => _$HoleDataFromJson(json);
  Map<String, dynamic> toJson() => _$HoleDataToJson(this);
}
