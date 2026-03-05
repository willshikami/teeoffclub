import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/presentation/home/pages/scorecard_page.dart';

/// [RoundDetailsPage] provides an in-depth summary of a completed or historical golf round.
/// It displays the final leaderboard, hole-by-hole breakdowns, and course metadata.
class RoundDetailsPage extends StatelessWidget {
  final GolfGame game;

  const RoundDetailsPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(this),
      builder: (context, vm) => Scaffold(
        appBar: AppBar(
          title: Text(game.courseName.toUpperCase()),
          actions: [
            if (game.id != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24),
                onPressed: () => _confirmDelete(context, vm),
              ),
          ],
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (game.isLive) _buildResumeAction(context),
            _buildSummaryHeader(),
            _buildLeaderboardHeader(),
            _buildLeaderboardList(),
            _buildHoleByHoleHeader(),
            _buildHoleByHoleList(),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, _ViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('DELETE ROUND?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will permanently remove this round from your history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              vm.onDelete(game.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit details page
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  /// High-impact call to action for active rounds, allowing users to jump back into the scoring interface.
  Widget _buildResumeAction(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => ScorecardPage(game: game)),
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.play_circle_filled_rounded, color: Colors.black, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROUND IN PROGRESS', style: TextStyle(
                      color: Colors.black, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 10,
                      letterSpacing: 1.0,
                    )),
                    Text('FINISH SCORING', style: TextStyle(
                      color: Colors.black, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 18,
                    )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the top-level round information like date and total holes.
  Widget _buildSummaryHeader() {
    final dateStr = DateFormat('MMMM d, yyyy').format(game.dateCreated);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr.toUpperCase(), style: const TextStyle(
              fontSize: 10, 
              letterSpacing: 2, 
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            )),
            const SizedBox(height: 8),
            Text('${game.totalHoles} HOLE ROUND', style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sports_golf, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(game.format.name.toUpperCase(), style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text('FINAL STANDINGS', style: TextStyle(
          fontSize: 10, 
          letterSpacing: 2, 
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        )),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final sortedPlayers = List<Player>.from(game.players)
      ..sort((a, b) => a.scoreToPar.compareTo(b.scoreToPar));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final player = sortedPlayers[index];
            final isWinner = index == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isWinner ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
              ),
              child: Row(
                children: [
                  Text('#${index + 1}', style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    color: isWinner ? AppColors.primary : AppColors.textSecondary,
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Text('${player.scoreToPar > 0 ? '+' : ''}${player.scoreToPar}', 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        color: isWinner ? AppColors.primary : AppColors.accent,
                        fontSize: 18,
                      )),
                ],
              ),
            );
          },
          childCount: sortedPlayers.length,
        ),
      ),
    );
  }

  Widget _buildHoleByHoleHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text('HOLE BY HOLE', style: TextStyle(
          fontSize: 10, 
          letterSpacing: 2, 
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        )),
      ),
    );
  }

  /// Builds the hole-by-hole section using a horizontal layout per player,
  /// inspired by high-end digital scorecards.
  Widget _buildHoleByHoleList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final holeNumber = index + 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                  child: Text('HOLE $holeNumber', style: const TextStyle(
                    fontSize: 10, 
                    letterSpacing: 2, 
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  )),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      ...game.players.map((player) {
                        final holeScore = player.scores.firstWhere(
                          (s) => s.holeNumber == holeNumber,
                          orElse: () => HoleScore(holeNumber: holeNumber, score: 0, par: 4),
                        );
                        
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(player.name.toUpperCase(), style: const TextStyle(
                                            fontWeight: FontWeight.w900, 
                                            fontSize: 16,
                                            letterSpacing: 0.5,
                                          )),
                                          if (holeScore.score > 0)
                                            _buildScoreLabel(holeScore.score, holeScore.par),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          player.scoreToPar == 0 ? 'E' : '${player.scoreToPar > 0 ? '+' : ''}${player.scoreToPar}',
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text('PAR ${holeScore.par}', style: TextStyle(
                                        color: AppColors.accent.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      )),
                                      const Spacer(),
                                      _scoreChip(holeScore.score, holeScore.par),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (game.players.indexOf(player) != game.players.length - 1)
                              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          },
          childCount: game.totalHoles,
        ),
      ),
    );
  }

  /// Returns a colored label based on the player's score relative to par.
  Widget _buildScoreLabel(int score, int par) {
    if (score == 0) return const SizedBox.shrink();

    final diff = score - par;
    String label = 'PAR';
    Color color = AppColors.textSecondary;

    if (diff == -1) {
      label = 'BIRDIE';
      color = Colors.greenAccent;
    } else if (diff == -2) {
      label = 'EAGLE';
      color = AppColors.primary;
    } else if (diff <= -3) {
      label = 'ALBATROSS';
      color = AppColors.primary;
    } else if (diff == 1) {
      label = 'BOGEY';
      color = Colors.orangeAccent;
    } else if (diff == 2) {
      label = 'DBL BOGEY';
      color = Colors.redAccent;
    } else if (diff >= 3) {
      label = 'TRIPLE+';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(label, style: TextStyle(
        color: color, 
        fontSize: 8, 
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      )),
    );
  }

  /// Visual indicator for the score on a specific hole.
  /// Uses a colored background for birdies and bogies.
  Widget _scoreChip(int score, int par) {
    if (score == 0) return const Text('—', style: TextStyle(color: AppColors.muted));
    
    final diff = score - par;
    Color color = Colors.transparent;
    Color textColor = AppColors.accent;

    if (diff < 0) {
      color = const Color(0xFF4CAF50); // Birdie or better (Green)
      textColor = Colors.white;
    } else if (diff > 0) {
      color = Colors.redAccent.withOpacity(0.2); // Bogey or worse
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: diff > 0 ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
      ),
      child: Center(
        child: Text('$score', style: TextStyle(
          fontWeight: FontWeight.w900, 
          fontSize: 14,
          color: textColor,
        )),
      ),
    );
  }
}

class _Factory extends VmFactory<AppState, RoundDetailsPage, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      onDelete: (id) => dispatch(DeleteGameAction(id)),
    );
  }
}

class _ViewModel extends Vm {
  final Function(int) onDelete;

  _ViewModel({required this.onDelete}) : super(equals: []);
}
