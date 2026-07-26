import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/colors.dart';

class HorizontalSmallListViewItemModel {
  final String? categoryId;
  final String title;
  final String image;
  final bool isNetworkImage;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  HorizontalSmallListViewItemModel({
    this.categoryId,
    required this.title,
    required this.image,
    this.isNetworkImage = false,
    this.textColor = TColors.white,
    this.backgroundColor,
    this.onTap,
  });
}
