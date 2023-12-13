import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {

  const ShimmerWidget.circular({
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder()
  });

  const ShimmerWidget.rectangular({
    this.width = double.infinity,
    required this.height,
  }) : this.shapeBorder = const RoundedRectangleBorder();

  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.4),
      highlightColor: Colors.grey.withOpacity(0.9),
      child: Container(
        height: height,
        width: width,
        decoration: ShapeDecoration(
          color: Colors.grey[400],
          shape: shapeBorder
        ),
      ),
  );
}