import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  Function(String)? _onRecognitionResult;
  Function(String)? _onRecognitionComplete;
  String _lastRecognizedWords = '';

  Future<void> initialize() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<bool> isAvailable() async {
    return _speechToText.isAvailable;
  }

  void setRecognitionResultCallback(Function(String) callback) {
    _onRecognitionResult = callback;
  }

  void setRecognitionCompleteCallback(Function(String) callback) {
    _onRecognitionComplete = callback;
  }

  Future<void> listen() async {
    if (!_speechToText.isAvailable) {
      return;
    }

    _lastRecognizedWords = '';

    await _speechToText.listen(
      onResult: (result) {
        _lastRecognizedWords = result.recognizedWords;
        if (_onRecognitionResult != null) {
          _onRecognitionResult!(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stop() async {
    await _speechToText.stop();
    if (_onRecognitionComplete != null) {
      _onRecognitionComplete!(_lastRecognizedWords);
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
    await _speechToText.stop();
  }
}
