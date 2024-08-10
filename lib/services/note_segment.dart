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

class Position {
  int x;
  int y;
  Widget child;

  Position({required this.x, required this.y, required this.child});
}

Image dot = Image.asset(
  'assets/images/reddot.png',
  width: 20,
  height: 20,
);

class FlaskServices {
  static List<NoteSegment> _noteSegments = [];

  static List<NoteSegment> get noteSegment => _noteSegments;
  static List<int> rightHandSideNote = [];
  static List<int> leftHandSideNote = [];
  static List<int> weights = [];
  static int counter = 0;
  static List<Position> positions = [];
  static Function? onStateChange;
  static List<Widget> notePositions = [];
  static double offsetY = littleStar.lineOffsetY[0].toDouble();
  static int lineIndex = 0;
  static setOnStateChange(Function? callback) {
    onStateChange = callback;
  }

  static Future<void> sendAudioSegment(List<int> audioBytes) async {
    var response = await http.post(
        Uri.parse('http://192.168.50.55:5000/audio_process'),
        body: audioBytes);

    print(response.body);
    if (response.statusCode == 200) {
      // 成功傳送
      print('Audio segment sent successfully');
      audioRespondDecode(response);
      if (weights.length == 0) {
        return;
      }
      print(weights.length);
      print(weights);
      print(rightHandSideNote);
      for (int i = 0; i < weights.length; i++) {
        if(weights.length == 0){
          return;
        }
        pushAudioNoteIntoStack(positions, rightHandSideNote[counter], weights[i]);
        counter++;
        if(counter == rightHandSideNote.length){
          counter = 0;
          positions = [];
        }
      }
    } else {
      print('Failed to send audio segment');
    }
  }

  static Future<void> audioRespondDecode(var response) async {
    final jsonResponse = json.decode(response.body);
    List<String> notes = List<String>.from(jsonResponse['notes']);
    List<int> beats = List<int>.from(jsonResponse['beats']);
    double tempo = jsonResponse['tempo'][0];
    DateTime tempDate =
        new DateFormat("yyyy-MM-dd hh:mm:ss").parse(jsonResponse['timeStamp']);
    _noteSegments.add(
        NoteSegment(notes: notes, beats: beats, tempo: tempo, time: tempDate));

    weights = getWeight(notes);
  }

  static List<int> getWeight(List<dynamic> notes) {
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

  static void pushAudioNoteIntoStack(List<Position> positions, int x, int y) {
    offsetY = littleStar.lineOffsetY[lineIndex].toDouble();
    double noteX = x / 2500 * 360 - 9;
    double noteY = offsetY - y * 1.45;
    if (noteX < 77) {
      lineIndex = lineIndex + 2;
    }
    positions.add(Position(x: noteX.toInt(), y: noteY.toInt(), child: dot));
    notePositions.add(Positioned(left: noteX, top: noteY, child: dot));
  }

  static Future<void> sendImageAndGetNotePosition() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    for (int note in noteLine2) {
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    for (int note in noteLine3) {
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    for (int note in noteLine4) {
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    for (int note in noteLine5) {
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    for (int note in noteLine6) {
      note = (note.toDouble() / 2500 * 360).toInt();
    }
    rightHandSideNote = noteLine1 + noteLine3 + noteLine5;
    leftHandSideNote = noteLine2 + noteLine4 + noteLine6;
  }
}
