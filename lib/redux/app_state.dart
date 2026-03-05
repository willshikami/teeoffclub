import 'package:flutter/foundation.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';

@immutable
class AppState {
  final List<GolfGame> games;
  final bool isLoading;

  const AppState({
    this.games = const [],
    this.isLoading = false,
  });

  AppState copyWith({
    List<GolfGame>? games,
    bool? isLoading,
  }) {
    return AppState(
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static AppState initialState() => const AppState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          games == other.games &&
          isLoading == other.isLoading;

  @override
  int get hashCode => games.hashCode ^ isLoading.hashCode;
}
