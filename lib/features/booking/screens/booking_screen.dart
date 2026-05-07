import 'package:flutter/material.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/charging_point.dart';
import '../../payment/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final ChargingPoint? chargingPoint;

  const BookingScreen({super.key, this.chargingPoint});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Sample bookings for demo
  final List<Booking> _bookings = [
    Booking(
      id: '1',
      chargingPointId: '1',
      userId: 'user1',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: BookingStatus.completed,
      totalPrice: 50.0,
    ),
    Booking(
      id: '2',
      chargingPointId: '2',
      userId: 'user1',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      status: BookingStatus.confirmed,
      totalPrice: 30.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // If a charging point is provided, show booking form
    if (widget.chargingPoint != null) {
      return _buildBookingForm();
    }

    // Otherwise show existing bookings
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find charging points on the map and book your spot!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return _BookingCard(booking: booking);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewBookingDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookingForm() {
    final chargingPoint = widget.chargingPoint!;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${chargingPoint.hostName}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charging Point Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chargingPoint.hostName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Address: ${chargingPoint.address}'),
                  Text('Socket: ${chargingPoint.socketTypeDisplay}'),
                  Text('Price: ₹${chargingPoint.pricePerHour}/hour'),
                  Text('Rating: ${chargingPoint.rating}⭐'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Booking Form
            Text(
              'Select Date & Time',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Select Date'),
              subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Start Time'),
              subtitle: Text(selectedStartTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedStartTime,
                );
                if (time != null) {
                  selectedStartTime = time;
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('End Time'),
              subtitle: Text(selectedEndTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedEndTime,
                );
                if (time != null) {
                  selectedEndTime = time;
                }
              },
            ),

            const Spacer(),

            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final startDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedStartTime.hour,
                    selectedStartTime.minute,
                  );
                  final endDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  );
                  final hours = endDateTime.difference(startDateTime).inHours;
                  final totalPrice = hours * chargingPoint.pricePerHour;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        chargingPoint: chargingPoint,
                        startTime: startDateTime,
                        endTime: endDateTime,
                        totalPrice: totalPrice,
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Booking'),
        content: const Text(
            'Select a charging point from the map to create a new booking.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${booking.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDateTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${booking.duration.inMinutes} minutes',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (booking.status == BookingStatus.confirmed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Cancel booking
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to charging point
                      },
                      child: const Text('Navigate'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.inProgress:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
