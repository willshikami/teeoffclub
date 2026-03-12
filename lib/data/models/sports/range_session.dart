import 'package:flutter/foundation.dart';

@immutable
class RangeSession {
  final String id;
  final String clubName;
  final int ballsHit;
  final String notes;
  final int secondsElapsed;
  final DateTime dateCreated;

  const RangeSession({
    required this.id,
    required this.clubName,
    required this.ballsHit,
    required this.notes,
    required this.secondsElapsed,
    required this.dateCreated,
  });

  RangeSession copyWith({
    String? id,
    String? clubName,
    int? ballsHit,
    String? notes,
    int? secondsElapsed,
    DateTime? dateCreated,
  }) {
    return RangeSession(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      ballsHit: ballsHit ?? this.ballsHit,
      notes: notes ?? this.notes,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RangeSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clubName == other.clubName &&
          ballsHit == other.ballsHit &&
          notes == other.notes &&
          secondsElapsed == other.secondsElapsed &&
          dateCreated == other.dateCreated;

  @override
  int get hashCode =>
      id.hashCode ^
      clubName.hashCode ^
      ballsHit.hashCode ^
      notes.hashCode ^
      secondsElapsed.hashCode ^
      dateCreated.hashCode;
}
