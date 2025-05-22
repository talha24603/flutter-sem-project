import 'package:flutter/material.dart';
import 'base_status_screen.dart';

class ResolvedComplaintsScreen extends StatelessWidget {
  const ResolvedComplaintsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseStatusScreen(
      status: 'Resolved',
      statusColor: Colors.green,
      statusIcon: Icons.check_circle,
    );
  }
}
