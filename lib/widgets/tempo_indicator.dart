import 'package:flutter/material.dart';

AlwaysStoppedAnimation<Color>  alarm = const AlwaysStoppedAnimation<Color> (Color(0xFFF5004F));
AlwaysStoppedAnimation<Color>  safe = const AlwaysStoppedAnimation<Color>(Color(0xFF6C946F));
class TempoIndicator extends StatefulWidget {
  const TempoIndicator({super.key, required this.tempo, required this.firstTempo});
  final double tempo;
  final double firstTempo;


  @override
  State<TempoIndicator> createState() => _TempoIndicatorState();
}

class _TempoIndicatorState extends State<TempoIndicator> {
  bool checkTempoStateSafety() {
    if (widget.tempo < widget.firstTempo+3 && widget.tempo > widget.firstTempo-3) {
      return true;
    } else {
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: double.parse((widget.tempo / 200).toStringAsFixed(1)),
      backgroundColor: const Color(0xFFB4E380),
      valueColor: checkTempoStateSafety() ? safe : alarm,
      semanticsLabel: 'TEMPO ${widget.tempo} BPM',
    );
  }
}
