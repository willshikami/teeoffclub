import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teeoffclub/utils/app_theme.dart';
import 'dart:async';
import 'package:async_redux/async_redux.dart';
import 'package:teeoffclub/redux/actions/actions.dart';
import 'package:teeoffclub/data/models/sports/range_session.dart';
import 'package:uuid/uuid.dart';

class RangeSetupPage extends StatefulWidget {
  const RangeSetupPage({super.key});

  @override
  State<RangeSetupPage> createState() => _RangeSetupPageState();
}

class _RangeSetupPageState extends State<RangeSetupPage> {
  // Session State
  bool isSessionOngoing = false;
  String selectedClub = 'Driver';
  int ballsHit = 0;
  final TextEditingController _notesController = TextEditingController();
  
  // Timer State
  Timer? _timer;
  int _secondsElapsed = 0;

  final List<String> clubs = [
    'Driver',
    '3 Wood',
    '5 Wood',
    '4 Iron',
    '5 Iron',
    '6 Iron',
    '7 Iron',
    '8 Iron',
    '9 Iron',
    'PW',
    'GW',
    'SW',
    'LW'
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handlePrimaryAction(BuildContext context) {
    if (!isSessionOngoing) {
      // Start Session
      setState(() {
        isSessionOngoing = true;
        _secondsElapsed = 0;
      });
      _startTimer();
    } else {
      // Finish Session
      _stopTimer();

      // Create and Save the session
      final session = RangeSession(
        id: const Uuid().v4(),
        clubName: selectedClub,
        ballsHit: ballsHit,
        notes: _notesController.text,
        secondsElapsed: _secondsElapsed,
        dateCreated: DateTime.now(),
      );

      StoreProvider.dispatch(context, SaveRangeSessionAction(session));
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSessionOngoing ? 'ONGOING SESSION' : 'RANGE SETUP',
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2.0,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSessionOngoing ? 'Practice in Progress' : 'New Session',
                        style: GoogleFonts.figtree(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                      if (isSessionOngoing) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LIVE',
                            style: GoogleFonts.figtree(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSessionOngoing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(CupertinoIcons.stopwatch, size: 20, color: Colors.black45),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Club Selection
            _buildSectionTitle('CLUB'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedClub,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.black),
                  items: clubs.map((String club) {
                    return DropdownMenuItem<String>(
                      value: club,
                      child: Text(
                        club,
                        style: GoogleFonts.figtree(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedClub = value!),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Balls Hit
            _buildSectionTitle('BALLS HIT'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCounterButton(CupertinoIcons.minus, () {
                  if (ballsHit > 0) setState(() => ballsHit--);
                }),
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '$ballsHit',
                        style: GoogleFonts.figtree(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildCounterButton(CupertinoIcons.plus, () {
                  setState(() => ballsHit++);
                }),
              ],
            ),
            
            if (isSessionOngoing) ...[
              const SizedBox(height: 32),
              // Notes
              _buildSectionTitle('SESSION NOTES'),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Notes (e.g., Pulling left, great tempo...)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.figtree(fontWeight: FontWeight.w500),
              ),
            ],
            
            const SizedBox(height: 48),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton(
                onPressed: () => _handlePrimaryAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSessionOngoing ? AppColors.forest : AppColors.primary,
                  foregroundColor: isSessionOngoing ? Colors.white : Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  isSessionOngoing ? 'FINISH SESSION' : 'START SESSION',
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.figtree(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.black38,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
