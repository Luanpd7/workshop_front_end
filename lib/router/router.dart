import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:workshop_front_end/customer/custom_view.dart';
import 'package:workshop_front_end/customer/list_customer.dart';
import 'package:workshop_front_end/login/view.dart';
import 'package:workshop_front_end/mechanic/mechanic_area.dart';
import 'package:workshop_front_end/service/entities/service_form_mechanic.dart';
import 'package:workshop_front_end/service/list_service.dart';
import 'package:workshop_front_end/service/service_form.dart';
import 'package:workshop_front_end/setting/view.dart';
import 'package:workshop_front_end/vehicle/vehicle_list.dart';
import '../home/home.dart';
import '../vehicle/vehicle_form.dart';

class RouterApp {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LoginScreen(),
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
        path: '/registerCustomer',
        builder: (context, state) => RegisterCustomer(isEdit: false),
      ),
      GoRoute(
        path: '/registerFormService/:id',
        builder: (BuildContext context, GoRouterState state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) throw Exception('ID inválido');

          return ServiceFormMechanic(id);
        },
      ),
      GoRoute(
        path: '/listService',
        builder: (context, state) => ListService(),
      ),
      GoRoute(
        path: '/listServiceToAnalyse',
        builder: (context, state) => ListServiceOfMechanic(screenToAnalyse: true),
      ),
      GoRoute(
        path: '/registerService',
        builder: (context, state) => RegisterService(),
      ),
      GoRoute(
        path: '/listVehicle',
        builder: (context, state) => ListVehicle(),
      ),
      GoRoute(
        path: '/listServiceOfMechanic',
        builder: (context, state) => ListServiceOfMechanic(screenToAnalyse: false,),
      ),
      GoRoute(
        path: '/registerVehicle',
        builder: (context, state) => RegisterVehicle(isEdit: false),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Settings(),
      ),
      GoRoute(
        path: '/homeManager',
        builder: (context, state) => RegisterService(),
      ),
    ],
  );
}
