import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Controllers for login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Controllers for register
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerWhatsappController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerWhatsappController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aira Grosir'),
        backgroundColor: Color(0xFF40C4B0),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Login Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _loginFormKey,
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _loginEmailController,
                    label: 'Email',
                    icon: FontAwesomeIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _loginPasswordController,
                    label: 'Password',
                    icon: FontAwesomeIcons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_loginFormKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final data = await ApiService().login(
                        email: _loginEmailController.text.trim(),
                        password: _loginPasswordController.text.trim(),
                      );
                      // Navigate to home screen on success
                      Navigator.of(context).pushReplacementNamed('/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: Color(0xFF40C4B0),
                    ),
                    child: Text('Masuk', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      child: Text('Belum punya akun? Daftar'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Register Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _registerFormKey,
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _registerNameController,
                    label: 'Nama Lengkap',
                    icon: FontAwesomeIcons.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _registerWhatsappController,
                    label: 'Nomor WhatsApp',
                    icon: FontAwesomeIcons.whatsapp,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor WhatsApp tidak boleh kosong';
                      }
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                        return 'Format nomor WhatsApp tidak valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _registerEmailController,
                    label: 'Email',
                    icon: FontAwesomeIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _registerPasswordController,
                    label: 'Password',
                    icon: FontAwesomeIcons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_registerFormKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final data = await ApiService().register(
                      name: _registerNameController.text.trim(),
                      email: _registerEmailController.text.trim(),
                      password: _registerPasswordController.text.trim(),
                      whatsapp: _registerWhatsappController.text.trim(),
                    );
                    // Navigate to home screen on success
                    Navigator.of(context).pushReplacementNamed('/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: Color(0xFF40C4B0),
                    ),
                    child: Text('Daftar', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _tabController.animateTo(0);
                      },
                      child: Text('Sudah punya akun? Masuk'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
