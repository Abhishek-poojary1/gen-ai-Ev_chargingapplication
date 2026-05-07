import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/charging_point.dart';
import '../../../core/providers/charging_point_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/notification_service.dart';
import '../../../themes/app_theme.dart';
import 'package:provider/provider.dart';

class AddChargingPointScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const AddChargingPointScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<AddChargingPointScreen> createState() => _AddChargingPointScreenState();
}

class _AddChargingPointScreenState extends State<AddChargingPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basic Information
  final _hostNameController = TextEditingController();
  final _hostPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Charging Details
  SocketType _selectedSocketType = SocketType.type15A;
  double _pricePerHour = 50.0;

  // Step 3: Location
  LatLng? _selectedLocation;
  bool _useCurrentLocation = true;
  String _locationStatus = 'Getting location...';

  // Step 4: Availability
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  bool _isAvailable24_7 = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _initializeLocation();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _hostNameController.text = 'Local Shop Owner';
    _hostPhoneController.text = '+919876543210';
    _startTimeController.text = '09:00';
    _endTimeController.text = '21:00';
  }

  Future<void> _initializeLocation() async {
    if (_useCurrentLocation && _selectedLocation == null) {
      setState(() {
        _locationStatus = 'Getting location...';
      });

      try {
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          setState(() {
            _selectedLocation = LatLng(position.latitude, position.longitude);
            _locationStatus = 'Location found';
          });
        } else {
          final defaultLocation = await LocationService.getDefaultLocation();
          setState(() {
            _selectedLocation = defaultLocation;
            _locationStatus = 'Using default location';
          });
        }
      } catch (e) {
        final defaultLocation = await LocationService.getDefaultLocation();
        setState(() {
          _selectedLocation = defaultLocation;
          _locationStatus = 'Location error, using default';
        });
      }
    }
  }

  @override
  void dispose() {
    _hostNameController.dispose();
    _hostPhoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Charging Point'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoPage(),
                _buildChargingDetailsPage(),
                _buildLocationPage(),
                _buildAvailabilityPage(),
              ],
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().slideX(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself and your location',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().slideX(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _hostNameController,
              decoration: const InputDecoration(
                labelText: 'Host Name',
                prefixIcon: Icon(Icons.person),
                helperText: 'Your name or business name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ).animate().slideY(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _hostPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                helperText: 'For booking confirmations',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ).animate().slideY(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
                helperText: 'Complete address of your charging point',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the address';
                }
                return null;
              },
            ).animate().slideY(delay: 400.ms, duration: 300.ms),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                helperText: 'Additional info like parking, landmarks, etc.',
              ),
              maxLines: 2,
            ).animate().slideY(delay: 500.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildChargingDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charging Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Specify your charging capabilities and pricing',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Socket Type Selection
          Text(
            'Socket Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<SocketType>(
                  title: Row(
                    children: [
                      Icon(Icons.electrical_services, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('5A Socket', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Standard charging (1kW)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  value: SocketType.type5A,
                  groupValue: _selectedSocketType,
                  onChanged: (value) {
                    setState(() {
                      _selectedSocketType = value!;
                    });
                  },
                ),
                RadioListTile<SocketType>(
                  title: Row(
                    children: [
                      Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('15A Socket', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Fast charging (3kW)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  value: SocketType.type15A,
                  groupValue: _selectedSocketType,
                  onChanged: (value) {
                    setState(() {
                      _selectedSocketType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Price Setting
          Text(
            'Price per Hour',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Slider(
                    value: _pricePerHour,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    label: '₹${_pricePerHour.round()}',
                    onChanged: (value) {
                      setState(() {
                        _pricePerHour = value;
                      });
                    },
                  ),
                  Text(
                    '₹${_pricePerHour.round()} per hour',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suggested: ₹30-60 for 5A, ₹50-100 for 15A',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Set the exact location of your charging point',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Location Toggle
          SwitchListTile(
            title: const Text('Use my current location'),
            subtitle: const Text('We\'ll use your GPS coordinates'),
            value: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value;
                if (value) {
                  _initializeLocation();
                }
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Location Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        _locationStatus,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_selectedLocation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_locationStatus == 'Getting location...')
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Location Tips
          Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Location Tips',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildLocationTips(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLocationTips() {
    return [
      _buildTipItem('📍 Be precise - users will navigate to this exact spot'),
      _buildTipItem('🏠 Use your main entrance if charging is at home'),
      _buildTipItem('🏪 For shops, use the main customer entrance'),
      _buildTipItem('🅿️ Mention if special parking is available'),
    ];
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildAvailabilityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Set when your charging point is available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // 24/7 Toggle
          Card(
            child: SwitchListTile(
              title: const Text('Available 24/7'),
              subtitle: const Text('Always available for bookings'),
              value: _isAvailable24_7,
              onChanged: (value) {
                setState(() {
                  _isAvailable24_7 = value;
                });
              },
            ),
          ),
          
          if (!_isAvailable24_7) ...[
            const SizedBox(height: 16),
            
            // Operating Hours
            Text(
              'Operating Hours',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              prefixIcon: Icon(Icons.access_time),
                              hintText: '09:00',
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              prefixIcon: Icon(Icons.access_time),
                              hintText: '21:00',
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Quick Options
                    Text(
                      'Quick Options',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _QuickOptionChip(
                          label: 'Business Hours',
                          onTap: () {
                            _startTimeController.text = '09:00';
                            _endTimeController.text = '18:00';
                          },
                        ),
                        _QuickOptionChip(
                          label: 'Evening Only',
                          onTap: () {
                            _startTimeController.text = '17:00';
                            _endTimeController.text = '22:00';
                          },
                        ),
                        _QuickOptionChip(
                          label: 'Weekend',
                          onTap: () {
                            _startTimeController.text = '10:00';
                            _endTimeController.text = '20:00';
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Summary Card
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Host', value: _hostNameController.text),
            _SummaryRow(label: 'Socket', value: _selectedSocketType.toString().split('.').last),
            _SummaryRow(label: 'Price', value: '₹${_pricePerHour.round()}/hour'),
            _SummaryRow(label: 'Availability', value: _isAvailable24_7 ? '24/7' : '${_startTimeController.text} - ${_endTimeController.text}'),
            if (_selectedLocation != null)
              _SummaryRow(label: 'Location', value: 'GPS coordinates set'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _submitChargingPoint,
              child: Text(_currentStep < 3 ? 'Next' : 'Add Charging Point'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _QuickOptionChip({required String label, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _SummaryRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
      return;
    }
    
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitChargingPoint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      NotificationService.showCustomDialog(
        title: 'Location Required',
        content: 'Please set a location for your charging point.',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
      return;
    }

    final chargingPoint = ChargingPoint(
      id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
      hostName: _hostNameController.text,
      hostPhone: _hostPhoneController.text,
      location: _selectedLocation!,
      address: _addressController.text,
      socketType: _selectedSocketType,
      pricePerHour: _pricePerHour,
      isAvailable: true,
      rating: 0.0,
      description: _descriptionController.text,
    );

    try {
      final provider = Provider.of<ChargingPointProvider>(context, listen: false);
      await provider.addChargingPoint(chargingPoint);

      NotificationService.showChargingPointAdded(chargingPoint.hostName);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Charging point added successfully!'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      NotificationService.showCustomDialog(
        title: 'Error',
        content: 'Failed to add charging point. Please try again.',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }
  }

  void _showHelp() {
    NotificationService.showCustomDialog(
      title: 'How to Add a Charging Point',
      content: '1. Fill in your basic information\n2. Select your socket type and pricing\n3. Set the exact location\n4. Choose your availability hours\n\nYour charging point will be visible to EV users who can book charging sessions.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
