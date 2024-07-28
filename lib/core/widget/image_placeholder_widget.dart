import 'package:flutter/material.dart';

class ImagePlaceHolder extends StatelessWidget {
  const ImagePlaceHolder({
    this.imgHeight = 150,
    this.imgWidth = double.infinity,
    super.key,
  });

  final double imgHeight;
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/placeholder.jpeg',
      width: imgWidth,
      height: imgHeight,
    );
  }
}
