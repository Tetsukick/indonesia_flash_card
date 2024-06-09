// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {

  const ShimmerWidget.circular({Key? key, 
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  }) : super(key: key);

  const ShimmerWidget.rectangular({Key? key, 
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder(), super(key: key);

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
          shape: shapeBorder,
        ),
      ),
  );
}
