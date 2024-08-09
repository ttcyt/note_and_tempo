import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:piano11/class/note_segment.dart';
import 'package:piano11/class/audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioServices audioServices = AudioServices();
  bool isRecording = false;
  bool isPlaying = false;
  late List<String> paths = [];
  Stack stack = Stack();

  double offsetRow1x = 75;
  double offsetRow1y = 142;
  double offsetRow2x = 37;
  double offsetRow2y = 261;
  double offsetRow3x = 37;
  double offsetRow3y = 380;

  // one note 3 offset  x16
  double moniterWidth = 360;
  double moniterHeight = 784;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioServices = AudioServices();
    audioServices.audioRecord = AudioRecorder();
    audioServices.audioPlayer = AudioPlayer();
    paths = audioServices.paths;
    FlaskServices.setOnStateChange(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    audioServices.audioRecord.dispose();
    audioServices.audioPlayer.dispose();
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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextButton(
                    onPressed: () async {
                      if (audioServices.audioPlayer.playing) {
                        audioServices.audioPlayer.stop();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await audioServices.audioPlayer
                            .setFilePath(paths[0]);
                        audioServices.audioPlayer.play();
                        print(paths.length);
                        print(MediaQuery.of(context).size.width);
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    child: const Icon(Icons.play_arrow)),
              ],
            ),
          ),
          Stack(
            children: FlaskServices.notePositions,
          ),
          const Padding(
            padding:  EdgeInsets.only(top:600),
            child: TextButton(
                onPressed: FlaskServices.sendImageAndGetNotePosition,
                child: Icon(
                  Icons.airplanemode_active,
                  size: 50,
                  color: Colors.black,
                )),
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
              setState(() {
                isRecording = false;
              });
              audioServices.stopRecording();
            } else {
              setState(() {
                isRecording = true;
              });
              audioServices.startRecording();
            }
          }),
    );
  }
}
