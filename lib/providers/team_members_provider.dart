import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_stand/models/models.dart';

final teamMembersProvider = StateNotifierProvider<TeamMembersNotifier, List<TeamMember>>((ref) {
  return TeamMembersNotifier();
});

class TeamMembersNotifier extends StateNotifier<List<TeamMember>> {
  TeamMembersNotifier() : super([]) {
    _loadDemoMembers();
  }

  void _loadDemoMembers() {
    state = [
      TeamMember(
        id: 'demo-user-1',
        name: 'Alex Johnson',
        email: 'alex@example.com',
        role: 'Engineering Lead',
        integrations: {
          'github': 'alexj',
          'slack': 'U123456',
          'notion': 'alex-notion-id',
        },
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      TeamMember(
        id: 'demo-user-2',
        name: 'Sarah Chen',
        email: 'sarah@example.com',
        role: 'Product Designer',
        integrations: {
          'figma': 'sarah-figma',
          'slack': 'U234567',
          'notion': 'sarah-notion-id',
        },
        joinedAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      TeamMember(
        id: 'demo-user-3',
        name: 'Mike Rodriguez',
        email: 'mike@example.com',
        role: 'Full Stack Developer',
        integrations: {
          'github': 'miker',
          'slack': 'U345678',
          'notion': 'mike-notion-id',
        },
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  List<TeamMember> getMembersForTeam(String teamId, List<String> memberIds) {
    return state.where((member) => memberIds.contains(member.id)).toList();
  }
}