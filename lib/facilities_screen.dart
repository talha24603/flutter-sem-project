import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Facilities',
      categoryColor: Colors.teal,
      categoryIcon: Icons.apartment,
    );
  }
}
