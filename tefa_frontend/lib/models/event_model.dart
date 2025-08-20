class EventModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final String price;
  final int maxParticipants;
  final int registeredParticipants;
  final String? imageUrl;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String status;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserCreator? creator;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.maxParticipants,
    required this.registeredParticipants,
    this.imageUrl,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'],
      maxParticipants: json['max_participants'],
      registeredParticipants: json['registered_participants'],
      imageUrl: json['image_url'],
      category: json['category'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      registrationDeadline: DateTime.parse(json['registration_deadline']),
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      creator:
          json['creator'] != null
              ? UserCreator.fromJson(json['creator'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'max_participants': maxParticipants,
      'registered_participants': registeredParticipants,
      'image_url': imageUrl,
      'category': category,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'registration_deadline': registrationDeadline.toIso8601String(),
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator': creator?.toJson(),
    };
  }
}

class UserCreator {
  final int id;
  final String name;
  final String email;
  final String role;

  UserCreator({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserCreator.fromJson(Map<String, dynamic> json) {
    return UserCreator(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }
}

class EventsResponse {
  final bool success;
  final String message;
  final EventsData data;

  EventsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      success: json['success'],
      message: json['message'],
      data: EventsData.fromJson(json['data']),
    );
  }
}

class EventsData {
  final List<EventModel> events;
  final PaginationModel pagination;

  EventsData({required this.events, required this.pagination});

  factory EventsData.fromJson(Map<String, dynamic> json) {
    return EventsData(
      events:
          (json['events'] as List).map((e) => EventModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
      from: json['from'],
      to: json['to'],
    );
  }
}
