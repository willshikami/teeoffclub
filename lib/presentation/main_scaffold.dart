import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:teeoffclub/presentation/home/pages/home_page.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:intl/intl.dart';
import 'package:teeoffclub/presentation/home/pages/round_details_page.dart';
import 'package:teeoffclub/data/models/sports/range_session.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CourseHistoryPage(),
    const RangeHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.forest,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, CupertinoIcons.map_fill, 'Home'),
                _buildNavItem(1, CupertinoIcons.flag_fill, 'Courses'),
                _buildNavItem(2, CupertinoIcons.sportscourt_fill, 'Range'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.figtree(
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseHistoryPage extends StatelessWidget {
  const CourseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CourseHistoryViewModel>(
      vm: () => _CourseHistoryFactory(),
      builder: (context, vm) => Scaffold(
        backgroundColor: AppColors.forest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'COURSE HISTORY',
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ),
        body: vm.games.isEmpty
            ? Center(
                child: Text(
                  'No past rounds found.',
                  style: GoogleFonts.figtree(color: Colors.white38),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: vm.games.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final game = vm.games.reversed.toList()[index];
                  return _roundTile(context, game);
                },
              ),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr.toUpperCase(),
                    style: GoogleFonts.figtree(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.courseName,
                    style: GoogleFonts.figtree(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        game.players.length <= 1
                            ? 'Solo'
                            : 'With ${game.players.length - 1} friends',
                        style: GoogleFonts.figtree(
                          color: Colors.white30,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•',
                          style: TextStyle(color: Colors.white24, fontSize: 13)),
                      const SizedBox(width: 8),
                      Text(
                        game.isLive ? 'Ongoing' : 'Completed',
                        style: GoogleFonts.figtree(
                          color: game.isLive ? AppColors.primary : Colors.white54,
                          fontSize: 13,
                          fontWeight:
                              game.isLive ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-12', // Placeholder score logic
                  style: GoogleFonts.figtree(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'PAR',
                  style: GoogleFonts.figtree(
                    color: AppColors.primary.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseHistoryFactory extends VmFactory<AppState, CourseHistoryPage, _CourseHistoryViewModel> {
  @override
  _CourseHistoryViewModel fromStore() => _CourseHistoryViewModel(games: state.games);
}

class _CourseHistoryViewModel extends Vm {
  final List<GolfGame> games;
  _CourseHistoryViewModel({required this.games}) : super(equals: [games]);
}

class RangeHistoryPage extends StatelessWidget {
  const RangeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RangeHistoryViewModel>(
      vm: () => _RangeHistoryFactory(),
      builder: (context, vm) => Scaffold(
        backgroundColor: AppColors.forest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'RANGE HISTORY',
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ),
        body: vm.sessions.isEmpty
            ? Center(
                child: Text(
                  'No practice sessions yet.',
                  style: GoogleFonts.figtree(color: Colors.white24),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: vm.sessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final session = vm.sessions.reversed.toList()[index];
                  final date = _formatDate(session.dateCreated);
                  return _buildRangeSessionTile(
                    date,
                    session.clubName,
                    '${session.ballsHit} Balls',
                    session.notes.isEmpty ? 'No notes added' : session.notes,
                    session.secondsElapsed,
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'TODAY';
    }
    return DateFormat('MMM d').format(date).toUpperCase();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    if (mins == 0) return '${seconds}s';
    return '${mins}m';
  }

  Widget _buildRangeSessionTile(String date, String club, String count, String note, int seconds) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.sportscourt_fill, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(date, style: GoogleFonts.figtree(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.white12, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(_formatDuration(seconds), style: GoogleFonts.figtree(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$club • $count', style: GoogleFonts.figtree(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(note, style: GoogleFonts.figtree(color: Colors.white38, fontSize: 13, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeHistoryFactory extends VmFactory<AppState, RangeHistoryPage, _RangeHistoryViewModel> {
  @override
  _RangeHistoryViewModel fromStore() => _RangeHistoryViewModel(sessions: state.rangeSessions);
}

class _RangeHistoryViewModel extends Vm {
  final List<RangeSession> sessions;
  _RangeHistoryViewModel({required this.sessions}) : super(equals: [sessions]);
}


