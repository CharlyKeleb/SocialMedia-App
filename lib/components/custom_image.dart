import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/widgets/indicators.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  CustomImage({
    this.imageUrl,
    this.height = 100.0,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      placeholder: (context, url) => circularProgress(context),
      errorWidget: (context, url, error) {
        return Icon(Icons.error);
      },
      height: height,
      fit: fit,
      width: width,
    );
  }
}
