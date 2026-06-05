import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class AppScroll extends StatelessWidget {
  const AppScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.dark
              ? const [Color(0xFF121728), Color(0xFF171B2C)]
              : const [Color(0xFFFDFBFF), Color(0xFFF1EDFF)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
        child: child,
      ),
    );
  }
}
