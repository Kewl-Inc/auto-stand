import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_stand/models/models.dart';

final standupUpdatesProvider = StateNotifierProvider<StandupUpdatesNotifier, List<StandupUpdate>>((ref) {
  return StandupUpdatesNotifier();
});

class StandupUpdatesNotifier extends StateNotifier<List<StandupUpdate>> {
  StandupUpdatesNotifier() : super([]);

  void addUpdate(StandupUpdate update) {
    state = [...state, update];
  }

  List<StandupUpdate> getUpdatesForTeam(String teamId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return state.where((update) {
      return update.date.isAfter(startOfDay) && 
             update.date.isBefore(endOfDay);
    }).toList();
  }
}