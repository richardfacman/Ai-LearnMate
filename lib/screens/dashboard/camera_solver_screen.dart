import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_learn_mate/services/ai/camera_service.dart';
import 'package:ai_learn_mate/services/ai/ai_provider_manager.dart';

class CameraSolverScreen extends StatefulWidget {
  const CameraSolverScreen({super.key});

  @override
  State<CameraSolverScreen> createState() => _CameraSolverScreenState();
}

class _CameraSolverScreenState extends State<CameraSolverScreen> {
  final CameraService _cameraService = CameraService();
  final TextEditingController _promptCtrl = TextEditingController();
  
  XFile? _selectedImage;
  String _recognizedText = "";
  String _solution = "";
  bool _loading = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  Future<void> _pickAndProcess(ImageSource source) async {
    setState(() {
      _loading = true;
      _solution = "";
    });

    try {
      final image = await _cameraService.pickImage(source: source);
      if (image == null) {
        setState(() => _loading = false);
        return;
      }

      setState(() => _selectedImage = image);

      final extractedText = await _cameraService.recognizeTextFromXFile(image);
      setState(() => _recognizedText = extractedText);

      final promptText = extractedText.isNotEmpty
          ? "Solve the following educational problem extracted from an image. Provide a clear step-by-step explanation:\n\n$extractedText"
          : "Please solve and explain this homework question step-by-step.";

      final res = await AiProviderManager().generateResponse(
        prompt: promptText,
        feature: AiFeature.imageSolver,
      );

      setState(() => _solution = res);
    } catch (e) {
      setState(() => _solution = "AI is temporarily unavailable. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _solveCustomPrompt(String taskPrefix) async {
    final customInput = _promptCtrl.text.trim();
    final questionText = _recognizedText.isNotEmpty ? _recognizedText : customInput;

    if (questionText.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Capture or upload a question first!", style: TextStyle(color: paper)),
          backgroundColor: surface,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _solution = "";
    });

    try {
      final fullPrompt = "$taskPrefix\n\nQuestion / Topic: ${questionText.isNotEmpty ? questionText : 'Image question'}";
      final res = await AiProviderManager().generateResponse(
        prompt: fullPrompt,
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
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("AI Homework Scanner", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 50, color: gold),
                  const SizedBox(height: 12),
                  const Text(
                    "Snap or Upload a Question",
                    style: TextStyle(color: paper, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Take a photo or upload an image of any math problem, science question, or textbook excerpt to get a step-by-step solution.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : () => _pickAndProcess(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text("Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: ink,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : () => _pickAndProcess(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 18, color: paper),
                          label: const Text("Gallery", style: TextStyle(color: paper)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: hairline),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: gold),
                      SizedBox(height: 12),
                      Text("Scanning image and generating solution...", style: TextStyle(color: muted, fontSize: 13)),
                    ],
                  ),
                ),
              ),

            if (_recognizedText.isNotEmpty) ...[
              const Text("Detected Text:", style: TextStyle(color: paper, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surfaceHi,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hairline),
                ),
                child: Text(_recognizedText, style: const TextStyle(color: paper, fontSize: 13)),
              ),
              const SizedBox(height: 20),
            ],

            if (_solution.isNotEmpty) ...[
              const Text("AI Step-by-Step Solution:", style: TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withOpacity(0.3)),
                ),
                child: SelectableText(_solution, style: const TextStyle(color: paper, fontSize: 14, height: 1.5)),
              ),
              const SizedBox(height: 18),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _actionChip("💡 Explain Simply", () => _solveCustomPrompt("Explain this solution in very simple terms for a beginner.")),
                    _actionChip("❓ Practice Similar", () => _solveCustomPrompt("Generate a similar practice problem with its step-by-step solution.")),
                    _actionChip("🔍 Deep Dive", () => _solveCustomPrompt("Provide a detailed technical deep dive explaining all underlying formulas and principles.")),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: paper, fontSize: 11.5, fontWeight: FontWeight.w500)),
        backgroundColor: surfaceHi,
        side: const BorderSide(color: hairline),
        onPressed: onTap,
      ),
    );
  }
}
