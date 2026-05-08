import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;

  String _formattedTime = "00:00.0";
  String _currentTime = "00:00.0";

  @override
  void initState() {
    super.initState();
    // Update the UI every 30ms for smooth decisecond updates
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);
          _currentTime = _formattedTime;
        });
      }
    });
  }

  String _formatTime(int milliseconds) {
    int minutes = (milliseconds / 60000).truncate();
    int seconds = (milliseconds / 1000).truncate() % 60;
    int hundredths = (milliseconds / 100).truncate() % 10;

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr.$hundredths";
  }

  void _startStop() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
    });
  }

  void _reset() {
    _stopwatch.reset();
    setState(() {
      _formattedTime = "00:00.0";
      _currentTime = "00:00.0";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Cozy Café Atmosphere)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047&auto=format&fit=crop"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Dark Overlay to make the text pop
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.7),
          ),

          // 3. Café Neon Sign Header
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C2BFF).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFF6C2BFF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C2BFF).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: const Text(
                  "café",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          // 4. Branding
          const Positioned(
            top: 40,
            left: 20,
            child: Text(
              "Ai Learn Mate",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          // 5. Main Content Area
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                
                // Huge Digital Timer Text
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -5,
                  ),
                ),
                
                // Current Sub-label
                Text(
                  "Current: $_currentTime",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // 6. Action Control Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start/Stop Button
                    GestureDetector(
                      onTap: _startStop,
                      child: Container(
                        width: 160,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C2BFF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C2BFF).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _stopwatch.isRunning ? "Stop" : "Start",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Outlined Lap Button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "Lap",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    // Reset Icon
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 45),
                      onPressed: _reset,
                    ),
                    
                    // History Icon
                    IconButton(
                      icon: const Icon(Icons.history_rounded, color: Colors.white, size: 45),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
