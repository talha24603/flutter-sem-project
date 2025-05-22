import 'package:flutter/material.dart';
import 'base_category_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseCategoryScreen(
      category: 'Maintenance',
      categoryColor: Colors.blue,
      categoryIcon: Icons.build,
    );
  }
}
