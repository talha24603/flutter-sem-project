import 'package:flutter/material.dart';
import 'base_status_screen.dart';

class PendingComplaintsScreen extends StatelessWidget {
  const PendingComplaintsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseStatusScreen(
      status: 'Pending',
      statusColor: Colors.orange,
      statusIcon: Icons.pending_actions,
    );
  }
}
