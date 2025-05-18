import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://your-api-domain.com/api';
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Order Management
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['orders']);
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['order'];
      }
      throw Exception('Failed to load order details');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? fcmToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: json.encode({
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
          'items': items,
          'fcm_token': fcmToken,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create order');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadPaymentProof(
    int orderId,
    File proofImage,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/upload-proof');
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        })
        ..files.add(
          await http.MultipartFile.fromPath('proof', proofImage.path),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to upload payment proof');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> completeOrder(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/complete'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to complete order');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> submitComplaint(int orderId, String description, File photo) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orders/$orderId/complaints'),
      )
        ..headers.addAll({
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        })
        ..fields['description'] = description
        ..files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw Exception('Failed to submit complaint');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> trackShipment(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId/track'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['tracking'];
      }
      throw Exception('Failed to track shipment');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> updateFCMToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/update-fcm-token'),
        headers: _headers,
        body: json.encode({'fcm_token': fcmToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to cancel order');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        return data;
      }
      throw Exception('Login failed');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _headers,
      );

      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Products
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['products']);
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['product'];
      }
      throw Exception('Failed to load product details');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Cart
  static Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: _headers,
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to add to cart');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load cart');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCartItem(
    int cartItemId,
    int quantity,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _headers,
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update cart item');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> removeFromCart(int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from cart');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Live Streaming Methods
  static Future<List<Map<String, dynamic>>> getActiveStreams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/live/streams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to get active streams');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getStreamDetails(String streamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/live/streams/$streamId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get stream details');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> joinStream(String streamId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live/streams/$streamId/join'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to join stream');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> leaveStream(String streamId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live/streams/$streamId/leave'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to leave stream');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLiveComments(String streamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/live/streams/$streamId/comments'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to get comments');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> sendLiveComment(String streamId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/live/streams/$streamId/comments'),
        headers: _headers,
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to send comment');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLiveProducts(String streamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/live/streams/$streamId/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to get stream products');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
