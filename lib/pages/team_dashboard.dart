import 'package:flutter/material.dart';

class TeamDashboard extends StatelessWidget {
  final String teamId;
  
  const TeamDashboard({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Dashboard'),
      ),
      body: Center(
        child: Text('Team Dashboard for team: $teamId'),
      ),
    );
  }
}