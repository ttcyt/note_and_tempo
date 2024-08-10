import 'package:flutter/material.dart';

class PianoSheet {
  String title;
  int height;
  int width;
  Image image;
  List<int> lineOffsetY;

  PianoSheet({
    required this.title,
    required this.height,
    required this.width,
    required this.image,
    required this.lineOffsetY,
  });
}

PianoSheet littleStar = PianoSheet(
  title: 'Little Star',
  height: 3499,
  width: 2499,
  image: Image.asset('assets/images/little_star.png'),
  lineOffsetY: [142, 182, 261, 301, 380, 420],
);
