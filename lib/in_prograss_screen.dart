import 'package:flutter/material.dart';
import 'base_status_screen.dart';

class InProgressComplaintsScreen extends StatelessWidget {
  const InProgressComplaintsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseStatusScreen(
      status: 'In Progress',
      statusColor: Colors.blue,
      statusIcon: Icons.loop,
    );
  }
}
  