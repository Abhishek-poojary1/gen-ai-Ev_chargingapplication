import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/models/charging_point.dart';
import '../../../services/charging_calculator.dart';
import '../../../themes/app_theme.dart';

class ChargingCalculatorScreen extends StatefulWidget {
  const ChargingCalculatorScreen({super.key});

  @override
  State<ChargingCalculatorScreen> createState() =>
      _ChargingCalculatorScreenState();
}

class _ChargingCalculatorScreenState extends State<ChargingCalculatorScreen> {
  SocketType _selectedSocketType = SocketType.type15A;
  int _chargingMinutes = 60;
  double _batteryCapacity = 2.0; // kWh
  double _currentBatteryLevel = 0.2; // 20%
  double _efficiency = 0.85; // 85% efficiency

  ChargingEstimate? _estimate;

  void _calculateCharging() {
    setState(() {
      _estimate = ChargingCalculator.getChargingEstimate(
        socketType: _selectedSocketType,
        chargingTime: Duration(minutes: _chargingMinutes),
        pricePerHour: 50.0, // Default price
        currentBatteryLevel: _currentBatteryLevel,
        batteryCapacity: _batteryCapacity,
        efficiency: _efficiency,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Calculator'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charging Animation
            Center(
              child: SizedBox(
                height: 200,
                child: _estimate != null
                    ? const Icon(
                        Icons.battery_charging_full,
                        size: 100,
                        color: AppTheme.electricBlue,
                      )
                    : const Icon(
                        Icons.battery_alert,
                        size: 100,
                        color: Colors.grey,
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Socket Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Socket Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<SocketType>(
                            title: const Text('5A Socket\n(1kW)'),
                            value: SocketType.type5A,
                            groupValue: _selectedSocketType,
                            onChanged: (value) {
                              setState(() {
                                _selectedSocketType = value!;
                                _calculateCharging();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<SocketType>(
                            title: const Text('15A Socket\n(3kW)'),
                            value: SocketType.type15A,
                            groupValue: _selectedSocketType,
                            onChanged: (value) {
                              setState(() {
                                _selectedSocketType = value!;
                                _calculateCharging();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Charging Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charging Time: $_chargingMinutes minutes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _chargingMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '$_chargingMinutes min',
                      onChanged: (value) {
                        setState(() {
                          _chargingMinutes = value.round();
                          _calculateCharging();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Battery Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Battery Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        'Battery Capacity: ${_batteryCapacity.toStringAsFixed(1)} kWh'),
                    Slider(
                      value: _batteryCapacity,
                      min: 1.0,
                      max: 5.0,
                      divisions: 40,
                      label: '${_batteryCapacity.toStringAsFixed(1)} kWh',
                      onChanged: (value) {
                        setState(() {
                          _batteryCapacity = value;
                          _calculateCharging();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                        'Current Level: ${(_currentBatteryLevel * 100).round()}%'),
                    Slider(
                      value: _currentBatteryLevel,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(_currentBatteryLevel * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _currentBatteryLevel = value;
                          _calculateCharging();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_estimate != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Charging Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(
                        icon: Icons.battery_charging_full,
                        label: 'Energy Added',
                        value: _estimate!.energyDisplay,
                      ),
                      const SizedBox(height: 12),
                      _ResultRow(
                        icon: Icons.directions_bike,
                        label: 'Range Added',
                        value: _estimate!.rangeDisplay,
                      ),
                      const SizedBox(height: 12),
                      _ResultRow(
                        icon: Icons.attach_money,
                        label: 'Estimated Cost',
                        value: _estimate!.priceDisplay,
                      ),
                      const SizedBox(height: 12),
                      _ResultRow(
                        icon: Icons.speed,
                        label: 'Charging Speed',
                        value: _estimate!.chargingSpeedDisplay,
                      ),
                      const SizedBox(height: 12),
                      if (_estimate!.timeToFullCharge > 0)
                        _ResultRow(
                          icon: Icons.timer,
                          label: 'Time to Full Charge',
                          value: _estimate!.timeToFullDisplay,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultRow({
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
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
