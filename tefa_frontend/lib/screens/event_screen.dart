import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../core/app_theme.dart';
import '../providers/event_provider.dart';
import 'event_card.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _loadEvents() {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();

    eventsProvider.getEvents(token: authProvider.token, refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  void _loadMoreEvents() {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();

    if (eventsProvider.hasMore && !eventsProvider.isLoadingMore) {
      eventsProvider.loadMoreEvents(token: authProvider.token);
    }
  }

  void _performSearch(String query) {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();

    eventsProvider.searchEvents(query: query, token: authProvider.token);
  }

  void _navigateToEventDetail(int eventId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: eventId),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: const Text(
          'Events',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Text(
                      'Hello, ${authProvider.user?.name ?? 'User'}',
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        authProvider.user?.role ?? '',
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle: const TextStyle(color: AppColors.gray),
                prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.gray),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {}); // Update suffixIcon visibility
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Events List
          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                // Loading state
                if (eventsProvider.isLoading && eventsProvider.events.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  );
                }

                // Error state
                if (eventsProvider.errorMessage != null &&
                    eventsProvider.events.isEmpty) {
                  return Center(
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
                          eventsProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadEvents,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (eventsProvider.events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppColors.gray.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No events found',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try searching with different keywords',
                          style: TextStyle(color: AppColors.gray, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                // Events List
                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.dark,
                  onRefresh: () async => _loadEvents(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        eventsProvider.events.length +
                        (eventsProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading more indicator
                      if (index == eventsProvider.events.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accent,
                              ),
                            ),
                          ),
                        );
                      }

                      final event = eventsProvider.events[index];
                      return EventCard(
                        event: event,
                        onTap: () => _navigateToEventDetail(event.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
