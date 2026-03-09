import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async_redux/async_redux.dart';
import 'package:intl/intl.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/presentation/home/pages/round_setup_page.dart';
import 'package:teeoffclub/presentation/home/pages/round_details_page.dart';

/// [HomeScreen] serves as the "Clubhouse" or main landing page of the application.
/// It follows a bento-style design with a white summary top section and a dark logging section.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        // Only move the header when we have items to scroll
        // Otherwise keep it fixed
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(widget),
      builder: (context, vm) => Scaffold(
        backgroundColor: AppColors.sage,
        body: Stack(
          children: [
            // Fixed Forest background for the bottom half of the screen
            // This ensures when you overscroll at the bottom, you only see Forest
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(color: AppColors.forest),
            ),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Flexible Header (Sage Section)
                SliverAppBar(
                  expandedHeight: vm.games.any((g) => g.isLive) ? 580 : 420, // Increased height for Active Round section
                  backgroundColor: AppColors.sage,
                  elevation: 0,
                  pinned: false,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: _buildSageTopSection(context, vm),
                  ),
                ),
                // Forest Section (Logbook)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (vm.games.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildLogbookList(context, vm),
                        // Safe area at the bottom
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top Sage container with salutation and quick actions.
  Widget _buildSageTopSection(BuildContext context, _ViewModel vm) {
    // Determine if there's an active round (game where isLive == true)
    // We take the latest active game if multiple exist
    final activeGame = vm.games.cast<GolfGame?>().lastWhere(
          (g) => g?.isLive ?? false,
          orElse: () => null,
        );

    return Container(
      width: double.infinity,
      color: AppColors.sage,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50), // Replaces SafeArea for SliverAppBar context
          _buildSalutation(),
          const SizedBox(height: 20),
          if (activeGame != null) ...[
            _buildActiveRoundTile(context, activeGame),
            const SizedBox(height: 12),
          ],
          _buildBentoQuickActions(context, vm),
          const SizedBox(height: 24), // 40px gap before the Forest section starts
        ],
      ),
    );
  }

  Widget _buildActiveRoundTile(BuildContext context, GolfGame game) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoundDetailsPage(game: game),
            ),
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF354531), // Darker Forest/Moss for contrast on Sage
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      game.courseName.isEmpty
                          ? 'Karen Country Club'
                          : game.courseName,
                      style: GoogleFonts.figtree(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Live Game Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE',
                          style: GoogleFonts.figtree(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Leaderboard Module
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ...(() {
                      // Sort players by total strokes descending (highest score first)
                      final sortedPlayers = List<Player>.from(game.players)
                        ..sort((a, b) => b.totalStrokes.compareTo(a.totalStrokes));
                      return sortedPlayers.take(2).toList();
                    }())
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      // Logic for current hole/score per player would go here
                      // Using placeholders for now as per previous design
                      return Column(
                        children: [
                          _buildLeaderboardRow(
                            player.name,
                            'Hole ${7 + index}', // Simulated hole progress
                            index == 0 ? '+3' : '+${3 + index * 2}', // Simulated score
                          ),
                          if (index <
                              (game.players.length > 2
                                      ? 2
                                      : game.players.length) -
                                  1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Navigation prompt now below leaderboard
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CONTINUE',
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(CupertinoIcons.chevron_right,
                            size: 12, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(String name, String hole, String score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Text(
              hole,
              style: GoogleFonts.figtree(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              score,
              style: GoogleFonts.figtree(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalutation() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'GOOD\nMORNING';
    } else if (hour < 17) {
      greeting = 'GOOD\nAFTERNOON';
    } else {
      greeting = 'GOOD\nEVENING';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.figtree(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Mind a round of golf?',
          style: GoogleFonts.figtree(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoQuickActions(BuildContext context, _ViewModel vm) {
    return Row(
      children: [
        // New Game Tile (Bright Lime)
        Expanded(
          flex: 5,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint('Navigating to RoundSetupPage...');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoundSetupPage()),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                height: 132,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('NEW GAME',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.black45)),
                        Icon(CupertinoIcons.arrow_up_right,
                            color: Colors.black, size: 24),
                      ],
                    ),
                    Spacer(),
                    Text('Start Round',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Best Score Tile (White)
        Expanded(
          flex: 3,
          child: Container(
            height: 132,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BEST SCORE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.black38)),
                const Spacer(),
                Text(
                  _getBestScore(vm.games),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getBestScore(List<GolfGame> games) {
    if (games.isEmpty) return '--';
    
    // Simplistic best score logic: lowest total strokes among finished games
    // In a real app, this might be relative to par or specifically for the user
    int? best;
    for (var game in games) {
      if (game.isLive) continue;
      for (var player in game.players) {
        // Assuming the first player is the user for this summary
        final score = player.totalStrokes;
        if (score > 0 && (best == null || score < best)) {
          best = score;
        }
      }
    }
    return best?.toString() ?? '--';
  }


  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/cart.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 18),
          Text(
            'You have no games recorded',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              "Let's head to your favourite course and\nstart a round",
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogbookList(BuildContext context, _ViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
           Text('Past Rounds', style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            height: 1.0,
          ),),
          const SizedBox(height: 24),
          ...vm.games.reversed.map((g) => _roundTile(context, g)),
          const SizedBox(height: 100), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _roundTile(BuildContext context, GolfGame game) {
    final dateStr = DateFormat('EEE, d MMM').format(game.dateCreated);
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => RoundDetailsPage(game: game)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr.toUpperCase(), style: const TextStyle(
                    color: Colors.white54, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  )),
                  const SizedBox(height: 6),
                  Text(game.courseName, style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 18,
                    color: Colors.white,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_getPlayerSummary(game), style: const TextStyle(
                        color: Colors.white38, 
                        fontSize: 14,
                      )),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        game.isLive 
                          ? 'On Hole 7: -2' // Dummy live data for now
                          : 'Completed: -12', // Dummy completed data for now
                        style: TextStyle(
                          color: game.isLive ? AppColors.primary : Colors.white60, 
                          fontSize: 14,
                          fontWeight: game.isLive ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (game.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: const Text('ONGOING', style: TextStyle(
                    color: AppColors.primary, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  )),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            child: Divider(color: Colors.white10, height: 1),
          ),
        ],
      ),
    );
  }

  String _getPlayerSummary(GolfGame game) {
    final count = game.players.length;
    if (count <= 1) return 'Solo';
    final friendsCount = count - 1;
    return 'With $friendsCount ${friendsCount == 1 ? 'friend' : 'friends'}';
  }
}

class _Factory extends VmFactory<AppState, HomeScreen, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      games: state.games,
      onClearHistory: () => dispatch(ClearHistoryAction()),
    );
  }
}

class _ViewModel extends Vm {
  final List<GolfGame> games;
  final VoidCallback onClearHistory;

  _ViewModel({
    required this.games,
    required this.onClearHistory,
  }) : super(equals: [games]);
}
