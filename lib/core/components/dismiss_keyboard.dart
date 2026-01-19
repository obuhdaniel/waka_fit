import 'package:flutter/material.dart';

class DismissKeyboardBehavior extends StatelessWidget {
  final Widget child;

  const DismissKeyboardBehavior({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
