import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// 이미지 파일에서 텍스트 전체 추출
  Future<String> recognizeTextFromFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
