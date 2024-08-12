import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:piano11/model/piano_sheet.dart';

class NoteSegment {
  List<dynamic> notes;
  List<dynamic> beats;
  double tempo;
  DateTime time;

  NoteSegment({
    required this.notes,
    required this.beats,
    required this.tempo,
    required this.time,
  });
}

Image dot = Image.asset(
  'assets/images/reddot.png',
  width: 20,
  height: 20,
);

class FlaskServices {
  static List<NoteSegment> noteSegments = [];
  static double tempo = 0;
  double firstTempo = 0;
  bool isFirstTempoSet = false;
  static List<int> rightHandSideNote = [];
  static List<int> leftHandSideNote = [];
  static List<int> weights = [];
  static int counter = 0;

  static List<Widget> notePositions = [];
  static double offsetY = littleStar.lineOffsetY[0].toDouble();
  static int lineIndex = 0;
  Function()? _onStateChange;

  void setOnStateChange(Function()? callback) {
    _onStateChange = callback;
  }

  void setStateLab() {
    if (_onStateChange != null) {
      _onStateChange!();
    }
  }

  Future<void> sendAudioSegment(List<int> audioBytes) async {
    print('Sending audio segment');
    var response = await http.post(
        Uri.parse('http://192.168.50.55:5000/audio_process'),
        body: audioBytes);
    print('receive response');
    setStateLab();
    // print(response.body);
    if (response.statusCode == 200) {
      setStateLab();
      // 成功傳送
      print('Audio segment sent successfully');
      audioRespondDecode(response);
      if (weights.isEmpty) {
        return;
      }
      // print(weights.length);
      print(weights);
      // print(rightHandSideNote);
      for (int i = 0; i < weights.length; i++) {
        if (weights.isEmpty) {
          break;
        }
        pushAudioNoteIntoStack(
            notePositions, rightHandSideNote[counter], weights[i]);
        if (_onStateChange != null) {
          _onStateChange!();
        }
        counter++;
        if (counter == rightHandSideNote.length) {
          counter = 0;
          notePositions.clear();
          if (_onStateChange != null) {
            _onStateChange!();
          }
        }
      }
    } else {
      print('Failed to send audio segment');
    }
  }

  Future<void> audioRespondDecode(var response) async {
    final jsonResponse = json.decode(response.body);
    List<String> notes = List<String>.from(jsonResponse['notes']);
    List<int> beats = List<int>.from(jsonResponse['beats']);
    tempo = jsonResponse['tempo'][0];
    if(isFirstTempoSet == false) {
      firstTempo = tempo;
      isFirstTempoSet = true;
    }
    if (_onStateChange != null) {
      _onStateChange!();
    }
    DateTime tempDate =
        DateFormat("yyyy-MM-dd hh:mm:ss").parse(jsonResponse['timeStamp']);
    noteSegments.add(
        NoteSegment(notes: notes, beats: beats, tempo: tempo, time: tempDate));

    weights = getWeight(notes);
  }

  List<int> getWeight(List<dynamic> notes) {
    List<int> weights = [];
    int simpleNote = 0;
    int weight = 0;
    //calculate the simple note
    for (int i = 0; i < notes.length; i++) {
      String note = notes[i].toString();
      if (note.startsWith('A')) {
        simpleNote = 9;
      } else if (note.startsWith('B')) {
        simpleNote = 11;
      } else if (note.startsWith('C')) {
        simpleNote = 0;
      } else if (note.startsWith('D')) {
        simpleNote = 2;
      } else if (note.startsWith('E')) {
        simpleNote = 4;
      } else if (note.startsWith('F')) {
        simpleNote = 5;
      } else if (note.startsWith('G')) {
        simpleNote = 7;
      }
      weight = simpleNote + (int.parse(note.substring(1)) + 1) * 12 - 60;
      weights.add(weight);
    }
    return weights;
  }

  void pushAudioNoteIntoStack(List<Widget> positions, int x, int y) {
    offsetY = littleStar.lineOffsetY[lineIndex].toDouble();
    double noteX = x / 2500 * 360 - 9;
    double noteY = offsetY - y * 1.45;
    if (noteX < 77) {
      lineIndex = lineIndex + 2;
    }
    notePositions.add(Positioned(left: noteX, top: noteY, child: dot));
    if (_onStateChange != null) {
      _onStateChange!();
    }
  }

  Future<void> sendImageAndGetNotePosition() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.50.55:5000/image_process'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);
    final jsonData = jsonDecode(responseBody.body);
    if (response.statusCode == 200) {
      print('Image sent successfully');
    } else {
      print('Failed to send image');
    }

    List<int> noteLine1 = List<int>.from(jsonData['note1']);
    List<int> noteLine2 = List<int>.from(jsonData['note2']);
    List<int> noteLine3 = List<int>.from(jsonData['note3']);
    List<int> noteLine4 = List<int>.from(jsonData['note4']);
    List<int> noteLine5 = List<int>.from(jsonData['note5']);
    List<int> noteLine6 = List<int>.from(jsonData['note6']);

    for (int note in noteLine1) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    for (int note in noteLine2) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    for (int note in noteLine3) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    for (int note in noteLine4) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    for (int note in noteLine5) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    for (int note in noteLine6) {
      note = (note.toDouble() / littleStar.width * 360).toInt();
    }
    rightHandSideNote = noteLine1 + noteLine3 + noteLine5;
    leftHandSideNote = noteLine2 + noteLine4 + noteLine6;
  }
}
