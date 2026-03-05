import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/golf_course.dart';
import 'package:teeoffclub/data/services/database_helper.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/presentation/home/pages/leaderboard_page.dart';

/// [ScorecardPage] provides the active interface for recording scores during a golf round.
/// It tracks a local [_activeGame] instance to ensure all updates are synchronized
/// with the correct database record once an ID is assigned.
class ScorecardPage extends StatefulWidget {
  final GolfGame game;

  const ScorecardPage({super.key, required this.game});

  @override
  State<ScorecardPage> createState() => _ScorecardPageState();
}

class _ScorecardPageState extends State<ScorecardPage> {
  int _currentHoleIndex = 0;
  GolfCourse? _courseDetails;
  late GolfGame _activeGame;

  @override
  void initState() {
    super.initState();
    _activeGame = widget.game;
    _loadCourseDetails();
  }

  /// Loads full course metadata (pars, handicaps) from the database to enable accurate scoring.
  Future<void> _loadCourseDetails() async {
    if (_activeGame.courseId != null) {
      final courses = await DatabaseHelper.instance.getCourses();
      final course = courses.firstWhere((c) => c.id == _activeGame.courseId, orElse: () => courses.first);
      setState(() {
        _courseDetails = course;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(widget),
      builder: (context, vm) => Scaffold(
        appBar: AppBar(
          title: Text(_activeGame.courseName.toUpperCase()),
          actions: [
            IconButton(
              icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primary),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardPage(game: _activeGame))),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHoleSelector(),
            Expanded(child: _buildScoringList(vm)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// Builds a horizontal scrollable list for selecting the current hole numbers.
  Widget _buildHoleSelector() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _activeGame.totalHoles,
        itemBuilder: (context, index) {
          final isSelected = _currentHoleIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _currentHoleIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('${index + 1}', style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isSelected ? Colors.black : AppColors.accent,
                )),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the main list of players and their respective stroke entry controls for the current hole.
  Widget _buildScoringList(_ViewModel vm) {
    // Current par for header if needed
    final int currentHolePar = (_courseDetails != null && _courseDetails!.holes.length > _currentHoleIndex) 
        ? _courseDetails!.holes[_currentHoleIndex].par 
        : 4;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _activeGame.players.length,
      itemBuilder: (context, index) {
        final player = _activeGame.players[index];
        final currentHoleScore = player.scores.firstWhere(
          (s) => s.holeNumber == _currentHoleIndex + 1,
          orElse: () => HoleScore(holeNumber: _currentHoleIndex + 1, score: 0, par: currentHolePar),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('TOTAL: ${player.scoreToPar > 0 ? '+' : ''}${player.scoreToPar}', 
                        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Row(
                children: [
                  _scoreBtn(Icons.remove, () {
                    if (currentHoleScore.score > 0) _updateScore(vm, player, currentHoleScore.score - 1);
                  }),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text('${currentHoleScore.score}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  ),
                  _scoreBtn(Icons.add, () => _updateScore(vm, player, currentHoleScore.score + 1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// A utility widget for the increment/decrement buttons in the score entry row.
  Widget _scoreBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, size: 20, color: AppColors.accent),
      ),
    );
  }

  /// Builds the persistent footer with the primary "SAVE & FINISH" action.
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: const Text('SAVE & FINISH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ),
    );
  }

  /// Logic for updating a player's score and synchronizing the change with Redux and SQLite.
  void _updateScore(_ViewModel vm, Player player, int newScore) {
    // Determine the current par for this hole
    int currentPar = 4;
    if (_courseDetails != null && _courseDetails!.holes.length > _currentHoleIndex) {
      currentPar = _courseDetails!.holes[_currentHoleIndex].par;
    }

    // Clone players and update score for the specific player
    for (var p in _activeGame.players) {
      if (p.id == player.id) {
        final List<HoleScore> newScores = List.from(p.scores);
        final scoreIndex = newScores.indexWhere((s) => s.holeNumber == _currentHoleIndex + 1);
        
        final updatedHoleScore = HoleScore(holeNumber: _currentHoleIndex + 1, score: newScore, par: currentPar);

        if (scoreIndex >= 0) {
          newScores[scoreIndex] = updatedHoleScore;
        } else {
          newScores.add(updatedHoleScore);
        }
        
        // Update the actual object in the active game
        p.scores.clear();
        p.scores.addAll(newScores);
      }
    }

    // Trigger action
    vm.onUpdateGame(_activeGame, (id) {
      _activeGame = _activeGame.copyWith(id: id);
    });
    setState(() {});
  }
}

class _Factory extends VmFactory<AppState, ScorecardPage, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      onUpdateGame: (game, onId) => dispatch(SaveGameAction(game, onIdAssigned: onId)),
    );
  }
}

class _ViewModel extends Vm {
  final Function(GolfGame, Function(int)?) onUpdateGame;

  _ViewModel({required this.onUpdateGame}) : super(equals: []);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}