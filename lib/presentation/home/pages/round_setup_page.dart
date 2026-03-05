import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'dart:math';
import 'package:teeoffclub/redux/app_state.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/golf_course.dart';
import 'package:teeoffclub/data/services/database_helper.dart';
import 'package:teeoffclub/data/services/golf_course_data.dart';
import 'package:teeoffclub/utils/app_theme.dart';

import 'package:teeoffclub/presentation/home/pages/scorecard_page.dart';

class RoundSetupPage extends StatelessWidget {
  const RoundSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      vm: () => _Factory(this),
      builder: (context, vm) => _RoundSetupView(
        onStartRound: vm.onStartRound,
      ),
    );
  }
}

class _RoundSetupView extends StatefulWidget {
  final Function(GolfGame) onStartRound;

  const _RoundSetupView({required this.onStartRound});

  @override
  State<_RoundSetupView> createState() => _RoundSetupViewState();
}

class _RoundSetupViewState extends State<_RoundSetupView> {
  final TextEditingController _courseController = TextEditingController();
  final List<TextEditingController> _playerControllers = [TextEditingController(text: 'Player 1')];
  GameFormat _format = GameFormat.stroke;
  int _holes = 18;
  GolfCourse? _selectedCourse;
  List<GolfCourse> _availableCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    // Force refresh the courses in the DB to use the new Kenyan clubs
    final mock = GolfCourseData.getCourses();
    await DatabaseHelper.instance.insertCourses(mock);
    _availableCourses = mock;
    setState(() {});
  }

  @override
  void dispose() {
    _courseController.dispose();
    for (var c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onCourseSelected(GolfCourse course) {
    setState(() {
      _selectedCourse = course;
      _courseController.text = course.name;
      _holes = course.totalHoles;
    });
  }

  void _addPlayer() {
    if (_playerControllers.length < 4) {
      setState(() {
        _playerControllers.add(TextEditingController(text: 'Player ${_playerControllers.length + 1}'));
      });
    }
  }

  void _removePlayer(int index) {
    if (_playerControllers.length > 1) {
      setState(() {
        _playerControllers[index].dispose();
        _playerControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETUP ROUND'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('COURSE'),
            const SizedBox(height: 12),
            if (_availableCourses.isNotEmpty)
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = _availableCourses[index];
                    final isSelected = _selectedCourse?.id == course.id;
                    return GestureDetector(
                      onTap: () => _onCourseSelected(course),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? null : Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Text(course.name, style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                            fontSize: 12,
                          )),
                        ),
                      ),
                    );
                  },
                ),
              ),
            TextField(
              controller: _courseController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Or custom name...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.accent.withOpacity(0.2)),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(child: _buildSelector('FORMAT', _format.name.toUpperCase(), () {
                  setState(() => _format = _format == GameFormat.stroke ? GameFormat.match : GameFormat.stroke);
                })),
                const SizedBox(width: 24),
                Expanded(child: _buildSelector('HOLES', '$_holes', () {
                  setState(() => _holes = _holes == 18 ? 9 : 18);
                })),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('PLAYERS'),
                if (_playerControllers.length < 4)
                  IconButton(onPressed: _addPlayer, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ..._playerControllers.asMap().entries.map((entry) => _playerInput(entry.key, entry.value)),
            const SizedBox(height: 80),
            _startBtn(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, color: AppColors.textSecondary));

  Widget _buildSelector(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(label),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.swap_vert, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerInput(int index, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Name'),
            ),
          ),
          if (_playerControllers.length > 1)
            IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.white24), onPressed: () => _removePlayer(index)),
        ],
      ),
    );
  }

  Widget _startBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final game = GolfGame(
            courseId: _selectedCourse?.id,
            courseName: _courseController.text.isEmpty ? 'Unknown' : _courseController.text,
            dateCreated: DateTime.now(),
            format: _format,
            totalHoles: _holes,
            players: _playerControllers.where((c) => c.text.isNotEmpty).map((c) => Player(
              id: Random().nextInt(10000).toString(),
              name: c.text,
              scores: [],
            )).toList(),
          );
          widget.onStartRound(game);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScorecardPage(game: game)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: const Text('START SESSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}

class _Factory extends VmFactory<AppState, RoundSetupPage, _ViewModel> {
  _Factory(super.widget);

  @override
  _ViewModel fromStore() {
    return _ViewModel(
      onStartRound: (game) => dispatch(SaveGameAction(game)),
    );
  }
}

class _ViewModel extends Vm {
  final Function(GolfGame) onStartRound;

  _ViewModel({required this.onStartRound}) : super(equals: []);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
