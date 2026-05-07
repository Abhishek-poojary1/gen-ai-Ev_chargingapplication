import 'dart:math';
import '../core/models/charging_point.dart';
import '../core/models/booking.dart';
import 'charging_calculator.dart';
import 'package:latlong2/latlong.dart';

class AIService {
  static ChargingRecommendation getChargingRecommendation({
    required double currentBatteryLevel,
    required double batteryCapacity,
    required LatLng userLocation,
    required List<ChargingPoint> nearbyChargingPoints,
    required double plannedRange,
  }) {
    // AI Logic: Find optimal charging point based on multiple factors
    ChargingPoint? bestPoint;
    double bestScore = 0.0;

    for (final point in nearbyChargingPoints) {
      final score = _calculateChargingScore(
        point: point,
        currentBatteryLevel: currentBatteryLevel,
        batteryCapacity: batteryCapacity,
        userLocation: userLocation,
        plannedRange: plannedRange,
      );

      if (score > bestScore) {
        bestScore = score;
        bestPoint = point;
      }
    }

    return ChargingRecommendation(
      recommendedPoint: bestPoint,
      score: bestScore,
      reasoning:
          _generateReasoning(bestPoint, currentBatteryLevel, batteryCapacity),
      alternativeOptions: nearbyChargingPoints
          .where((p) => p.id != bestPoint?.id)
          .take(3)
          .toList(),
    );
  }

  static double _calculateChargingScore({
    required ChargingPoint point,
    required double currentBatteryLevel,
    required double batteryCapacity,
    required LatLng userLocation,
    required double plannedRange,
  }) {
    double score = 0.0;

    // Factor 1: Availability (30% weight)
    if (point.isAvailable) {
      score += 30.0;
    }

    // Factor 2: Distance (25% weight) - closer is better
    final distance = _calculateDistance(userLocation, point.location);
    final distanceScore = max(0, 25.0 - (distance / 1000)); // Normalize to km
    score += distanceScore;

    // Factor 3: Charging Speed (20% weight)
    final chargingSpeed = point.chargingRate;
    final speedScore = (chargingSpeed / 3.0) * 20.0; // Normalize to max 3kW
    score += speedScore;

    // Factor 4: Price (15% weight) - cheaper is better
    final priceScore = max(
        0, 15.0 - (point.pricePerHour / 200.0) * 15.0); // Normalize to max ₹200
    score += priceScore;

    // Factor 5: Rating (10% weight)
    final ratingScore = point.rating * 2.0; // Normalize to 5-star scale
    score += ratingScore;

    // AI Bonus: Smart charging time optimization
    final optimalChargingTime = _calculateOptimalChargingTime(
      currentBatteryLevel,
      batteryCapacity,
      point.chargingRate,
    );
    final timeEfficiency = _calculateTimeEfficiency(optimalChargingTime);
    score += timeEfficiency * 10.0;

    return score;
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    final double dLat = (point2.latitude - point1.latitude) * pi / 180;
    final double dLon = (point2.longitude - point1.longitude) * pi / 180;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(dLat) * cos(dLat) * sin(dLon / 2) * sin(dLon / 2);
    final double c = sqrt(sin(dLat / 2) * sin(dLat / 2) +
        cos(dLat) * cos(dLat) * cos(dLon / 2) * cos(dLon / 2));
    final double d = 2 * atan2(sqrt(a), sqrt(c));

    return earthRadius * d;
  }

  static Duration _calculateOptimalChargingTime(
    double currentBatteryLevel,
    double batteryCapacity,
    double chargingRate,
  ) {
    // AI Logic: Calculate optimal charging time to reach 80% battery
    final targetLevel = min(0.8, currentBatteryLevel + 0.6);
    final energyNeeded = (targetLevel - currentBatteryLevel) * batteryCapacity;
    final chargingTimeHours = energyNeeded / chargingRate;

    return Duration(minutes: (chargingTimeHours * 60).round());
  }

  static double _calculateTimeEfficiency(Duration optimalTime) {
    // AI Logic: Prefer charging times between 30-90 minutes
    final optimalMinutes = optimalTime.inMinutes.toDouble();
    if (optimalMinutes >= 30 && optimalMinutes <= 90) {
      return 1.0; // Perfect efficiency
    } else if (optimalMinutes >= 20 && optimalMinutes <= 120) {
      return 0.7; // Good efficiency
    } else if (optimalMinutes >= 10 && optimalMinutes <= 180) {
      return 0.4; // Acceptable efficiency
    } else {
      return 0.1; // Poor efficiency
    }
  }

  static String _generateReasoning(
    ChargingPoint? point,
    double currentBatteryLevel,
    double batteryCapacity,
  ) {
    if (point == null) return 'No suitable charging points found nearby.';

    final reasoning = StringBuffer();

    // Distance reasoning
    final distance = _calculateDistance(
      // User location (would be passed as parameter)
      const LatLng(28.6139, 77.2090), // Default
      point.location,
    );

    if (distance < 500) {
      reasoning.write(
          '🎯 Very close (${(distance / 1000).toStringAsFixed(1)}km) - walking distance\n');
    } else if (distance < 2000) {
      reasoning.write(
          '📍 Close (${(distance / 1000).toStringAsFixed(1)}km) - short drive\n');
    } else {
      reasoning.write(
          '🚗 Moderate distance (${(distance / 1000).toStringAsFixed(1)}km)\n');
    }

    // Charging speed reasoning
    if (point.chargingRate >= 2.5) {
      reasoning.write(
          '⚡ Fast charging (${point.chargingRate.toStringAsFixed(1)}kW) - quick top-up\n');
    } else {
      reasoning.write(
          '🔌 Standard charging (${point.chargingRate.toStringAsFixed(1)}kW) - reliable charging\n');
    }

    // Price reasoning
    if (point.pricePerHour <= 30) {
      reasoning.write(
          '💰 Affordable (₹${point.pricePerHour.round()}/hr) - budget-friendly\n');
    } else if (point.pricePerHour <= 60) {
      reasoning
          .write('💰 Reasonable price (₹${point.pricePerHour.round()}/hr)\n');
    } else {
      reasoning
          .write('💰 Premium pricing (₹${point.pricePerHour.round()}/hr)\n');
    }

    // Battery optimization
    final energyNeeded = (1.0 - currentBatteryLevel) * batteryCapacity;
    if (energyNeeded <= 1.0) {
      reasoning.write(
          '🔋 Quick top-up needed (${energyNeeded.toStringAsFixed(1)}kWh)\n');
    } else {
      reasoning.write(
          '🔋 Full charge recommended (${energyNeeded.toStringAsFixed(1)}kWh)\n');
    }

    // Rating and reliability
    if (point.rating >= 4.5) {
      reasoning.write(
          '⭐ Highly rated (${point.rating.toStringAsFixed(1)}⭐) - trusted host\n');
    } else if (point.rating >= 4.0) {
      reasoning.write(
          '⭐ Good rating (${point.rating.toStringAsFixed(1)}⭐) - reliable\n');
    }

    return reasoning.toString();
  }

  static List<PricingSuggestion> getPricingSuggestions({
    required SocketType socketType,
    required double currentPrice,
    required double averagePriceInArea,
  }) {
    final suggestions = <PricingSuggestion>[];

    // AI Logic: Suggest optimal pricing based on market analysis
    final basePrice = socketType == SocketType.type15A ? 50.0 : 30.0;

    // Competitive pricing suggestion
    if (currentPrice > averagePriceInArea * 1.2) {
      suggestions.add(PricingSuggestion(
        type: SuggestionType.competitive,
        title: 'Competitive Pricing',
        description: 'Lower price to attract more customers',
        suggestedPrice: averagePriceInArea * 1.1,
        potentialIncrease: '+25% bookings',
      ));
    }

    // Premium pricing suggestion
    if (currentPrice < basePrice * 0.8) {
      suggestions.add(PricingSuggestion(
        type: SuggestionType.premium,
        title: 'Premium Pricing',
        description: 'Increase price for higher revenue',
        suggestedPrice: basePrice * 1.2,
        potentialIncrease: '+15% revenue',
      ));
    }

    // Dynamic pricing suggestion
    suggestions.add(PricingSuggestion(
      type: SuggestionType.dynamic,
      title: 'Smart Dynamic Pricing',
      description: 'Adjust based on demand and time of day',
      suggestedPrice: basePrice,
      potentialIncrease: '+20% profit',
    ));

    // Peak hours pricing
    suggestions.add(PricingSuggestion(
      type: SuggestionType.peak_hours,
      title: 'Peak Hour Pricing',
      description: 'Higher rates during 6-9 PM',
      suggestedPrice: basePrice * 1.3,
      potentialIncrease: '+30% peak revenue',
    ));

    return suggestions;
  }

  static RouteOptimization getOptimizedRoute({
    required LatLng startLocation,
    required LatLng endLocation,
    required List<ChargingPoint> availableChargingPoints,
    required double currentBatteryLevel,
    required double batteryCapacity,
  }) {
    // AI Logic: Find optimal charging stops along the route
    final totalRange = _calculateDistance(startLocation, endLocation);
    final averageRange = batteryCapacity * 40; // 40km per kWh average

    List<ChargingStop> chargingStops = [];
    double remainingRange = currentBatteryLevel * averageRange;
    LatLng currentPos = startLocation;

    while (remainingRange < totalRange) {
      final bestStop = _findBestChargingStop(
        currentPos,
        availableChargingPoints,
        chargingStops,
        remainingRange,
      );

      if (bestStop == null) break;

      chargingStops.add(bestStop!);
      remainingRange += bestStop!.rangeAdded;
      currentPos = bestStop!.location;
    }

    return RouteOptimization(
      chargingStops: chargingStops,
      totalTime:
          Duration(minutes: chargingStops.length * 45), // 45 min per stop
      totalCost: chargingStops.fold(0, (sum, stop) => sum + stop.estimatedCost),
      efficiency: _calculateRouteEfficiency(totalRange, chargingStops.length),
    );
  }

  static ChargingStop? _findBestChargingStop(
    LatLng currentLocation,
    List<ChargingPoint> availablePoints,
    List<ChargingStop> existingStops,
    double remainingRange,
  ) {
    ChargingStop? bestStop;
    double bestScore = 0.0;

    for (final point in availablePoints) {
      // Skip if already used
      if (existingStops.any((stop) => stop.chargingPointId == point.id)) {
        continue;
      }

      final distance = _calculateDistance(currentLocation, point.location);

      // AI scoring for charging stop selection
      double score = 0.0;

      // Distance factor (40% weight)
      if (distance <= 5000) {
        // Within 5km
        score += 40.0;
      } else if (distance <= 10000) {
        // Within 10km
        score += 25.0;
      } else {
        score += 10.0;
      }

      // Charging speed factor (30% weight)
      score += (point.chargingRate / 3.0) * 30.0;

      // Availability factor (20% weight)
      if (point.isAvailable) {
        score += 20.0;
      }

      // Rating factor (10% weight)
      score += point.rating * 2.0;

      if (score > bestScore) {
        bestScore = score;
        bestStop = ChargingStop(
          chargingPointId: point.id,
          location: point.location,
          chargingPointName: point.hostName,
          distanceFromRoute: distance,
          estimatedChargingTime: Duration(minutes: 45),
          estimatedCost: point.pricePerHour * 0.75, // 45 minutes
          rangeAdded: point.chargingRate * 0.75 * 40, // Range added in 45 min
        );
      }
    }

    return bestStop;
  }

  static double _calculateRouteEfficiency(double totalRange, int stopCount) {
    if (stopCount == 0) return 0.0;

    // AI Logic: Calculate efficiency based on stop frequency
    final optimalStops = (totalRange / 10000).ceil(); // One stop per 10km
    final efficiency = optimalStops / stopCount;

    return efficiency.clamp(0.0, 1.0);
  }

  static DemandForecast predictDemand({
    required List<Booking> historicalBookings,
    required DateTime targetDate,
    required SocketType socketType,
  }) {
    // AI Logic: Predict demand using historical data and patterns
    final dayOfWeek = targetDate.weekday;
    final hour = targetDate.hour;

    // Filter relevant historical data
    final relevantBookings = historicalBookings.where((booking) {
      return booking.startTime.weekday == dayOfWeek &&
          booking.startTime.hour >= hour - 2 &&
          booking.startTime.hour <= hour + 2;
    }).toList();

    // Calculate base demand
    final averageBookings =
        relevantBookings.length / 4.0; // Average over 4 weeks

    // Apply AI multipliers based on patterns
    double demandMultiplier = 1.0;

    // Weekend multiplier
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      demandMultiplier *= 1.3;
    }

    // Peak hours multiplier
    if (hour >= 18 && hour <= 21) {
      demandMultiplier *= 1.5;
    } else if (hour >= 12 && hour <= 14) {
      demandMultiplier *= 1.2;
    }

    // Socket type multiplier
    if (socketType == SocketType.type15A) {
      demandMultiplier *= 1.2;
    }

    final predictedDemand = averageBookings * demandMultiplier;
    final confidenceLevel = _calculateConfidence(relevantBookings.length);

    return DemandForecast(
      predictedBookings: predictedDemand.round(),
      confidenceLevel: confidenceLevel,
      factors: _generateDemandFactors(demandMultiplier),
      recommendations:
          _generateDemandRecommendations(predictedDemand, confidenceLevel),
    );
  }

  static ConfidenceLevel _calculateConfidence(int dataPoints) {
    if (dataPoints >= 20) return ConfidenceLevel.high;
    if (dataPoints >= 10) return ConfidenceLevel.medium;
    if (dataPoints >= 5) return ConfidenceLevel.low;
    return ConfidenceLevel.very_low;
  }

  static List<String> _generateDemandFactors(double multiplier) {
    final factors = <String>[];

    if (multiplier >= 1.4) {
      factors.add('🔥 High demand period');
    } else if (multiplier >= 1.2) {
      factors.add('📈 Elevated demand');
    } else if (multiplier >= 1.0) {
      factors.add('📊 Normal demand');
    } else {
      factors.add('📉 Low demand period');
    }

    return factors;
  }

  static List<String> _generateDemandRecommendations(
      double demand, ConfidenceLevel confidence) {
    final recommendations = <String>[];

    if (demand > 5 && confidence != ConfidenceLevel.very_low) {
      recommendations
          .add('💡 Consider increasing availability during high demand');
      recommendations.add('💰 Implement dynamic pricing for peak hours');
    }

    if (demand < 1 && confidence == ConfidenceLevel.high) {
      recommendations
          .add('📱 Promote your charging point during low demand periods');
      recommendations.add('🎯 Offer special discounts to attract customers');
    }

    if (confidence == ConfidenceLevel.very_low) {
      recommendations
          .add('📊 Collect more booking data to improve predictions');
    }

    return recommendations;
  }
}

class ChargingRecommendation {
  final ChargingPoint? recommendedPoint;
  final double score;
  final String reasoning;
  final List<ChargingPoint> alternativeOptions;

  ChargingRecommendation({
    required this.recommendedPoint,
    required this.score,
    required this.reasoning,
    required this.alternativeOptions,
  });
}

class PricingSuggestion {
  final SuggestionType type;
  final String title;
  final String description;
  final double suggestedPrice;
  final String potentialIncrease;

  PricingSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.suggestedPrice,
    required this.potentialIncrease,
  });
}

class RouteOptimization {
  final List<ChargingStop> chargingStops;
  final Duration totalTime;
  final double totalCost;
  final double efficiency;

  RouteOptimization({
    required this.chargingStops,
    required this.totalTime,
    required this.totalCost,
    required this.efficiency,
  });
}

class ChargingStop {
  final String chargingPointId;
  final LatLng location;
  final String chargingPointName;
  final double distanceFromRoute;
  final Duration estimatedChargingTime;
  final double estimatedCost;
  final double rangeAdded;

  ChargingStop({
    required this.chargingPointId,
    required this.location,
    required this.chargingPointName,
    required this.distanceFromRoute,
    required this.estimatedChargingTime,
    required this.estimatedCost,
    required this.rangeAdded,
  });
}

class DemandForecast {
  final int predictedBookings;
  final ConfidenceLevel confidenceLevel;
  final List<String> factors;
  final List<String> recommendations;

  DemandForecast({
    required this.predictedBookings,
    required this.confidenceLevel,
    required this.factors,
    required this.recommendations,
  });
}

enum SuggestionType {
  competitive,
  premium,
  dynamic,
  peak_hours,
}

enum ConfidenceLevel {
  very_low,
  low,
  medium,
  high,
}
