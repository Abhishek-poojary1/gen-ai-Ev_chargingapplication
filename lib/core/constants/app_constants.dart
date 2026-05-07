class AppConstants {
  // App Info
  static const String appName = 'EV-Grama Charge';
  static const String appVersion = '1.0.0';
  
  // Charging Rates (kW)
  static const double socket5ARate = 1.0; // 5A socket ~ 1kW
  static const double socket15ARate = 3.0; // 15A socket ~ 3kW
  
  // Average EV Battery sizes (kWh)
  static const double avgScooterBattery = 2.0; // 2 kWh average
  static const double avgBikeBattery = 3.0; // 3 kWh average
  
  // Range per kWh (km)
  static const double rangePerKwh = 40.0; // 40 km per kWh average
  
  // Pricing
  static const double defaultPricePerHour = 50.0; // ₹50 per hour
  
  // Map
  static const double defaultZoom = 13.0;
  static const double searchRadius = 10.0; // 10 km search radius
  
  // Booking
  static const int defaultBookingDuration = 60; // 60 minutes
  static const int maxBookingDuration = 240; // 4 hours max
  
  // Colors
  static const String electricBlue = '#00BCD4';
  static const String electricGreen = '#4CAF50';
  static const String darkBackground = '#121212';
}
