import 'package:googleapis/calendar/v3.dart' as calendar_api;
import 'package:intl/intl.dart';

abstract class CalendarServiceInterface {
  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date);

  /// Get events for a date range
  Future<List<CalendarEvent>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Check if the service is available/authenticated
  Future<bool> isAvailable();
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;

  final String? description;
  final String? location;
  final List<String> participants;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.description,
    this.location,
    this.participants = const [],
  });

  String get formattedStartTime {
    if (isAllDay) return 'All Day';
    return DateFormat('HH:mm').format(startTime);
  }

  String get formattedEndTime {
    if (isAllDay) return '';
    return DateFormat('HH:mm').format(endTime);
  }

  factory CalendarEvent.fromGoogleEvent(calendar_api.Event event) {
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;
    if (start == null || end == null) {
      throw Exception('Event has no start or end time: $event');
    }

    final isAllDay = event.start?.date != null;

    // Extract participants from attendees
    final participants =
        event.attendees
            ?.where((attendee) => attendee.email != null)
            .map((attendee) => attendee.email!)
            .toList() ??
        [];

    return CalendarEvent(
      id: event.id ?? '',
      title: event.summary ?? 'No Title',
      description: event.description,
      startTime: start,
      endTime: end,
      location: event.location,
      isAllDay: isAllDay,
      participants: participants,
    );
  }
}
