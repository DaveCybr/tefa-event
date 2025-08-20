import 'package:flutter/material.dart';
import '../services/api_client.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map? order;
  bool loading = true;
  Future<void> fetch() async {
    final res = await ApiClient().get('/api/orders/${widget.orderId}');
    order = (res.data as Map)['data'];
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
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order!['id']}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(order.toString()),
      ),
    );
  }
}
