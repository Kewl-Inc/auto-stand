import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_stand/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  return TeamsNotifier();
});

class TeamsNotifier extends StateNotifier<List<Team>> {
  TeamsNotifier() : super([]) {
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = prefs.getString('teams');
    if (teamsJson != null) {
      final teamsList = jsonDecode(teamsJson) as List;
      state = teamsList.map((json) => Team.fromJson(json)).toList();
    } else {
      // Create a demo team for testing
      _createDemoTeam();
    }
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = jsonEncode(state.map((team) => team.toJson()).toList());
    await prefs.setString('teams', teamsJson);
  }

  void addTeam(Team team) {
    state = [...state, team];
    _saveTeams();
  }

  void updateTeam(String teamId, Team updatedTeam) {
    state = state.map((team) {
      return team.id == teamId ? updatedTeam : team;
    }).toList();
    _saveTeams();
  }

  void deleteTeam(String teamId) {
    state = state.where((team) => team.id != teamId).toList();
    _saveTeams();
  }

  void updateTemplateSections(String teamId, List<TemplateSection> sections) {
    state = state.map((team) {
      if (team.id == teamId) {
        return team.copyWith(templateSections: sections);
      }
      return team;
    }).toList();
    _saveTeams();
  }

  void _createDemoTeam() {
    final demoTeam = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Demo Team',
      description: 'A demo team to showcase AutoStand features',
      memberIds: ['demo-user-1', 'demo-user-2', 'demo-user-3'],
      ownerId: 'demo-user-1',
      templateSections: TemplateSection.defaultSections,
      settings: const TeamSettings(),
      createdAt: DateTime.now(),
    );
    addTeam(demoTeam);
  }
}