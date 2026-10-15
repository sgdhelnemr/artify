import 'package:flutter/material.dart';

/// Shows an asset image, a network image, or a placeholder if empty/failed.
class PaintingImage extends StatelessWidget {
  final String path;
  final double height;
  const PaintingImage({super.key, required this.path, required this.height});

  Widget _placeholder(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Center(child: Icon(Icons.image, size: 48)),
      );

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder(context);

    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : SizedBox(
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              ),
        errorBuilder: (c, e, s) => _placeholder(c),
      );
    }

    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => _placeholder(c),
    );
  }
}
