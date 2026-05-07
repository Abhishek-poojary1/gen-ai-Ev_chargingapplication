import 'package:flutter/material.dart';
import '../core/models/booking.dart';
import '../core/models/charging_point.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void showBookingNotification(Booking booking, ChargingPoint chargingPoint) {
    _showNotification(
      title: 'Booking Confirmed!',
      message: 'Your charging session at ${chargingPoint.hostName} is confirmed.',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  static void showBookingReminder(Booking booking, ChargingPoint chargingPoint) {
    _showNotification(
      title: 'Charging Session Starting Soon',
      message: 'Your booking at ${chargingPoint.hostName} starts in 15 minutes.',
      type: NotificationType.warning,
      duration: const Duration(seconds: 5),
    );
  }

  static void showBookingCompleted(Booking booking, ChargingPoint chargingPoint) {
    _showNotification(
      title: 'Charging Session Completed',
      message: 'Your session at ${chargingPoint.hostName} has ended. Thank you for using EV-Grama Charge!',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  static void showHostBookingNotification(Booking booking, String userName) {
    _showNotification(
      title: 'New Booking Received!',
      message: '$userName has booked your charging point.',
      type: NotificationType.info,
      duration: const Duration(seconds: 4),
    );
  }

  static void showHostBookingStart(Booking booking) {
    _showNotification(
      title: 'Charging Session Started',
      message: 'A user has started their charging session.',
      type: NotificationType.info,
      duration: const Duration(seconds: 3),
    );
  }

  static void showHostBookingEnd(Booking booking) {
    _showNotification(
      title: 'Charging Session Ended',
      message: 'The charging session has completed. You earned ₹${booking.totalPrice.toStringAsFixed(0)}',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  static void showAvailabilityUpdate(bool isAvailable) {
    _showNotification(
      title: 'Availability Updated',
      message: isAvailable 
          ? 'Your charging point is now available for bookings.'
          : 'Your charging point is now unavailable.',
      type: NotificationType.info,
      duration: const Duration(seconds: 3),
    );
  }

  static void showLocationPermissionDenied() {
    _showNotification(
      title: 'Location Permission Required',
      message: 'Please enable location services to see nearby charging points.',
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void showNetworkError() {
    _showNotification(
      title: 'Network Error',
      message: 'Unable to connect to server. Please check your internet connection.',
      type: NotificationType.error,
      duration: const Duration(seconds: 4),
    );
  }

  static void showPaymentSuccess(double amount) {
    _showNotification(
      title: 'Payment Successful',
      message: 'Payment of ₹${amount.toStringAsFixed(0)} completed successfully.',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  static void showChargingPointAdded(String hostName) {
    _showNotification(
      title: 'Charging Point Added',
      message: '$hostName has been successfully registered as a charging host.',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  static void _showNotification({
    required String title,
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        title: title,
        message: message,
        type: type,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showCustomDialog({
    required String title,
    required String content,
    required List<Widget> actions,
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }

  static void showBottomSheet({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }
}

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class _NotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: _backgroundColor,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _backgroundColor,
              ),
              child: Row(
                children: [
                  Icon(
                    _icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
