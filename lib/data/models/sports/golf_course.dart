import 'package:json_annotation/json_annotation.dart';

part 'golf_course.g.dart';

@JsonSerializable()
class GolfCourse {
  final String id;
  final String name;
  final String location;
  final int totalHoles;
  final List<HoleData> holes;
  final String? difficulty; // e.g., "Championship", "Resort"
  final double? rating;
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

@JsonSerializable()
class HoleData {
  final int number;
  final int par;
  final int? length; // in yards
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
