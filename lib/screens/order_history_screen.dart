import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
    _updateFCMToken();
  }

  Future<void> _updateFCMToken() async {
    try {
      final token = await NotificationService.getFCMToken();
      if (token != null) {
        await ApiService.updateFCMToken(token);
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      return await ApiService.getOrders();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
      case 'Menunggu Konfirmasi':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Dikirim':
        return Colors.indigo;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshOrders,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada pesanan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = List<Map<String, dynamic>>.from(order['items']);
                final firstItem = items.first;
                final remainingItemsCount = items.length - 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(orderId: order['id']),
                        ),
                      ).then((_) => _refreshOrders());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pesanan #${order['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Chip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      order['status_icon'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order['status'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                backgroundColor: _getStatusColor(order['status']).withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: _getStatusColor(order['status']),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                firstItem['image_url'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(
                              firstItem['product_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: remainingItemsCount > 0
                                ? Text(
                                    '+$remainingItemsCount produk lainnya',
                                    style: TextStyle(color: Colors.grey[600]),
                                  )
                                : null,
                            trailing: Text(
                              'Rp ${order['total_price'].toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (order['tracking_number'] != null) ...[
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'No. Resi: ${order['tracking_number']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal: ${order['created_at']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
