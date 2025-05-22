import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Staff',
      categoryColor: Colors.purple,
      categoryIcon: Icons.people,
    );
  }
}
