import 'package:flutter/material.dart';
import 'package:ai_learn_mate/services/ai/camera_service.dart';
import 'package:ai_learn_mate/services/ai/ai_provider_manager.dart';

class CameraSolverScreen extends StatefulWidget {
  const CameraSolverScreen({super.key});

  @override
  State<CameraSolverScreen> createState() => _CameraSolverScreenState();
}

class _CameraSolverScreenState extends State<CameraSolverScreen> {
  final CameraService _cameraService = CameraService();
  String _recognizedText = "";
  String _solution = "";
  bool _loading = false;

  Future<void> _captureAndSolve() async {
    setState(() => _loading = true);
    
    try {
      final text = await _cameraService.recognizeTextFromImage();
      if (text.isEmpty) {
        setState(() {
          _loading = false;
          _recognizedText = "No text found in image.";
        });
        return;
      }

      setState(() => _recognizedText = text);

      final res = await AiProviderManager().generateResponse(
        prompt: "Solve the following educational problem found in this text. Provide a step-by-step explanation:\n\n$text",
        feature: AiFeature.imageSolver,
      );
      setState(() => _solution = res);
    } catch (e) {
      setState(() => _solution = "AI is temporarily unavailable. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Homework Solver"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            const Text(
              "Take a photo of a math problem, equation, or any textbook question to get a step-by-step solution.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _loading ? null : _captureAndSolve,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Capture Question"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Detected Question:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Text(_recognizedText),
              ),
            ],
            if (_solution.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("AI Solution:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.2))),
                child: Text(_solution),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
