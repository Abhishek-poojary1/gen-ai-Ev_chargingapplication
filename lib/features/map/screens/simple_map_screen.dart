import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/charging_point.dart';
import '../../../services/location_service.dart';
import '../../../core/providers/charging_point_provider.dart';
import 'package:provider/provider.dart';
import '../../host/screens/add_charging_point_screen.dart';
import '../../booking/screens/booking_screen.dart';

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<ChargingPointProvider>(context, listen: false);
        print(
            'Provider charging points in initState: ${provider.chargingPoints.length}');
        if (provider.chargingPoints.isEmpty) {
          print('Initializing sample data from map screen...');
          provider.initializeSampleData();
        }
        provider.startRealTimeUpdates();
      }
    });
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        final defaultLocation = await LocationService.getDefaultLocation();
        setState(() {
          _currentLocation = defaultLocation;
        });
      }
    } catch (e) {
      final defaultLocation = await LocationService.getDefaultLocation();
      setState(() {
        _currentLocation = defaultLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EV-Grama Charge'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ChargingPointProvider>(context, listen: false)
                  .refreshChargingPoints();
            },
          ),
        ],
      ),
      body: Consumer<ChargingPointProvider>(
        builder: (context, provider, child) {
          print('Charging points count: ${provider.chargingPoints.length}');
          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(28.6139, 77.2090),
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ev_gamma_flutter',
                retinaMode: false,
                maxZoom: 18.0,
              ),
              MarkerLayer(
                markers: [
                  // Test marker at center
                  Marker(
                    point: const LatLng(28.6139, 77.2090),
                    width: 60,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // Charging point markers
                  ...provider.chargingPoints.map((point) {
                    return Marker(
                      point: point.location,
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _showChargingPointDialog(point);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.electric_bolt,
                            color:
                                point.isAvailable ? Colors.green : Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Consumer<ChargingPointProvider>(
              builder: (context, provider, child) {
                return Text(
                  'Charging Points: ${provider.chargingPoints.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddChargingPointScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showChargingPointDialog(ChargingPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point.hostName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${point.address}'),
            const SizedBox(height: 8),
            Text('Socket: ${point.socketTypeDisplay}'),
            const SizedBox(height: 8),
            Text('Price: ₹${point.pricePerHour}/hour'),
            const SizedBox(height: 8),
            Text('Rating: ${point.rating}⭐'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: point.isAvailable
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                point.isAvailable ? 'Available' : 'Busy',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (point.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(point.description),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (point.isAvailable)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(chargingPoint: point),
                  ),
                );
              },
              child: const Text('Book Now'),
            ),
        ],
      ),
    );
  }
}
