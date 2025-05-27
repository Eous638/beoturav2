import 'package:flutter/material.dart';

/// Component for displaying rich paragraph text in an immersive tour
class ParagraphComponent extends StatelessWidget {
  final String text;

  const ParagraphComponent({
    super.key,
    required this.text, required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }
}
