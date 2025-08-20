import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/app_model.dart';
import '../services/api_client.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventItem? event;
  bool loading = true;
  Future<void> fetch() async {
    final res = await ApiClient().get('/api/events/${widget.eventId}');
    final j = (res.data as Map)['data'];
    event = EventItem.fromJson(j);
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext ctx) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final e = event!;
    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(e.location, style: const TextStyle(color: AppColors.gray)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ApiClient().post(
                    '/api/orders',
                    data: {'event_id': e.id},
                  );
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order created')),
                    );
                },
                child: const Text('REGISTER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
