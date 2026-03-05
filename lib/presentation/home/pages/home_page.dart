import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:async_redux/async_redux.dart';
import 'package:intl/intl.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/presentation/home/pages/round_setup_page.dart';
import 'package:teeoffclub/presentation/home/pages/round_details_page.dart';

/// [HomeScreen] serves as the "Clubhouse" or main landing page of the application.
/// It displays the primary action to start a new round and a scrollable history
/// of previous golf games.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(this),
      builder: (context, vm) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeroAction(context),
                    _buildRecentRoundsSection(context, vm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top-level branding header with the "Clubhouse" title.
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TEE OFF', style: TextStyle(
            fontSize: 12, 
            letterSpacing: 4, 
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          )),
          Text('Clubhouse', style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          )),
        ],
      ),
    );
  }

  /// Builds the high-impact "START NEW ROUND" hero card at the top of the scroll view.
  Widget _buildHeroAction(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoundSetupPage())),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.add_circle, color: Colors.black, size: 48),
              SizedBox(height: 32),
              Text('START\nNEW ROUND', style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.0,
              )),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the scrollable list of historical rounds, including a "CLEAR" functionality.
  Widget _buildRecentRoundsSection(BuildContext context, _ViewModel vm) {
    if (vm.games.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HISTORY', style: TextStyle(
                fontSize: 10, 
                letterSpacing: 2, 
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              )),
              TextButton(
                onPressed: () => _confirmClearHistory(context, vm),
                child: const Text('CLEAR', style: TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.games.map((g) => _roundTile(context, g)),
        ]),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, _ViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('CLEAR HISTORY?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will delete all saved rounds. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              vm.onClearHistory();
              Navigator.pop(context);
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Displays a single round's summary in the history list. 
  /// Tapping the tile navigates to the detailed [RoundDetailsPage].
  Widget _roundTile(BuildContext context, GolfGame game) {
    final dateStr = DateFormat('E, d MMM').format(game.dateCreated);
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => RoundDetailsPage(game: game)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr.toUpperCase(), style: const TextStyle(
                    color: AppColors.primary, 
                    fontSize: 10, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 4),
                  Text(game.courseName.toUpperCase(), style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 4),
                  Text('${game.players.length} PLAYERS • ${game.totalHoles} HOLES', 
                      style: TextStyle(
                        color: AppColors.accent.withOpacity(0.4), 
                        fontSize: 9, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 14),
          ],
        ),
      ),
    );
  }
}

class SegmentedToggleButton extends StatelessWidget {
  const SegmentedToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text('Local', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Live', style: TextStyle(color: AppColors.textLight)),
          ),
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.black,
            child: Text('Pro', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomPromptBar extends StatelessWidget {
  const BottomPromptBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: AppColors.textLight),
          ),
          const Expanded(
            child: Text(
              'Quick search or action...',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_none, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _Factory extends VmFactory<AppState, HomeScreen, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      games: state.games,
      isLoading: state.isLoading,
      onClearHistory: () => dispatch(ClearHistoryAction()),
    );
  }
}

class _ViewModel extends Vm {
  final List<GolfGame> games;
  final bool isLoading;
  final VoidCallback onClearHistory;

  _ViewModel({
    required this.games,
    required this.isLoading,
    required this.onClearHistory,
  }) : super(equals: [isLoading]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          onClearHistory == other.onClearHistory &&
          listEquals(games, other.games);

  @override
  int get hashCode => games.hashCode ^ isLoading.hashCode ^ onClearHistory.hashCode;
}
