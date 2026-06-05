part of 'package:relax_app/main.dart';

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: context.dark ? .88 : .96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: context.relax.glow.withValues(
              alpha: context.dark ? .12 : .24,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PixelIconBox extends StatelessWidget {
  const PixelIconBox({super.key, required this.icon, this.size = 46});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border),
      ),
      child: Icon(icon, color: RelaxTheme.purple),
    );
  }
}
