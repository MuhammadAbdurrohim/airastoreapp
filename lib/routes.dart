import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/live_stream_list_screen.dart';
import 'screens/live_streaming_screen.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String profile = '/profile';
  static const String liveStreams = '/live-streams';
  static const String liveStream = '/live-stream';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      productDetail: (context) {
        final productId = ModalRoute.of(context)!.settings.arguments as int;
        return ProductDetailScreen(productId: productId);
      },
      cart: (context) => const CartScreen(),
      checkout: (context) => const CheckoutScreen(),
      orderHistory: (context) => const OrderHistoryScreen(),
      orderDetail: (context) {
        final orderId = ModalRoute.of(context)!.settings.arguments as int;
        return OrderDetailScreen(orderId: orderId);
      },
      profile: (context) => const ProfileScreen(),
      liveStreams: (context) => const LiveStreamListScreen(),
      liveStream: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return LiveStreamingScreen(
          streamId: args['streamId'] as String,
          isHost: args['isHost'] as bool,
          userId: args['userId'] as String,
          userName: args['userName'] as String,
        );
      },
    };
  }
}
