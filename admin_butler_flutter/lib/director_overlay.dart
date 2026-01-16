import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:admin_butler_client/admin_butler_client.dart';

// 1. THE SCRIPT
// This defines exactly what happens in your 3-minute video.
final List<DemoStep> DEMO_SCRIPT = [
  // --- INTRO ---
  DemoStep(text: "Welcome to AdminButler. The AI-powered assistant for your paperwork.", action: "wait", duration: 4000),
  DemoStep(text: "Admins spend hours manually typing data from receipts and bills.", action: "move:center", duration: 4000),
  DemoStep(text: "Butler George automates this using Google Gemini Vision.", action: "move:header", duration: 3000),
  
  // --- THE SCAN ---
  DemoStep(text: "Let's process a new document. I'll tap the Scan button.", action: "move:fab", duration: 2000),
  DemoStep(text: "Clicking now...", action: "click:fab", duration: 1000),
  DemoStep(text: "The image is sent to the server securely via Serverpod.", action: "wait", duration: 4000),
  DemoStep(text: "Gemini analyzes the image, extracting the amount, date, and context.", action: "wait", duration: 4000),
  
  // --- THE RESULT ---
  DemoStep(text: "Done! It identified a 'Utility Bill' for \$145.50.", action: "move:card_0", duration: 4000),
  DemoStep(text: "It even extracted the Due Date automatically.", action: "wait", duration: 3000),
  
  // --- THE DRAFT REPLY ---
  DemoStep(text: "But here is the killer feature: The Auto-Reply.", action: "move:draft_btn", duration: 3000),
  DemoStep(text: "Let's see what Butler George suggests.", action: "click:draft_btn", duration: 1000),
  DemoStep(text: "It wrote a professional email to the vendor asking for clarification.", action: "wait", duration: 6000),
  DemoStep(text: "I can copy this draft with one click.", action: "click:copy_btn", duration: 2000),
  DemoStep(text: "Copied to clipboard.", action: "close:modal", duration: 2000),

  // --- OUTRO ---
  DemoStep(text: "AdminButler. Stop typing. Start managing.", action: "move:center", duration: 5000),
];

class DemoStep {
  final String text;
  final String action;
  final int duration;
  DemoStep({required this.text, required this.action, required this.duration});
}

class DirectorOverlay extends StatefulWidget {
  final Widget child;
  final Function(String action) onActionTriggered;

  const DirectorOverlay({super.key, required this.child, required this.onActionTriggered});

  @override
  State<DirectorOverlay> createState() => _DirectorOverlayState();
}

class _DirectorOverlayState extends State<DirectorOverlay> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  String _currentSubtitle = "";
  Offset _mousePos = const Offset(100, 100);
  
  // Hardcoded positions based on typical screen layout (0.0 to 1.0)
  final Map<String, Offset> _targets = {
    "center": const Offset(0.5, 0.5),
    "header": const Offset(0.5, 0.1),
    "fab": const Offset(0.9, 0.9), // Bottom right
    "card_0": const Offset(0.5, 0.3), // Top card
    "draft_btn": const Offset(0.5, 0.45), // Button on card
    "copy_btn": const Offset(0.5, 0.8), // Bottom sheet button
  };

  void _startScript() async {
    setState(() => _isPlaying = true);

    for (var step in DEMO_SCRIPT) {
      if (!_isPlaying) break;

      // 1. Update Subtitle
      setState(() => _currentSubtitle = step.text);

      // 2. Handle Movement
      if (step.action.startsWith("move:")) {
        final targetKey = step.action.split(":")[1];
        final targetPct = _targets[targetKey] ?? const Offset(0.5, 0.5);
        final screenSize = MediaQuery.of(context).size;
        
        setState(() {
          _mousePos = Offset(
            screenSize.width * targetPct.dx, 
            screenSize.height * targetPct.dy
          );
        });
      }

      // 3. Handle Clicks
      if (step.action.startsWith("click:") || step.action.startsWith("close:")) {
        // First move there
        if (step.action.startsWith("click:")) {
           // animate a small press effect here if we had time
        }
        widget.onActionTriggered(step.action);
      }

      await Future.delayed(Duration(milliseconds: step.duration));
    }

    setState(() {
      _isPlaying = false;
      _currentSubtitle = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Real App
        widget.child,

        // 2. Director Controls (Hidden when playing, or small icon)
        if (!_isPlaying)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: _startScript,
              icon: const Icon(Icons.movie_creation),
              label: const Text("Start Director Mode"),
              backgroundColor: Colors.redAccent,
            ),
          ),
          
        // 3. Fake Mouse Cursor
        if (_isPlaying)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuad,
            left: _mousePos.dx,
            top: _mousePos.dy,
            child: const Icon(
              Icons.mouse, // Or use a custom cursor image
              size: 48,
              color: Colors.white, // High contrast
              shadows: [Shadow(color: Colors.black, blurRadius: 10)],
            ),
          ),

        // 4. Subtitles (The "Teleprompter")
        if (_isPlaying && _currentSubtitle.isNotEmpty)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _currentSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}