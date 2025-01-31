import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/widget/image_placeholder_widget.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget(this.url,
      {this.width = 30,
      this.height = 30,
      this.imgHeight = 150,
      this.imgWidth = double.infinity,
      super.key});

  final String url;
  final double height;
  final double width;
  final double imgHeight;
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => Center(
          child: SizedBox(
              width: width,
              height: height,
              child: const CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => ImagePlaceHolder(
          imgWidth: imgWidth,
          imgHeight: imgHeight,
        ),
        // Assuming you have imageUrl in your Product model
        fit: BoxFit.cover,
        height: imgHeight,
        width: imgWidth,
      );
    } else {
      return ImagePlaceHolder(
        imgWidth: imgWidth,
        imgHeight: imgHeight,
      );
    }
  }
}
