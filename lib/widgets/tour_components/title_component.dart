import 'package:flutter/material.dart';

/// Component for displaying stylized titles in an immersive tour
class TitleComponent extends StatelessWidget {
  final String text;

  const TitleComponent({
    super.key,
    required this.text, required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 24),
      width: double.infinity,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
          letterSpacing: -0.5,
          height: 1.1,
        ),
      ),
    );
  }
}
