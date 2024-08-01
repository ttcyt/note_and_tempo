import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';

Image dot = Image.asset('assets/images/reddot.png');

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRecording = false;
  bool isPlaying = false;
  late final AudioRecorder audioRecord;
  String? _audioPath;
  List<Widget> note = [];
  late final AudioPlayer audioPlayer;
  late Timer timer;
  int segmentation = 1;
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();

  @override
  void initState() {
    audioRecord = AudioRecorder();
    audioPlayer = AudioPlayer();
    recorder.openRecorder();
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/star.jpg',
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            children: [
              Row(
                children: note,
              ),
              Row(
                children: note,
              ),
              TextButton(
                  onPressed: () async {
                    if (audioPlayer.playing) {
                      audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.setFilePath(_audioPath!);
                      audioPlayer.play();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: Icon(Icons.play_arrow)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          isRecording ? Icons.rectangle : Icons.mic,
          size: 25,
        ),
        onPressed: () async {
          if (isRecording) {
            String? filePath = await audioRecord.stop();
            recorder.stopRecorder();
            if (filePath != null) {
              setState(() {
                isRecording = false;
                _audioPath = filePath;
              });
            }
          } else {
            if (await audioRecord.hasPermission()) {
              final Directory appDir = await getApplicationDocumentsDirectory();
              final String path = p.join(appDir.path, 'record.wav');
              audioRecord.start(
                const RecordConfig(),
                path: path,
              );
              setState(() {
                isRecording = true;
                _audioPath = null;
              });
            }
          }
        },
      ),
    );
  }
}
