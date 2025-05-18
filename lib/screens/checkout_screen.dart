import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'Bank';
  File? _paymentProof;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPaymentProof() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _paymentProof = File(pickedFile.path);
      });
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement API call to submit order with address, payment method, and payment proof

    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pesanan berhasil dikirim')),
    );

    Navigator.of(context).pushReplacementNamed('/order-history');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFF40C4B0),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Pengiriman',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Masukkan alamat lengkap',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat pengiriman wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Estimasi Ongkos Kirim: Rp 10.000',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Metode Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: const Text('Bank'),
                      leading: Radio<String>(
                        value: 'Bank',
                        groupValue: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      trailing: Icon(Icons.account_balance),
                    ),
                    ListTile(
                      title: const Text('E-Wallet'),
                      leading: Radio<String>(
                        value: 'E-Wallet',
                        groupValue: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      trailing: Icon(Icons.account_balance_wallet),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Upload Bukti Transfer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickPaymentProof,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey[200],
                        ),
                        child: _paymentProof == null
                            ? Center(child: Text('Tap untuk memilih gambar'))
                            : Image.file(_paymentProof!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF40C4B0),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Kirim Pesanan',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
