import 'package:flutter/material.dart';

class SwipeCardsBanner extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final VoidCallback onTap;

  const SwipeCardsBanner({
    super.key,
    required this.controller,
    required this.images,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
