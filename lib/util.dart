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

class ImageWithUrl extends StatelessWidget {
  final String url;

  ImageWithUrl(this.url);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      errorBuilder: (context, exception, stackTrace) => Icon(Icons.error),
    );
  }
}
