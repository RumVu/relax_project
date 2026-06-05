part of 'package:relax_app/main.dart';

class CatAvatar extends StatelessWidget {
  const CatAvatar({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.relax.border),
      ),
      child: CustomPaint(painter: PixelCatPainter(dark: context.dark)),
    );
  }
}

class PixelCatScene extends StatelessWidget {
  const PixelCatScene({super.key, required this.scene, this.height = 220});

  final CatScene scene;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: PixelScenePainter(scene: scene, dark: context.dark),
      ),
    );
  }
}
