import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/data/services/database_helper.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/range_session.dart';

/// Base class for all Redux actions in the Tee Off Club application.
abstract class AppAction extends ReduxAction<AppState> {}

/// [FetchGamesAction] coordinates the retrieval of all golf rounds from the local database.
/// It updates the [AppState.games] list and manages the global loading indicator.
class FetchGamesAction extends AppAction {
  @override
  Future<AppState?> reduce() async {
    final games = await DatabaseHelper.instance.getAllGames();
    return state.copyWith(games: games);
  }

  @override
  void before() => dispatch(SetLoading(true));

  @override
  void after() => dispatch(SetLoading(false));
}

/// [SaveRangeSessionAction] saves a range practice session to the state.
class SaveRangeSessionAction extends AppAction {
  final RangeSession session;
  SaveRangeSessionAction(this.session);

  @override
  AppState reduce() {
    final sessions = List<RangeSession>.from(state.rangeSessions)..add(session);
    return state.copyWith(rangeSessions: sessions);
  }
}

/// [SaveGameAction] persists a [GolfGame] object into SQLite.
/// If it's a new game, it provides the generated ID via the [onIdAssigned] callback
/// to ensure the UI can synchronize its local state and prevent duplicate entries.
class SaveGameAction extends AppAction {
  final GolfGame game;
  final Function(int)? onIdAssigned;
  
  SaveGameAction(this.game, {this.onIdAssigned});

  @override
  Future<AppState?> reduce() async {
    final id = await DatabaseHelper.instance.insertGame(game);
    if (game.id == null && onIdAssigned != null) {
      onIdAssigned!(id);
    }
    final games = await DatabaseHelper.instance.getAllGames();
    return state.copyWith(games: games);
  }
}

/// [ClearHistoryAction] performs a destructive operation to remove all golf game history
/// from both the local database and the current [AppState].
class ClearHistoryAction extends AppAction {
  @override
  Future<AppState?> reduce() async {
    await DatabaseHelper.instance.deleteAllGames();
    return state.copyWith(games: []);
  }
}

/// [DeleteGameAction] removes a specific round from both the local database and the Redux state.
class DeleteGameAction extends AppAction {
  final int id;
  DeleteGameAction(this.id);

  @override
  Future<AppState?> reduce() async {
    await DatabaseHelper.instance.deleteGame(id);
    final updatedGames = state.games.where((g) => g.id != id).toList();
    return state.copyWith(games: updatedGames);
  }
}

/// [SetLoading] toggles the application's global loading state, typically used during
/// asynchronous operations in the background.
class SetLoading extends AppAction {
  final bool isLoading;
  SetLoading(this.isLoading);

  @override
  AppState reduce() => state.copyWith(isLoading: isLoading);
}
