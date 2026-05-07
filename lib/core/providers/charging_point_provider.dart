import 'package:flutter/foundation.dart';
import '../models/charging_point.dart';
import '../models/booking.dart';
import 'package:latlong2/latlong.dart';

class ChargingPointProvider with ChangeNotifier {
  List<ChargingPoint> _chargingPoints = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<ChargingPoint> get chargingPoints => _chargingPoints;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with sample data
  void initializeSampleData() {
    print('Initializing sample data...');
    _chargingPoints = [
      ChargingPoint(
        id: '1',
        hostName: 'Ravi Kirana Store',
        hostPhone: '+919876543210',
        location: const LatLng(28.6139, 77.2090),
        address: 'Main Market, Sector 15',
        socketType: SocketType.type15A,
        pricePerHour: 50.0,
        isAvailable: true,
        rating: 4.5,
        description: 'Available 24/7, parking space available',
      ),
      ChargingPoint(
        id: '2',
        hostName: 'Priya Tea Stall',
        hostPhone: '+919876543211',
        location: const LatLng(28.6149, 77.2190),
        address: 'Near Bus Stand',
        socketType: SocketType.type5A,
        pricePerHour: 30.0,
        isAvailable: true,
        rating: 4.2,
        description: 'Available 8AM-10PM',
      ),
      ChargingPoint(
        id: '3',
        hostName: 'Anand Electronics',
        hostPhone: '+919876543212',
        location: const LatLng(28.6089, 77.1990),
        address: 'Shopping Complex, Sector 14',
        socketType: SocketType.type15A,
        pricePerHour: 60.0,
        isAvailable: false,
        rating: 4.8,
        description: 'Fast charging, covered parking',
      ),
      ChargingPoint(
        id: '4',
        hostName: 'Suresh Garage',
        hostPhone: '+919876543213',
        location: const LatLng(28.6189, 77.2290),
        address: 'Industrial Area',
        socketType: SocketType.type5A,
        pricePerHour: 25.0,
        isAvailable: true,
        rating: 3.9,
        description: 'Basic charging, affordable rates',
      ),
      ChargingPoint(
        id: '5',
        hostName: 'Metro Station Parking',
        hostPhone: '+919876543214',
        location: const LatLng(28.6239, 77.2090),
        address: 'Near Metro Station',
        socketType: SocketType.type15A,
        pricePerHour: 40.0,
        isAvailable: true,
        rating: 4.6,
        description: 'Secure parking, fast charging available',
      ),
      ChargingPoint(
        id: '6',
        hostName: 'City Mall EV Station',
        hostPhone: '+919876543215',
        location: const LatLng(28.6039, 77.2190),
        address: 'City Mall Basement',
        socketType: SocketType.type15A,
        pricePerHour: 70.0,
        isAvailable: false,
        rating: 4.7,
        description: 'Premium charging station, shopping available',
      ),
      ChargingPoint(
        id: '7',
        hostName: 'Highway Dhaba Charging',
        hostPhone: '+919876543216',
        location: const LatLng(28.6289, 77.2390),
        address: 'NH-44 Highway',
        socketType: SocketType.type5A,
        pricePerHour: 35.0,
        isAvailable: true,
        rating: 4.1,
        description: '24/7 highway charging, food court available',
      ),
      ChargingPoint(
        id: '8',
        hostName: 'Residential Complex EV',
        hostPhone: '+919876543217',
        location: const LatLng(28.5939, 77.1890),
        address: 'Green Park Society',
        socketType: SocketType.type15A,
        pricePerHour: 45.0,
        isAvailable: true,
        rating: 4.3,
        description: 'Residents only, visitor charging available',
      ),
    ];
    print(
        'Sample data initialized with ${_chargingPoints.length} charging points');

    _bookings = [
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

    _updateAvailabilityBasedOnBookings();
    notifyListeners();
  }

  // Update availability based on current bookings
  void _updateAvailabilityBasedOnBookings() {
    final now = DateTime.now();

    for (final point in _chargingPoints) {
      final activeBookings = _bookings
          .where((booking) =>
              booking.chargingPointId == point.id &&
              booking.status == BookingStatus.confirmed &&
              now.isAfter(booking.startTime) &&
              now.isBefore(booking.endTime))
          .toList();

      final isCurrentlyBooked = activeBookings.isNotEmpty;

      if (point.isAvailable != !isCurrentlyBooked) {
        _chargingPoints = _chargingPoints.map((p) {
          if (p.id == point.id) {
            return p.copyWith(isAvailable: !isCurrentlyBooked);
          }
          return p;
        }).toList();
      }
    }
  }

  // Toggle availability for a charging point
  Future<void> toggleAvailability(
      String chargingPointId, bool isAvailable) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _chargingPoints = _chargingPoints.map((point) {
        if (point.id == chargingPointId) {
          return point.copyWith(isAvailable: isAvailable);
        }
        return point;
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update availability';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new charging point
  Future<void> addChargingPoint(ChargingPoint chargingPoint) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _chargingPoints.add(chargingPoint);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add charging point';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _bookings.add(booking);

      // Update availability after creating booking
      _updateAvailabilityBasedOnBookings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create booking';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _bookings = _bookings.map((booking) {
        if (booking.id == bookingId) {
          return booking.copyWith(status: BookingStatus.cancelled);
        }
        return booking;
      }).toList();

      // Update availability after cancelling booking
      _updateAvailabilityBasedOnBookings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to cancel booking';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get charging point by ID
  ChargingPoint? getChargingPointById(String id) {
    try {
      return _chargingPoints.firstWhere((point) => point.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get bookings for a specific charging point
  List<Booking> getBookingsForChargingPoint(String chargingPointId) {
    return _bookings
        .where((booking) => booking.chargingPointId == chargingPointId)
        .toList();
  }

  // Get user's bookings
  List<Booking> getUserBookings(String userId) {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  // Simulate real-time updates
  void startRealTimeUpdates() {
    // Update availability every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (kDebugMode) {
        _updateAvailabilityBasedOnBookings();
        notifyListeners();
        startRealTimeUpdates(); // Recursive call for continuous updates
      }
    });
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh charging points
  void refreshChargingPoints() {
    print('Refreshing charging points...');
    notifyListeners();
  }
}
