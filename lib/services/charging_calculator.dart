import '../core/constants/app_constants.dart';
import '../core/models/charging_point.dart';

class ChargingCalculator {
  static double calculateChargingSpeed(SocketType socketType) {
    switch (socketType) {
      case SocketType.type5A:
        return AppConstants.socket5ARate; // 1 kW
      case SocketType.type15A:
        return AppConstants.socket15ARate; // 3 kW
    }
  }

  static double calculateEnergyAdded(SocketType socketType, Duration chargingTime) {
    final chargingSpeed = calculateChargingSpeed(socketType);
    final hours = chargingTime.inMinutes / 60.0;
    return chargingSpeed * hours; // kWh
  }

  static double calculateRangeAdded(SocketType socketType, Duration chargingTime, {double efficiency = 1.0}) {
    final energyAdded = calculateEnergyAdded(socketType, chargingTime);
    return energyAdded * AppConstants.rangePerKwh * efficiency; // km
  }

  static double calculateTimeToFullCharge(
    SocketType socketType,
    double currentBatteryLevel, // 0.0 to 1.0
    double batteryCapacity, // in kWh
  ) {
    final chargingSpeed = calculateChargingSpeed(socketType);
    final energyNeeded = batteryCapacity * (1.0 - currentBatteryLevel);
    final hoursNeeded = energyNeeded / chargingSpeed;
    return hoursNeeded * 60; // return minutes
  }

  static double calculatePrice(
    SocketType socketType,
    Duration chargingTime,
    double pricePerHour,
  ) {
    final hours = chargingTime.inMinutes / 60.0;
    return pricePerHour * hours;
  }

  static ChargingEstimate getChargingEstimate({
    required SocketType socketType,
    required Duration chargingTime,
    required double pricePerHour,
    double currentBatteryLevel = 0.0,
    double batteryCapacity = AppConstants.avgScooterBattery,
    double efficiency = 1.0,
  }) {
    final energyAdded = calculateEnergyAdded(socketType, chargingTime);
    final rangeAdded = calculateRangeAdded(socketType, chargingTime, efficiency: efficiency);
    final price = calculatePrice(socketType, chargingTime, pricePerHour);
    final timeToFull = calculateTimeToFullCharge(socketType, currentBatteryLevel, batteryCapacity);

    return ChargingEstimate(
      energyAdded: energyAdded,
      rangeAdded: rangeAdded,
      price: price,
      timeToFullCharge: timeToFull,
      chargingSpeed: calculateChargingSpeed(socketType),
    );
  }
}

class ChargingEstimate {
  final double energyAdded; // kWh
  final double rangeAdded; // km
  final double price; // ₹
  final double timeToFullCharge; // minutes
  final double chargingSpeed; // kW

  ChargingEstimate({
    required this.energyAdded,
    required this.rangeAdded,
    required this.price,
    required this.timeToFullCharge,
    required this.chargingSpeed,
  });

  String get energyDisplay => '${energyAdded.toStringAsFixed(2)} kWh';
  String get rangeDisplay => '${rangeAdded.toStringAsFixed(1)} km';
  String get priceDisplay => '₹${price.toStringAsFixed(0)}';
  String get timeToFullDisplay => '${timeToFullCharge.toStringAsFixed(0)} min';
  String get chargingSpeedDisplay => '${chargingSpeed.toStringAsFixed(1)} kW';
}
