import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController(text: 'User Name');
  final TextEditingController waController = TextEditingController(text: '08123456789');
  final TextEditingController emailController = TextEditingController(text: 'user@example.com');

  void _saveProfile() {
    // TODO: Implement save profile logic
  }

  void _logout() {
    // TODO: Implement logout logic
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: waController,
              decoration: InputDecoration(labelText: 'No WA'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
