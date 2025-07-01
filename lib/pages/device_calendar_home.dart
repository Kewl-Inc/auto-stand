import 'package:auto_stand/services/device_calendar.dart';
import 'package:auto_stand/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:auto_stand/models/models.dart';
import 'package:logger/logger.dart';

class DeviceCalendarHomePage extends StatefulWidget {
  const DeviceCalendarHomePage({super.key});

  @override
  State<DeviceCalendarHomePage> createState() => _DeviceCalendarHomePageState();
}

class _DeviceCalendarHomePageState extends State<DeviceCalendarHomePage> {
  final Logger _logger = Logger();
  final DeviceCalendarService _calendarService = DeviceCalendarService();

  bool _isAuthorized = false;
  bool _isLoading = false;
  List<CalendarEvent> _events = [];
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hasPermissions = await _calendarService.hasPermissions();
      setState(() {
        _isAuthorized = hasPermissions;
      });

      if (hasPermissions) {
        await _loadEvents();
      }
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      setState(() {
        _errorMessage = 'Error checking permissions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Device Calendar'),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showCalendarSettings,
              tooltip: 'Calendar Settings',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (!_isAuthorized) {
      return _buildPermissionPrompt();
    }

    return CalendarEventsWidget(
      events: _events,
      selectedDate: _selectedDate,
      onDateChanged: _handleDateChange,
      onRefresh: _loadEvents,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Device Calendar Access',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This app needs permission to access your device calendar to display your events',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Grant Calendar Permission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_isAuthorized) {
      return null;
    }

    return FloatingActionButton(
      onPressed: _loadEvents,
      tooltip: 'Refresh Events',
      child: const Icon(Icons.refresh),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _logger.d('Requesting calendar permissions...');
      final granted = await _calendarService.requestPermissions();

      if (granted) {
        setState(() {
          _isAuthorized = true;
          _errorMessage = '';
        });
        await _loadEvents();
        _logger.d('Calendar permissions granted successfully');
      } else {
        setState(() {
          _errorMessage =
              'Calendar permissions were denied. Please enable them in your device settings.';
        });
        _logger.w('Calendar permissions denied');
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      setState(() {
        _errorMessage = 'Error requesting permissions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (!_isAuthorized) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final events = await _calendarService.getEventsForDate(_selectedDate);
      setState(() {
        _events = events;
      });
      _logger.d(
        'Loaded ${events.length} events for ${_selectedDate.toIso8601String()}',
      );
    } catch (e) {
      _logger.e('Error loading events: $e');
      setState(() {
        _errorMessage = 'Failed to load events: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleDateChange() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadEvents();
    }
  }

  void _showCalendarSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Calendar Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Calendar: ${_calendarService.selectedCalendarId ?? 'None'}',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _showCalendarSelector();
                  },
                  child: const Text('Select Calendar'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _showCalendarSelector() async {
    try {
      final calendars = await _calendarService.getAvailableCalendars();

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Calendar'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: calendars.length,
                  itemBuilder: (context, index) {
                    final calendar = calendars[index];
                    return ListTile(
                      title: Text(calendar.name ?? 'Unknown Calendar'),
                      subtitle: Text(calendar.accountName ?? ''),
                      trailing:
                          calendar.isDefault == true
                              ? const Icon(Icons.star, color: Colors.amber)
                              : null,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _calendarService.selectCalendar(calendar.id!);
                        await _loadEvents();
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );
    } catch (e) {
      _logger.e('Error showing calendar selector: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading calendars: $e')));
      }
    }
  }
}
