import 'package:flutter/material.dart';

class TempoIndicator extends StatefulWidget {
  TempoIndicator({super.key, required this.tempo});
  double tempo;

  @override
  State<TempoIndicator> createState() => _TempoIndicatorState();
}

class _TempoIndicatorState extends State<TempoIndicator> {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: widget.tempo / 200,
      backgroundColor: Color(0xFFB4E380),
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C946F)),
      semanticsLabel: 'TEMPO ${widget.tempo} BPM',
    );
  }
}
