// lib/widgets/in_app_notification.dart
import 'package:flutter/material.dart';

class InAppNotification {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  /// Show in-app notification popup (like WhatsApp)
  static void show({
    required BuildContext context,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    try {
      // Don't show if already showing
      if (_isShowing) return;

      // Find the overlay-enabled context
      final overlayContext = _findOverlayContext(context);
      if (overlayContext == null) {
        debugPrint('❌ No overlay context found');
        return;
      }

      _isShowing = true;

      final overlay = Overlay.of(overlayContext);
      _currentOverlay = OverlayEntry(
        builder:
            (context) => _InAppNotificationWidget(
              title: title,
              body: body,
              imageUrl: imageUrl,
              data: data,
              onTap: onTap ?? () => _handleTap(overlayContext, data),
              onDismiss: _dismiss,
            ),
      );

      overlay.insert(_currentOverlay!);

      debugPrint('✅ In-app notification overlay inserted');

      // Auto dismiss after duration
      Future.delayed(duration, () {
        _dismiss();
      });
    } catch (e) {
      debugPrint('❌ Error showing in-app notification: $e');
      _isShowing = false;
    }
  }

  /// Find a context that has an Overlay ancestor
  static BuildContext? _findOverlayContext(BuildContext context) {
    try {
      // First try the provided context
      if (Overlay.of(context, rootOverlay: false) != null) {
        return context;
      }

      // Try root overlay
      if (Overlay.of(context, rootOverlay: true) != null) {
        return context;
      }

      return null;
    } catch (e) {
      debugPrint('Error finding overlay context: $e');
      return null;
    }
  }

  static void _handleTap(BuildContext context, Map<String, dynamic>? data) {
    _dismiss();

    if (data != null) {
      // Handle deep linking
      if (data.containsKey('event_id')) {
        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: {'eventId': int.parse(data['event_id'].toString())},
        );
      } else if (data.containsKey('order_id')) {
        Navigator.pushNamed(
          context,
          '/order-detail',
          arguments: {'orderId': int.parse(data['order_id'].toString())},
        );
      }
    }
  }

  static void _dismiss() {
    if (_currentOverlay != null && _isShowing) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }

  /// Force dismiss any showing notification
  static void dismissCurrent() {
    _dismiss();
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // App Icon or Image
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            widget.imageUrl != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.notifications,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                  ),
                                )
                                : const Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: 24,
                                ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Dismiss button
                      GestureDetector(
                        onTap: _handleDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
