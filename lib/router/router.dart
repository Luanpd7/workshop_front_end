import 'package:go_router/go_router.dart';
import 'package:workshop_front_end/customer/list_customer.dart';
import 'package:workshop_front_end/login/view.dart';
import 'package:workshop_front_end/service/list_service.dart';
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
        builder: (context, state) {

  final isManager = state.extra as bool?;
  return Home(isManager: isManager,);
  }



      ),
      GoRoute(
        path: '/listCustomers',
        builder: (context, state) => ListCustomer(),
      ),
      GoRoute(
        path: '/listService',
        builder: (context, state) => ListService(),
      ),
      GoRoute(
        path: '/registerService',
        builder: (context, state) => ServiceTab(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Settings(),
      ),
      GoRoute(
        path: '/homeManager',
        builder: (context, state) => ServiceTab(),
      ),
    ],
  );
}
