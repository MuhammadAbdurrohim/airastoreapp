import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Map<String, dynamic>> _orderFuture;
  bool _isUploading = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = _fetchOrderDetails();
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    try {
      return await ApiService.getOrderDetails(widget.orderId);
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  Future<void> _refreshOrder() async {
    setState(() {
      _orderFuture = _fetchOrderDetails();
    });
  }

  Future<void> _uploadPaymentProof() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      await ApiService.uploadPaymentProof(
        widget.orderId,
        File(image.path),
      );

      _refreshOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diunggah')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _cancelOrder() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Batalkan Pesanan'),
          content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isLoading = true);
      await ApiService.cancelOrder(widget.orderId);
      await _refreshOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCompleteOrderDialog() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selesaikan Pesanan'),
          content: const Text('Apakah pesanan Anda sudah diterima dengan baik?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() => _isLoading = true);
        await ApiService.completeOrder(widget.orderId);
        await _refreshOrder();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil diselesaikan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showComplaintDialog() async {
    final TextEditingController descController = TextEditingController();
    File? selectedImage;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajukan Komplain'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Masalah',
                    hintText: 'Jelaskan masalah yang Anda alami',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = File(image.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pilih Foto'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: selectedImage != null && descController.text.isNotEmpty
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedImage != null) {
      try {
        setState(() => _isLoading = true);
        await ApiService.submitComplaint(
          widget.orderId,
          descController.text,
          selectedImage,
        );
        await _refreshOrder();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Komplain berhasil diajukan')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _trackShipment() async {
    try {
      setState(() => _isLoading = true);
      final tracking = await ApiService.trackShipment(widget.orderId);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Informasi Pengiriman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kurir: ${tracking['courier']}'),
                Text('No. Resi: ${tracking['tracking_number']}'),
                Text('Status: ${tracking['status']}'),
                Text('Estimasi: ${tracking['estimated_delivery']}'),
                const Divider(height: 24),
                const Text(
                  'Riwayat:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List<Map<String, dynamic>>.from(tracking['history'])
                    .map((history) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history['date'],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(history['description']),
                              Text(
                                history['location'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu pembayaran':
      case 'menunggu konfirmasi':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'dikirim':
        return Colors.indigo;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      case 'komplain':
        return Colors.deepOrange;
      case 'selesai dengan komplain':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan #${widget.orderId}'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _orderFuture,
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
                        onPressed: _refreshOrder,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              final order = snapshot.data!;
              final items = List<Map<String, dynamic>>.from(order['items']);

              return RefreshIndicator(
                onRefresh: _refreshOrder,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status Pesanan',
                                  style: TextStyle(
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
                                  backgroundColor: _getStatusColor(order['status'])
                                      .withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: _getStatusColor(order['status']),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Text(
                              'Tanggal Pesanan: ${order['created_at']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Items Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Produk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            ...items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          item['image_url'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['product_name'],
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w500),
                                            ),
                                            Text(
                                              '${item['quantity']}x @ Rp ${item['price']}',
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            if (item['notes'] != null)
                                              Text(
                                                'Catatan: ${item['notes']}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp ${order['total_price']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Shipping Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Pengiriman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            Text(
                              order['shipping_address'],
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            if (order['shipping_courier'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Kurir: ${order['shipping_courier']}',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ],
                            if (order['tracking_number'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'No. Resi: ${order['tracking_number']}',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Pembayaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Metode Pembayaran: ${order['payment_method']}',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            if (order['payment_proof'] != null) ...[
                              const SizedBox(height: 8),
                              const Text('Bukti Pembayaran:'),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order['payment_proof']['image_url'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (order['payment_proof']
                                      ['verified_at'] !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Terverifikasi pada: ${order['payment_proof']['verified_at']}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Column(
                      children: [
                        if (order['status'] == 'Menunggu Pembayaran') ...[
                          ElevatedButton(
                            onPressed:
                                _isUploading ? null : _uploadPaymentProof,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: _isUploading
                                ? const CircularProgressIndicator()
                                : const Text('Upload Bukti Pembayaran'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _cancelOrder,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Batalkan Pesanan'),
                          ),
                        ],
                        if (order['status'] == 'Dikirim') ...[
                          ElevatedButton(
                            onPressed: _trackShipment,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Lacak Pengiriman'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showCompleteOrderDialog,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Selesaikan Pesanan'),
                          ),
                        ],
                        if (order['status'] == 'Dikirim' ||
                            order['status'] == 'Selesai') ...[
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _showComplaintDialog,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Ajukan Komplain'),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Complaints Section
                    if (order['complaints'] != null &&
                        order['complaints'].isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Riwayat Komplain',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Divider(),
                              ...List<Map<String, dynamic>>.from(
                                      order['complaints'])
                                  .map((complaint) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  complaint['created_at'],
                                                  style: TextStyle(
                                                    color:
                                                        Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration:
                                                      BoxDecoration(
                                                    color: Color(int.parse(
                                                            complaint[
                                                                'status_color']
                                                                .substring(
                                                                    1),
                                                            radix: 16))
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(12),
                                                  ),
                                                  child: Text(
                                                    complaint[
                                                        'status_label'],
                                                    style: TextStyle(
                                                      color: Color(int.parse(
                                                          complaint[
                                                              'status_color']
                                                              .substring(
                                                                  1),
                                                          radix: 16)),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(complaint[
                                                'description']),
                                            const SizedBox(height: 8),
                                            if (complaint['photo_url'] !=
                                                null)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                child: Image.network(
                                                  complaint['photo_url'],
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            if (complaint[
                                                    'admin_notes'] !=
                                                null) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                        8),
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    const Text(
                                                      'Catatan Admin:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 4),
                                                    Text(
                                                      complaint[
                                                          'admin_notes'],
                                                      style:
                                                          const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
