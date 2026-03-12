import 'package:flutter/foundation.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/range_session.dart';

/// [AppState] is the single source of truth for the entire application.
/// It holds the history of golf rounds and the current UI loading state.
@immutable
class AppState {
  /// The collection of all saved or active golf rounds retrieved from local storage.
  final List<GolfGame> games;

  /// The history of range practice sessions.
  final List<RangeSession> rangeSessions;

  /// Indicates whether a background operation (like database fetching) is in progress.
  final bool isLoading;

  const AppState({
    this.games = const [],
    this.rangeSessions = const [],
    this.isLoading = false,
  });

  /// Creates a new [AppState] instance with updated fields while preserving others.
  AppState copyWith({
    List<GolfGame>? games,
    List<RangeSession>? rangeSessions,
    bool? isLoading,
  }) {
    return AppState(
      games: games ?? this.games,
      rangeSessions: rangeSessions ?? this.rangeSessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Returns the default starting state for the Redux store.
  static AppState initialState() => const AppState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          games == other.games &&
          rangeSessions == other.rangeSessions &&
          isLoading == other.isLoading;

  @override
  int get hashCode => games.hashCode ^ rangeSessions.hashCode ^ isLoading.hashCode;
}
