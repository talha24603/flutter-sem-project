import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class NoiseScreen extends StatelessWidget {
  const NoiseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Noise',
      categoryColor: Colors.orange,
      categoryIcon: Icons.volume_up,
    );
  }
}
