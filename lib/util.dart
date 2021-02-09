import 'package:flutter/material.dart';

class Bold extends StatelessWidget {
  final String text;
  final double size;

  Bold(this.text) : this.size = 14;

  Bold.withSize(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: this.size),
    );
  }
}
