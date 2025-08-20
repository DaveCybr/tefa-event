import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../core/app_theme.dart';
import '../providers/event_provider.dart';
import '../services/api_client.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistering = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  void _loadEventDetail() {
    final authProvider = context.read<AuthProvider>();
    final eventDetailProvider = context.read<EventDetailProvider>();

    // Try to get from cache first
    final eventsProvider = context.read<EventsProvider>();
    final cachedEvent = eventsProvider.getEventById(widget.eventId);

    if (cachedEvent != null) {
      eventDetailProvider.setEvent(cachedEvent);
    }

    // Always fetch latest data
    eventDetailProvider.getEventDetail(
      eventId: widget.eventId,
      token: authProvider.token,
    );
  }

  Future<void> _registerForEvent() async {
    if (_isRegistering) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.token == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      await ApiService.createOrder(
        eventId: widget.eventId,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear notes
        _notesController.clear();

        // Reload event to update participant count
        _loadEventDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            title: const Text(
              'Register for Event',
              style: TextStyle(color: AppColors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to register for this event?',
                  style: TextStyle(color: AppColors.gray),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add notes (optional)',
                    hintStyle: TextStyle(color: AppColors.gray),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _notesController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _registerForEvent();
                },
                child: const Text('Register'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailProvider>(
      builder: (context, eventDetailProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: AppColors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Event Details',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              eventDetailProvider.isLoading && eventDetailProvider.event == null
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  )
                  : eventDetailProvider.errorMessage != null &&
                      eventDetailProvider.event == null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          eventDetailProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadEventDetail,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : eventDetailProvider.event == null
                  ? const Center(
                    child: Text(
                      'Event not found',
                      style: TextStyle(color: AppColors.gray, fontSize: 16),
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(16),
                            image:
                                eventDetailProvider.event!.imageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(
                                        eventDetailProvider.event!.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                      onError: (error, stackTrace) {
                                        // Handle image load error
                                      },
                                    )
                                    : null,
                          ),
                          child:
                              eventDetailProvider.event!.imageUrl == null
                                  ? const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 64,
                                      color: AppColors.gray,
                                    ),
                                  )
                                  : null,
                        ),

                        const SizedBox(height: 24),

                        // Event Title
                        Text(
                          eventDetailProvider.event!.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Category and Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                eventDetailProvider.event!.category,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  eventDetailProvider.event!.status,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                eventDetailProvider.event!.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(
                                    eventDetailProvider.event!.status,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Event Details Cards
                        _buildDetailCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          content: eventDetailProvider.event!.location,
                        ),

                        _buildDetailCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Date & Time',
                          content:
                              '${DateFormat('EEEE, MMMM dd, yyyy').format(eventDetailProvider.event!.startDate)}\n'
                              '${DateFormat('HH:mm').format(eventDetailProvider.event!.startDate)} - ${DateFormat('HH:mm').format(eventDetailProvider.event!.endDate)}',
                        ),

                        _buildDetailCard(
                          icon: Icons.people_outline,
                          title: 'Participants',
                          content:
                              '${eventDetailProvider.event!.registeredParticipants} / ${eventDetailProvider.event!.maxParticipants} registered',
                        ),

                        _buildDetailCard(
                          icon: Icons.payment_outlined,
                          title: 'Price',
                          content: _formatPrice(
                            eventDetailProvider.event!.price,
                          ),
                          isAccent: true,
                        ),

                        _buildDetailCard(
                          icon: Icons.schedule_outlined,
                          title: 'Registration Deadline',
                          content: DateFormat(
                            'EEEE, MMMM dd, yyyy at HH:mm',
                          ).format(
                            eventDetailProvider.event!.registrationDeadline,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          eventDetailProvider.event!.description,
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isRegistering ? null : _showRegistrationDialog,
                            child:
                                _isRegistering
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.black,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Register for Event',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    bool isAccent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dark.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isAccent ? AppColors.accent : AppColors.gray,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: isAccent ? AppColors.accent : AppColors.white,
                    fontSize: 16,
                    fontWeight: isAccent ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.gray;
    }
  }

  String _formatPrice(String price) {
    final numPrice = double.tryParse(price) ?? 0;
    if (numPrice == 0) return 'FREE';
    return 'Rp ${NumberFormat('#,###').format(numPrice)}';
  }
}
