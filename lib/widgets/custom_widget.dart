import 'package:flutter/material.dart';

class CustomWidget extends StatelessWidget {
  final dynamic leadingIcon; // Changed type to dynamic
  final String mainText;
  final String descriptionText;
  final IconData suffixIcon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double borderRadius;
  final double iconSize; // New parameter for icon size
  final double suffixSize;

  const CustomWidget({
    super.key,
    required this.leadingIcon,
    required this.mainText,
    required this.descriptionText,
    required this.suffixIcon,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 0.0,
    this.iconSize = 40.0,
    this.suffixSize = 20, // Default size is 40.0
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon is IconData) // Check if leadingIcon is IconData
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  leadingIcon,
                  size: iconSize,
                  color: Colors.grey,
                ),
              ),
            if (leadingIcon
                is String) // Check if leadingIcon is String (image path)
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(
                  leadingIcon,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 17),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    descriptionText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                suffixIcon,
                size: suffixSize,
              ),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
