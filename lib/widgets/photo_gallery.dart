import 'package:flutter/material.dart';

class PhotoGallery extends StatelessWidget {
  final List<String> photoUrls;
  const PhotoGallery({super.key, required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return const Text('No hay fotos disponibles');
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(photoUrls[i], width: 120, fit: BoxFit.cover),
        ),
      ),
    );
  }
} 