import 'package:flutter/material.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/utils/app_theme.dart';

class LeaderboardPage extends StatelessWidget {
  final GolfGame game;

  const LeaderboardPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(game.players)
      ..sort((a, b) => a.scoreToPar.compareTo(b.scoreToPar));

    return Scaffold(
      appBar: AppBar(title: const Text('LEADERBOARD')),
      body: Column(
        children: [
          _buildPodium(sortedPlayers),
          Expanded(child: _buildRankList(sortedPlayers)),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Player> players) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (players.length > 1) _podiumBar(players[1], 2, 80),
          const SizedBox(width: 12),
          _podiumBar(players[0], 1, 120),
          const SizedBox(width: 12),
          if (players.length > 2) _podiumBar(players[2], 3, 60),
        ],
      ),
    );
  }

  Widget _podiumBar(Player player, int rank, double height) {
    final isFirst = rank == 1;
    return Column(
      children: [
        Text('${player.scoreToPar > 0 ? '+' : ''}${player.scoreToPar}', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isFirst ? AppColors.primary : AppColors.accent)),
        const SizedBox(height: 8),
        Text(player.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: isFirst ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.w900, color: isFirst ? Colors.black : AppColors.textSecondary))),
        ),
      ],
    );
  }

  Widget _buildRankList(List<Player> players) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
              const SizedBox(width: 20),
              Expanded(child: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text('${player.scoreToPar > 0 ? '+' : ''}${player.scoreToPar}', 
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }
}