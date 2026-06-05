part of 'package:relax_app/main.dart';

class CatAvatar extends StatelessWidget {
  const CatAvatar({super.key, this.size = 84, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.relax.border),
      ),
      child: url == null
          ? CustomPaint(painter: PixelCatPainter(dark: context.dark))
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CustomPaint(
                  painter: PixelCatPainter(dark: context.dark),
                );
              },
            ),
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
