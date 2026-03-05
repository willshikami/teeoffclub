import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/golf_course.dart';
import 'package:teeoffclub/data/services/database_helper.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/presentation/home/pages/leaderboard_page.dart';

class ScorecardPage extends StatefulWidget {
  final GolfGame game;

  const ScorecardPage({super.key, required this.game});

  @override
  State<ScorecardPage> createState() => _ScorecardPageState();
}

class _ScorecardPageState extends State<ScorecardPage> {
  int _currentHoleIndex = 0;
  GolfCourse? _courseDetails;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    if (widget.game.courseId != null) {
      final courses = await DatabaseHelper.instance.getCourses();
      final course = courses.firstWhere((c) => c.id == widget.game.courseId, orElse: () => courses.first);
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
          title: Text(widget.game.courseName.toUpperCase()),
          actions: [
            IconButton(
              icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primary),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardPage(game: widget.game))),
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

  Widget _buildHoleSelector() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.game.totalHoles,
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

  Widget _buildScoringList(_ViewModel vm) {
    // Current par for header if needed
    final int currentHolePar = (_courseDetails != null && _courseDetails!.holes.length > _currentHoleIndex) 
        ? _courseDetails!.holes[_currentHoleIndex].par 
        : 4;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.game.players.length,
      itemBuilder: (context, index) {
        final player = widget.game.players[index];
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

  void _updateScore(_ViewModel vm, Player player, int newScore) {
    // Determine the current par for this hole
    int currentPar = 4;
    if (_courseDetails != null && _courseDetails!.holes.length > _currentHoleIndex) {
      currentPar = _courseDetails!.holes[_currentHoleIndex].par;
    }

    // Clone players and update score for the specific player
    for (var p in widget.game.players) {
      if (p.id == player.id) {
        final List<HoleScore> newScores = List.from(p.scores);
        final scoreIndex = newScores.indexWhere((s) => s.holeNumber == _currentHoleIndex + 1);
        
        final updatedHoleScore = HoleScore(holeNumber: _currentHoleIndex + 1, score: newScore, par: currentPar);

        if (scoreIndex >= 0) {
          newScores[scoreIndex] = updatedHoleScore;
        } else {
          newScores.add(updatedHoleScore);
        }
        
        // Update the actual object in the widget game
        p.scores.clear();
        p.scores.addAll(newScores);
      }
    }

    // Trigger action
    vm.onUpdateGame(widget.game);
    setState(() {});
  }
}

class _Factory extends VmFactory<AppState, ScorecardPage, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      onUpdateGame: (game) => dispatch(SaveGameAction(game)),
    );
  }
}

class _ViewModel extends Vm {
  final Function(GolfGame) onUpdateGame;

  _ViewModel({required this.onUpdateGame}) : super(equals: []);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}