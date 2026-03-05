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
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(widget),
      builder: (context, vm) => Scaffold(
        backgroundColor: AppColors.sage,
        body: Stack(
          children: [
            // Fixed Forest background at the bottom to prevent Sage showing at bottom overscroll
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 256,
              child: Container(color: AppColors.forest),
            ),
            // Top Sage section Fixed
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildSageTopSection(context, vm),
            ),
            // Scrolling Bottom Forest dark section
            Positioned.fill(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.normal,
                  ),
                ),
                slivers: [
                  // Spacer for the top section
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 380), // Approx height of top section
                  ),
                  SliverToBoxAdapter(
                    child: _buildForestBottomSection(context, vm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top Sage container with salutation and quick actions.
  Widget _buildSageTopSection(BuildContext context, _ViewModel vm) {
    return Container(
      width: double.infinity,
      color: AppColors.sage,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalutation(),
              const SizedBox(height: 20),
              _buildBentoQuickActions(context, vm),
            ],
          ),
        ),
      ),
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
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoundSetupPage()),
            ),
            child: Container(
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
        const SizedBox(width: 12),
        // Rounds Counter Tile (White)
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
                const Text('ROUNDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black38)),
                const Spacer(),
                Text('${vm.games.length}', style: const TextStyle(
                  fontSize: 48, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF333333),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the bottom Forest dark section.
  Widget _buildForestBottomSection(BuildContext context, _ViewModel vm) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: vm.games.isEmpty 
        ? _buildEmptyState(context)
        : _buildLogbookList(context, vm),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/cart.png',
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text('NO GAMES RECORDED', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          )),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              "Lets head to your first round, and start a round",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoundSetupPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Start Round', style: TextStyle(fontWeight: FontWeight.w900)),
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
          
           Text('Game History', style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            height: 1.0,
          ),),
          const SizedBox(height: 24),
          ...vm.games.map((g) => _roundTile(context, g)),
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
                    color: AppColors.primary, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  )),
                  const SizedBox(height: 6),
                  Text(game.courseName, style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                    color: Colors.white,
                  )),
                  const SizedBox(height: 4),
                  Text('${game.totalHoles} Holes', style: const TextStyle(
                    color: Colors.white38, 
                    fontSize: 14,
                  )),
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
