import 'package:flutter/material.dart';
import '../pixel/pixel_panel.dart';

class MiniMoment extends StatelessWidget {
  const MiniMoment({
    super.key,
    required this.title,
    required this.time,
    required this.minutes,
    required this.icon,
  });

  final String title;
  final String time;
  final String minutes;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelIconBox(icon: icon, size: 52),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(time, style: Theme.of(context).textTheme.bodyMedium),
          Text(minutes, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
