import 'package:go_router/go_router.dart';
import 'package:workshop_front_end/customer/list_customer.dart';
import 'package:workshop_front_end/login/view.dart';
import 'package:workshop_front_end/setting/view.dart';

import '../home/home.dart';
import '../service/tabService.dart';

class RouterApp {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Login(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => Home(),
      ),
      GoRoute(
        path: '/listCustomers',
        builder: (context, state) => ListCustomer(),
      ),

      GoRoute(
        path: '/registerService',
        builder: (context, state) => ServiceTab(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Settings(),
      ),
    ],
  );
}
