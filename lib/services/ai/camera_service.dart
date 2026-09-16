import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(source: source);
    } catch (_) {
      return null;
    }
  }

  Future<String> recognizeTextFromXFile(XFile file) async {
    if (kIsWeb) {
      return "";
    }

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint("OCR error: $e");
      return "";
    }
  }

  void dispose() {
    try {
      _textRecognizer.close();
    } catch (_) {}
  }
}
