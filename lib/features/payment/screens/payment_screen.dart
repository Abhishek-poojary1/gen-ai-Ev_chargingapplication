import 'package:flutter/material.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/charging_point.dart';

class PaymentScreen extends StatefulWidget {
  final ChargingPoint chargingPoint;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.chargingPoint,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'upi';
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'color': Colors.green,
    },
    {
      'id': 'cash',
      'name': 'Cash on Arrival',
      'icon': Icons.money,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final duration = widget.endTime.difference(widget.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow('Charging Point', widget.chargingPoint.hostName),
                  _SummaryRow('Address', widget.chargingPoint.address),
                  _SummaryRow('Socket Type', widget.chargingPoint.socketTypeDisplay),
                  _SummaryRow('Start Time', _formatDateTime(widget.startTime)),
                  _SummaryRow('End Time', _formatDateTime(widget.endTime)),
                  const Divider(),
                  _SummaryRow(
                    'Duration',
                    '${hours}h ${minutes}min',
                    isHighlighted: true,
                  ),
                  _SummaryRow(
                    'Rate',
                    '₹${widget.chargingPoint.pricePerHour}/hour',
                  ),
                  const Divider(),
                  _SummaryRow(
                    'Total Amount',
                    '₹${widget.totalPrice.toStringAsFixed(2)}',
                    isHighlighted: true,
                    isPrice: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Selection
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._paymentMethods.map((method) => _PaymentMethodCard(method)),
            
            const Spacer(),
            
            // Process Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Processing...'),
                        ],
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SummaryRow(String label, String value, {bool isHighlighted = false, bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? Theme.of(context).colorScheme.primary : null,
              fontSize: isPrice ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _PaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? method['color']?.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? method['color'] : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              method['icon'],
              color: isSelected ? method['color'] : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? method['color'] : Colors.grey.shade800,
                    ),
                  ),
                  if (method['id'] == 'cash') ...[
                    Text(
                      'Pay when you arrive',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: method['color'],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been confirmed.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Booking ID: #${DateTime.now().millisecondsSinceEpoch}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close success dialog
                Navigator.of(context).pop(); // Go back to booking screen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}
