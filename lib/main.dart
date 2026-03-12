import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/presentation/main_scaffold.dart';

late Store<AppState> store;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  store = Store<AppState>(initialState: AppState.initialState());
  // Load initial data
  store.dispatch(FetchGamesAction());
  runApp(const TeeOffClubApp());
}

class TeeOffClubApp extends StatelessWidget {
  const TeeOffClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'TeeOff Club',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      ),
    );
  }
}
