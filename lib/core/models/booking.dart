class Booking {
  final String id;
  final String chargingPointId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final double totalPrice;
  final String notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.chargingPointId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.pending,
    required this.totalPrice,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      chargingPointId: json['chargingPointId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      ),
      totalPrice: json['totalPrice'].toDouble(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chargingPointId': chargingPointId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'totalPrice': totalPrice,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Duration get duration => endTime.difference(startTime);
  bool get isCompleted => DateTime.now().isAfter(endTime);
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);

  Booking copyWith({
    String? id,
    String? chargingPointId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    double? totalPrice,
    String? notes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      chargingPointId: chargingPointId ?? this.chargingPointId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}
