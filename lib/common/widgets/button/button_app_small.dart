import 'package:flutter/material.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';

class AppButtonSmall extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double ? height;
  const AppButtonSmall({
    required this.onPressed,
    required this.title,
    this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(250, height ?? 50),
      ), 
      child: Text(
        title,
        style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: context.isDarkMode? Colors.white : Colors.black
                )
      )
    );
  }
}