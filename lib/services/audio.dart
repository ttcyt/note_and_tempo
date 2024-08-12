import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:io';
import 'package:piano11/services/note_segment.dart';

class AudioServices {
  AudioServices({required this.flaskServices});
  FlaskServices flaskServices;
  AudioRecorder audioRecord = AudioRecorder();
  AudioPlayer audioPlayer = AudioPlayer();
  static Timer timer = Timer(const Duration(seconds: 1), () {});
  static int id = 0;
  List<String> paths = [];

  Future<void> startRecording() async {
    AudioEncoder encoder = AudioEncoder.wav;
    if (await audioRecord.hasPermission()) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String path = p.join(appDir.path, 'record$id.wav');
      await audioRecord.start(
          RecordConfig(
            encoder: encoder,
            sampleRate: 16000,
          ),
          path: path);
      id++;

      timer = Timer.periodic(const Duration(seconds: 3), (Timer t) async {
        String? filePath = await audioRecord.stop();
        if (filePath != null) {
          paths.add(filePath);
        }
        if (filePath != null) {
          File file = File(filePath);
          Uint8List audioBytes = await file.readAsBytes();
          await flaskServices.sendAudioSegment(audioBytes as List<int>);

          final Directory appDir = await getApplicationDocumentsDirectory();
          final String path = p.join(appDir.path, 'record$id.wav');
          await audioRecord.start(
              RecordConfig(
                encoder: encoder,
                sampleRate: 16000,
              ),
              path: path);
          id++;
        }
      });
    }
  }

  Future<void> stopRecording() async {
    timer.cancel();
    flaskServices.isFirstTempoSet = false;
  }
}
