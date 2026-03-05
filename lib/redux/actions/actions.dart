import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/data/services/database_helper.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';

abstract class AppAction extends ReduxAction<AppState> {}

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

class SaveGameAction extends AppAction {
  final GolfGame game;
  SaveGameAction(this.game);

  @override
  Future<AppState?> reduce() async {
    await DatabaseHelper.instance.insertGame(game);
    final games = await DatabaseHelper.instance.getAllGames();
    return state.copyWith(games: games);
  }
}

class ClearHistoryAction extends AppAction {
  @override
  Future<AppState?> reduce() async {
    await DatabaseHelper.instance.deleteAllGames();
    return state.copyWith(games: []);
  }
}

class SetLoading extends AppAction {
  final bool isLoading;
  SetLoading(this.isLoading);

  @override
  AppState reduce() => state.copyWith(isLoading: isLoading);
}
