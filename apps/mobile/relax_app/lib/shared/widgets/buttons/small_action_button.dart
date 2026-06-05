part of 'package:relax_app/main.dart';

class SmallActionButton extends StatelessWidget {
  const SmallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 42,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: context.dark
              ? const Color(0xFFE6DFFF)
              : RelaxTheme.purple,
          side: BorderSide(color: context.relax.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: FittedBox(child: Text(label)),
      ),
    );
  }
}
