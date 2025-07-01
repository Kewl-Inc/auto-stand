import 'package:base_project/models/models.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:logger/logger.dart';

class DeviceCalendarService implements CalendarServiceInterface {
  final Logger _logger = Logger();
  final DeviceCalendarPlugin _deviceCalendar = DeviceCalendarPlugin();

  String? _selectedCalendarId;
  bool _hasPermissions = false;

  String? get selectedCalendarId => _selectedCalendarId;

  @override
  Future<bool> isAvailable() async {
    return await hasPermissions();
  }

  @override
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    if (!_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) {
        throw Exception('Calendar permissions not granted');
      }
    }

    if (_selectedCalendarId == null) {
      await _selectDefaultCalendar();
      if (_selectedCalendarId == null) {
        throw Exception('No calendar available');
      }
    }

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      _logger.d('Fetching events for date: ${date.toIso8601String()}');

      final eventsResult = await _deviceCalendar.retrieveEvents(
        _selectedCalendarId!,
        RetrieveEventsParams(startDate: startOfDay, endDate: endOfDay),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        final events = eventsResult.data!;
        _logger.d(
          'Found ${events.length} events for date ${date.toIso8601String()}',
        );

        return events.map((event) => _convertToCalendarEvent(event)).toList();
      } else {
        _logger.w('No events found or error occurred: ${eventsResult.errors}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching events for date: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) {
        throw Exception('Calendar permissions not granted');
      }
    }

    if (_selectedCalendarId == null) {
      await _selectDefaultCalendar();
      if (_selectedCalendarId == null) {
        throw Exception('No calendar available');
      }
    }

    try {
      _logger.d(
        'Fetching events from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );

      final eventsResult = await _deviceCalendar.retrieveEvents(
        _selectedCalendarId!,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        final events = eventsResult.data!;
        _logger.d('Found ${events.length} events in date range');

        return events.map((event) => _convertToCalendarEvent(event)).toList();
      } else {
        _logger.w('No events found or error occurred: ${eventsResult.errors}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching events for date range: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<bool> hasPermissions() async {
    try {
      final permissionsGranted = await _deviceCalendar.hasPermissions();
      _hasPermissions =
          permissionsGranted.isSuccess && permissionsGranted.data!;
      _logger.d('Calendar permissions granted: $_hasPermissions');
      return _hasPermissions;
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      _logger.d('Requesting calendar permissions...');
      final permissionsGranted = await _deviceCalendar.requestPermissions();

      if (permissionsGranted.isSuccess && permissionsGranted.data!) {
        _hasPermissions = true;
        _logger.d('Calendar permissions granted successfully');

        // Get available calendars and select the first one
        await _selectDefaultCalendar();
        return true;
      } else {
        _logger.w('Calendar permissions denied');
        return false;
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _selectDefaultCalendar() async {
    try {
      final calendarsResult = await _deviceCalendar.retrieveCalendars();

      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        final calendars = calendarsResult.data!;

        // Try to find the default calendar (usually the first one)
        Calendar? defaultCalendar;

        for (final calendar in calendars) {
          if (calendar.isDefault == true) {
            defaultCalendar = calendar;
            break;
          }
        }

        // If no active calendar found, use the first one
        if (defaultCalendar == null && calendars.isNotEmpty) {
          defaultCalendar = calendars.first;
        }

        if (defaultCalendar != null) {
          _selectedCalendarId = defaultCalendar.id;
          _logger.d(
            'Selected calendar: ${defaultCalendar.name} (${defaultCalendar.id})',
          );
        } else {
          _logger.w('No calendars available');
        }
      } else {
        _logger.e('Failed to retrieve calendars: ${calendarsResult.errors}');
      }
    } catch (e) {
      _logger.e('Error selecting default calendar: $e');
    }
  }

  /// Convert device calendar event to our CalendarEvent model
  CalendarEvent _convertToCalendarEvent(Event event) {
    final startTime = event.start ?? DateTime.now();
    final endTime = event.end ?? startTime.add(const Duration(hours: 1));

    // Determine if it's an all-day event
    final isAllDay = event.allDay ?? false;

    // Extract participants from attendees
    final List<String> participants =
        event.attendees == null
            ? []
            : event.attendees!
                .where((attendee) => attendee?.emailAddress != null)
                .map((attendee) => attendee!.emailAddress!)
                .toList();

    return CalendarEvent(
      id: event.eventId ?? '',
      title: event.title ?? 'No Title',
      description: event.description,
      startTime: startTime,
      endTime: endTime,
      location: event.location,
      isAllDay: isAllDay,
      participants: participants,
    );
  }

  /// Get available calendars
  Future<List<Calendar>> getAvailableCalendars() async {
    if (!_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) {
        throw Exception('Calendar permissions not granted');
      }
    }

    try {
      final calendarsResult = await _deviceCalendar.retrieveCalendars();

      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        return calendarsResult.data!;
      } else {
        _logger.e('Failed to retrieve calendars: ${calendarsResult.errors}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting available calendars: $e');
      throw Exception('Failed to get calendars: $e');
    }
  }

  /// Select a specific calendar
  Future<void> selectCalendar(String calendarId) async {
    _selectedCalendarId = calendarId;
    _logger.d('Selected calendar: $calendarId');
  }
}
