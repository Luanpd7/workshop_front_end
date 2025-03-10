import 'package:go_router/go_router.dart';
import 'package:workshop_front_end/login/view.dart';
import 'package:workshop_front_end/setting/view.dart';

import '../home/home.dart';
import '../scanner/scanner_photo.dart';
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
        path: '/scanner',
        builder: (context, state) => NotaFiscalScanner(),
      ),
    ],
  );
}