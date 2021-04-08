import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
