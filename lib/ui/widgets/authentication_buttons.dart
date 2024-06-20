import 'package:flutter/material.dart';

Widget authButtons({
    required String text,
    required VoidCallback onTap,
    required bool showProgress,
    required Color color,
    required Color textColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 49,
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: color,
          border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
        ),
        child: Center(
          child: (showProgress)?const CircularProgressIndicator(color: Color.fromARGB(255, 21, 85, 204),) :Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }