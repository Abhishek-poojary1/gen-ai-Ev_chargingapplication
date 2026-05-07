import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/charging_point.dart';
import '../../../services/charging_calculator.dart';
import '../../../themes/app_theme.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final ChargingPoint chargingPoint;
  final DateTime startTime;
  final DateTime endTime;

  const BookingConfirmationScreen({
    super.key,
    required this.chargingPoint,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isProcessing = false;
  Booking? _confirmedBooking;

  @override
  Widget build(BuildContext context) {
    final duration = widget.endTime.difference(widget.startTime);
    final estimate = ChargingCalculator.getChargingEstimate(
      socketType: widget.chargingPoint.socketType,
      chargingTime: duration,
      pricePerHour: widget.chargingPoint.pricePerHour,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charging Point Info Card
            _buildChargingPointCard(),
            const SizedBox(height: 16),
            
            // Booking Details Card
            _buildBookingDetailsCard(duration),
            const SizedBox(height: 16),
            
            // Charging Estimate Card
            _buildChargingEstimateCard(estimate),
            const SizedBox(height: 16),
            
            // Payment Method Card
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),
            
            // Action Buttons
            if (_confirmedBooking == null) ...[
              _buildActionButton(estimate),
            ] else ...[
              _buildSuccessCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargingPointCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.electric_bolt,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chargingPoint.hostName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.chargingPoint.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.chargingPoint.isAvailable 
                        ? AppTheme.successColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.chargingPoint.isAvailable ? 'Available' : 'Busy',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.electrical_services,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(widget.chargingPoint.socketTypeDisplay),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('₹${widget.chargingPoint.pricePerHour}/hour'),
                const SizedBox(width: 16),
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text('${widget.chargingPoint.rating}⭐'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(Duration duration) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: '${widget.startTime.day}/${widget.startTime.month}/${widget.startTime.year}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Start Time',
              value: '${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.schedule,
              label: 'End Time',
              value: '${widget.endTime.hour.toString().padLeft(2, '0')}:${widget.endTime.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.timer,
              label: 'Duration',
              value: '${duration.inMinutes} minutes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargingEstimateCard(ChargingEstimate estimate) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charging Estimate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.battery_charging_full,
              label: 'Energy Added',
              value: estimate.energyDisplay,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.directions_bike,
              label: 'Range Added',
              value: estimate.rangeDisplay,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.speed,
              label: 'Charging Speed',
              value: estimate.chargingSpeedDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Cash on Arrival'),
              value: 'cash',
              groupValue: 'cash',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('UPI Payment'),
              value: 'upi',
              groupValue: 'cash',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Credit/Debit Card'),
              value: 'card',
              groupValue: 'cash',
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ChargingEstimate estimate) {
    return Column(
      children: [
        // Price Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                estimate.priceDisplay,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Confirm Booking Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            child: _isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Processing...'),
                    ],
                  )
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.successColor,
          ).animate().scale(duration: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Booking Confirmed!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking ID: ${_confirmedBooking!.id.substring(0, 8).toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate booking processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _confirmedBooking = Booking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        chargingPointId: widget.chargingPoint.id,
        userId: 'user1',
        startTime: widget.startTime,
        endTime: widget.endTime,
        status: BookingStatus.confirmed,
        totalPrice: ChargingCalculator.calculatePrice(
          widget.chargingPoint.socketType,
          widget.endTime.difference(widget.startTime),
          widget.chargingPoint.pricePerHour,
        ),
      );
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Booking confirmed successfully!'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
