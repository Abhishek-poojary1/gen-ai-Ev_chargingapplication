import 'package:latlong2/latlong.dart';

enum SocketType { type5A, type15A }

class ChargingPoint {
  final String id;
  final String hostName;
  final String hostPhone;
  final LatLng location;
  final String address;
  final SocketType socketType;
  final double pricePerHour;
  final bool isAvailable;
  final double rating;
  final String description;
  final DateTime createdAt;

  ChargingPoint({
    required this.id,
    required this.hostName,
    required this.hostPhone,
    required this.location,
    required this.address,
    required this.socketType,
    required this.pricePerHour,
    this.isAvailable = true,
    this.rating = 0.0,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChargingPoint.fromJson(Map<String, dynamic> json) {
    return ChargingPoint(
      id: json['id'],
      hostName: json['hostName'],
      hostPhone: json['hostPhone'],
      location: LatLng(json['latitude'], json['longitude']),
      address: json['address'],
      socketType: SocketType.values.firstWhere(
        (e) => e.toString() == 'SocketType.${json['socketType']}',
        orElse: () => SocketType.type5A,
      ),
      pricePerHour: json['pricePerHour'].toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      rating: json['rating']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostName': hostName,
      'hostPhone': hostPhone,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'socketType': socketType.toString().split('.').last,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable,
      'rating': rating,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get chargingRate {
    switch (socketType) {
      case SocketType.type5A:
        return 1.0; // kW
      case SocketType.type15A:
        return 3.0; // kW
    }
  }

  String get socketTypeDisplay {
    switch (socketType) {
      case SocketType.type5A:
        return '5A Socket (1kW)';
      case SocketType.type15A:
        return '15A Socket (3kW)';
    }
  }

  ChargingPoint copyWith({
    String? id,
    String? hostName,
    String? hostPhone,
    LatLng? location,
    String? address,
    SocketType? socketType,
    double? pricePerHour,
    bool? isAvailable,
    double? rating,
    String? description,
    DateTime? createdAt,
  }) {
    return ChargingPoint(
      id: id ?? this.id,
      hostName: hostName ?? this.hostName,
      hostPhone: hostPhone ?? this.hostPhone,
      location: location ?? this.location,
      address: address ?? this.address,
      socketType: socketType ?? this.socketType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
