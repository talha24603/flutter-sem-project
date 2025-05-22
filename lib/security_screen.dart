import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Security',
      categoryColor: Colors.red,
      categoryIcon: Icons.security,
    );
  }
}
