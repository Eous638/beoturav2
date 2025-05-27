import 'package:flutter/material.dart';

/// Component for displaying a prominent action prompt in an immersive tour
class PromptComponent extends StatelessWidget {
  final String text;

  const PromptComponent({
    super.key,
    required this.text, required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Subtle icon to indicate this is a prompt
          Icon(
            Icons.info_outline,
            color: Colors.black.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 12),

          // Prompt text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
