import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'view/home_page.dart';

void main() => runApp(Piano());

class Piano extends StatelessWidget {
  const Piano({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
