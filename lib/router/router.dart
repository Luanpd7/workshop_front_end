import 'package:go_router/go_router.dart';
import 'package:workshop_front_end/login/view.dart';
import '../customer/view.dart';
import '../home/home.dart';
import '../service/tabService.dart';


class RouterApp{
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
        path: '/registerService',
        builder: (context, state) => ServiceTab(),
      ),
    ],
  );
}