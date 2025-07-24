import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? icon; // Make IconData optional
  final VoidCallback onPressed;
  final double borderRadius;
  final bool pass;
  final double size;
  final FontWeight fontWeight;
  final double height; // Height parameter for the text field

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onPressed,
    this.height = 50, // Default height if none is provided
    this.pass = false,
    this.icon, // Make IconData optional
    this.borderRadius = 8.0,
    this.size = 15,
    this.fontWeight = FontWeight.w300,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cardColor),
      ),
      height:
          height, // Set the height of the container using the height parameter
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: size, fontWeight: fontWeight),
              controller: controller,
              obscureText: pass,
              decoration: InputDecoration(
                hintText: labelText,
                border: InputBorder.none,
              ),
            ),
          ),
          if (icon != null)
            IconButton(
              onPressed: onPressed,
              icon: Icon(icon),
            ), // Show IconButton if icon is not null
        ],
      ),
    );
  }
}
