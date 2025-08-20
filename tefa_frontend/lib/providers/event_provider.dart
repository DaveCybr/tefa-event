import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/api_client.dart';

class EventsProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  PaginationModel? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<EventModel> get events => _events;
  PaginationModel? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get hasMore =>
      _pagination != null && _pagination!.currentPage < _pagination!.lastPage;

  /// Get events (first page or refresh)
  Future<void> getEvents({
    String? search,
    bool refresh = false,
    String? token,
  }) async {
    if (refresh) {
      _events.clear();
      _pagination = null;
    }

    _isLoading = true;
    _errorMessage = null;
    _searchQuery = search ?? '';
    notifyListeners();

    try {
      final response = await ApiService.getEvents(
        search: search,
        page: 1,
        perPage: 10,
        token: token,
      );

      if (response.success) {
        _events = response.data.events;
        _pagination = response.data.pagination;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Get events error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more events (pagination)
  Future<void> loadMoreEvents({String? token}) async {
    if (!hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = (_pagination?.currentPage ?? 0) + 1;

      final response = await ApiService.getEvents(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: nextPage,
        perPage: 10,
        token: token,
      );

      if (response.success) {
        _events.addAll(response.data.events);
        _pagination = response.data.pagination;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Load more events error: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Search events
  Future<void> searchEvents({required String query, String? token}) async {
    await getEvents(search: query, refresh: true, token: token);
  }

  /// Refresh events
  Future<void> refreshEvents({String? token}) async {
    await getEvents(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      refresh: true,
      token: token,
    );
  }

  /// Get event by ID from cache
  EventModel? getEventById(int id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}

/// Event Detail Provider (separate for detail screen)
class EventDetailProvider extends ChangeNotifier {
  EventModel? _event;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  EventModel? get event => _event;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get event detail
  Future<void> getEventDetail({required int eventId, String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final event = await ApiService.getEventDetail(
        eventId: eventId,
        token: token,
      );

      _event = event;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Get event detail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set event from cache
  void setEvent(EventModel event) {
    _event = event;
    notifyListeners();
  }

  /// Clear event
  void clearEvent() {
    _event = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
