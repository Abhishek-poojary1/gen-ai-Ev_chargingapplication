import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/charging_point.dart';
import '../../../themes/app_theme.dart';

class HostRegistrationScreen extends StatefulWidget {
  const HostRegistrationScreen({super.key});

  @override
  State<HostRegistrationScreen> createState() => _HostRegistrationScreenState();
}

class _HostRegistrationScreenState extends State<HostRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Personal Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Charging Point Information
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  SocketType _selectedSocketType = SocketType.type15A;
  double _pricePerHour = 50.0;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Location
  bool _useCurrentLocation = true;
  String _locationStatus = 'Getting location...';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        title: const Text('Become a Host'),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                _buildPersonalInfoPage(),
                _buildChargingPointPage(),
                _buildAvailabilityPage(),
                _buildConfirmationPage(),
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

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().slideX(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().slideX(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
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
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ).animate().slideY(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ).animate().slideY(delay: 400.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildChargingPointPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charging Point Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your charging point',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on),
              helperText: 'Enter the complete address of your charging point',
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Socket Type
          Text(
            'Socket Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<SocketType>(
                  title: const Text('5A Socket\n(1kW charging)'),
                  value: SocketType.type5A,
                  groupValue: _selectedSocketType,
                  onChanged: (value) {
                    setState(() {
                      _selectedSocketType = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<SocketType>(
                  title: const Text('15A Socket\n(3kW charging)'),
                  value: SocketType.type15A,
                  groupValue: _selectedSocketType,
                  onChanged: (value) {
                    setState(() {
                      _selectedSocketType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Text(
            'Price per Hour',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
          Center(
            child: Text(
              '₹${_pricePerHour.round()} per hour',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
              helperText:
                  'Add any additional information (parking, availability, etc.)',
            ),
            maxLines: 3,
          ),
        ],
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
            'Set your availability hours',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Use Current Location
          SwitchListTile(
            title: const Text('Use my current location'),
            subtitle: const Text('We\'ll use your GPS coordinates'),
            value: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value;
              });
            },
          ),

          if (_useCurrentLocation) ...[
            const SizedBox(height: 16),
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
                    child: Text(
                      _locationStatus,
                      style: Theme.of(context).textTheme.bodyMedium,
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
          ],

          const SizedBox(height: 24),

          // Operating Hours
          Text(
            'Operating Hours',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          // Quick Options
          Text(
            'Quick Options',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [
              _QuickOptionChip(
                label: '24/7',
                onTap: () {
                  _startTimeController.text = '00:00';
                  _endTimeController.text = '23:59';
                },
              ),
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
                  _startTimeController.text = '18:00';
                  _endTimeController.text = '22:00';
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Personal Info Summary
          _buildSummaryCard('Personal Information', [
            'Name: ${_nameController.text}',
            'Phone: ${_phoneController.text}',
            'Email: ${_emailController.text}',
          ]),

          const SizedBox(height: 16),

          // Charging Point Summary
          _buildSummaryCard('Charging Point', [
            'Address: ${_addressController.text}',
            'Socket: ${_selectedSocketType.toString().split('.').last} Socket',
            'Price: ₹${_pricePerHour.round()}/hour',
            if (_descriptionController.text.isNotEmpty)
              'Description: ${_descriptionController.text}',
          ]),

          const SizedBox(height: 16),

          // Availability Summary
          _buildSummaryCard('Availability', [
            'Location: ${_useCurrentLocation ? 'Current GPS Location' : 'Manual Entry'}',
            'Hours: ${_startTimeController.text} - ${_endTimeController.text}',
          ]),

          const SizedBox(height: 24),

          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'By registering as a host, you agree to:\n'
                  '• Provide reliable charging service\n'
                  '• Maintain your charging point in good condition\n'
                  '• Be available during specified hours\n'
                  '• Follow safety guidelines\n'
                  '• Allow EV-Grama Charge to facilitate bookings',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the terms and conditions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
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
              onPressed: _currentStep < 3 ? _nextStep : _submitRegistration,
              child: Text(_currentStep < 3 ? 'Next' : 'Submit Registration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _QuickOptionChip(
      {required String label, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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

  void _submitRegistration() {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 12),
            const Text('Registration Successful!'),
          ],
        ),
        content: const Text(
          'Your charging point has been registered successfully. '
          'You can now start accepting bookings from EV users.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}
