import 'package:flutter/material.dart';

class OnBoardingModel {
  const OnBoardingModel({
    required this.icon,
    required this.iconColor,
    required this.iconSurfaceColor,
    required this.title,
    required this.subTitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconSurfaceColor;
  final String title;
  final String subTitle;
}
