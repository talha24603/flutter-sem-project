import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class CleanlinessScreen extends StatelessWidget {
  const CleanlinessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Cleanliness',
      categoryColor: Colors.green,
      categoryIcon: Icons.cleaning_services,
    );
  }
}
