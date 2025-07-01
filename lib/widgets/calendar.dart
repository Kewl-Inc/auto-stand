import 'package:flutter/material.dart';
import 'package:base_project/models/models.dart';

class CalendarEventsWidget extends StatelessWidget {
  final List<CalendarEvent> events;
  final DateTime selectedDate;
  final VoidCallback onDateChanged;
  final VoidCallback onRefresh;

  const CalendarEventsWidget({
    super.key,
    required this.events,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(
          child:
              events.isEmpty
                  ? _buildEmptyState(context)
                  : _buildEventsList(context),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // This will be handled by the parent widget
              onDateChanged();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && picked != selectedDate) {
                  // This will be handled by the parent widget
                  onDateChanged();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // This will be handled by the parent widget
              onDateChanged();
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events for this date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You have no calendar events scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                event.isAllDay ? Icons.all_inclusive : Icons.schedule,
                color: Colors.white,
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.description?.isNotEmpty == true)
                  Text(
                    event.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (event.location?.isNotEmpty == true)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                Text(
                  event.isAllDay
                      ? 'All Day'
                      : '${event.formattedStartTime} - ${event.formattedEndTime}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            isThreeLine:
                event.description?.isNotEmpty == true ||
                event.location?.isNotEmpty == true,
          ),
        );
      },
    );
  }
}
