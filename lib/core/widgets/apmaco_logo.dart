import 'package:apma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ApmacoLogo extends StatelessWidget {
  final double width;
  final double height;

  const ApmacoLogo({super.key, this.width = 200, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'apma',
                style: TextStyle(
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                  fontFamily: 'Vazir',
                ),
              ),
              TextSpan(
                text: 'co',
                style: TextStyle(
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGray,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
