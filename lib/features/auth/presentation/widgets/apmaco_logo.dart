import 'package:flutter/material.dart';

class ApmacoLogo extends StatelessWidget {
  final double width;
  final double height;

  const ApmacoLogo({super.key, this.width = 200, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/apma_logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
