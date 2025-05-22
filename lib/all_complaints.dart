import 'package:flutter/material.dart';
import 'base_status_screen.dart';

class AllComplaintsScreen extends StatelessWidget {
  const AllComplaintsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseStatusScreen(
      status: 'All',
      statusColor: Colors.indigo,
      statusIcon: Icons.list_alt,
      showStatusFilter: true,
    );
  }
}
