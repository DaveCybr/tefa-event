class EventItem {
  final int id;
  final String title;
  final String location;
  final DateTime startDate;
  final int price;
  EventItem.fromJson(Map j)
    : id = j['id'],
      title = j['title'],
      location = j['location'] ?? '',
      startDate = DateTime.parse(j['start_date']),
      price = (j['price'] as num).toInt();
}

class OrderItem {
  final int id;
  final String status;
  final EventItem event;
  OrderItem.fromJson(Map j)
    : id = j['id'],
      status = j['status'],
      event = EventItem.fromJson(j['event']);
}
