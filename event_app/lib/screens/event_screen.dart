import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/app_model.dart';
import '../services/api_client.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<EventItem> events = [];
  bool loading = true;
  final df = DateFormat('MMM d, yyyy • HH:mm');

  Future<void> fetch() async {
    setState(() => loading = true);
    final res = await ApiClient().get(
      '/api/events',
      q: {'page': 1, 'per_page': 20},
    );
    final list = (res.data as Map)['data']['events'] as List;
    events = list.map((e) => EventItem.fromJson(e)).toList();
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext ctx) {
    return RefreshIndicator(
      onRefresh: fetch,
      child:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final e = events[i];
                  return InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(eventId: e.id),
                          ),
                        ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dark),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.location,
                            style: const TextStyle(color: AppColors.gray),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.gray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                df.format(e.startDate),
                                style: const TextStyle(color: AppColors.gray),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'IDR ${e.price}',
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
