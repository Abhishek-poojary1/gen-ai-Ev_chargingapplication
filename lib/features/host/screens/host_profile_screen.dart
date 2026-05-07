import 'package:flutter/material.dart';
import '../../../core/models/charging_point.dart';
import 'package:latlong2/latlong.dart';
import 'host_registration_screen.dart';
import 'add_charging_point_screen.dart';
import '../../../core/providers/charging_point_provider.dart';
import 'package:provider/provider.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  bool _isHost = false;
  bool _isAvailable = true;
  ChargingPoint? _myChargingPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isHost) ...[
              _BecomeHostCard(),
            ] else ...[
              _HostInfoCard(),
              const SizedBox(height: 16),
              _AvailabilityToggle(),
              const SizedBox(height: 16),
              if (_myChargingPoint != null) ...[
                _ChargingPointCard(_myChargingPoint!),
                const SizedBox(height: 16),
              ],
              _ManageChargingPointCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _BecomeHostCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.electric_bolt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Become a Charging Host',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'List your power socket and earn extra income while helping EV users in your community.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _becomeHost,
              icon: const Icon(Icons.add),
              label: const Text('Register as Host'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _HostInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ravi Kumar',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Charging Host',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.book,
                    label: 'Total Bookings',
                    value: '24',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    label: 'Earned',
                    value: '₹1,200',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _AvailabilityToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isAvailable ? Icons.check_circle : Icons.cancel,
              color: _isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _isAvailable ? 'Available for charging' : 'Not available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ChargingPointCard(ChargingPoint chargingPoint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Charging Point',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(chargingPoint.address),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.electric_bolt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(chargingPoint.socketTypeDisplay),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('₹${chargingPoint.pricePerHour}/hour'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ManageChargingPointCard() {
    return Consumer<ChargingPointProvider>(
      builder: (context, provider, child) {
        // Get charging points for this host (for demo, assume first 2 points belong to host)
        final hostChargingPoints = provider.chargingPoints.take(2).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Charging Points',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${hostChargingPoints.length} points',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Add new charging point button
                ElevatedButton.icon(
                  onPressed: _addChargingPoint,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Charging Point'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 16),

                // List of charging points
                if (hostChargingPoints.isNotEmpty) ...[
                  Text(
                    'Your Listings',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...hostChargingPoints
                      .map((point) => _ChargingPointListItem(point)),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No charging points listed yet. Add your first charging point to start earning!',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ChargingPointListItem(ChargingPoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  point.hostName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: point.isAvailable ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  point.isAvailable ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            point.address,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹${point.pricePerHour}/hr',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _editChargingPoint(point),
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _toggleAvailability(point),
                    icon: Icon(
                      point.isAvailable
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    tooltip: point.isAvailable ? 'Deactivate' : 'Activate',
                  ),
                  IconButton(
                    onPressed: () => _deleteChargingPoint(point),
                    icon: const Icon(Icons.delete, size: 18),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(ChargingPoint point) {
    // Toggle availability logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${point.hostName} availability updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteChargingPoint(ChargingPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Charging Point'),
        content: Text('Are you sure you want to delete ${point.hostName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${point.hostName} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _becomeHost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HostRegistrationScreen(),
      ),
    );
  }

  void _addChargingPoint() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChargingPointScreen(),
      ),
    );
  }

  void _editChargingPoint([ChargingPoint? point]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChargingPointScreen(),
      ),
    );
  }

  void _viewBookings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking history feature coming soon!'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
