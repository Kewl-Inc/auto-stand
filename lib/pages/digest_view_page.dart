import 'package:flutter/material.dart';

class DigestViewPage extends StatelessWidget {
  final String teamId;
  final DateTime date;
  
  const DigestViewPage({
    super.key,
    required this.teamId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Digest'),
      ),
      body: Center(
        child: Text('Digest for team: $teamId on ${date.toLocal()}'),
      ),
    );
  }
}