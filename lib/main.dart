import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workshop_front_end/router/router.dart';

void main() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.3:8080/'));
    if (response.statusCode == 200) {
      print('Deu boa !!!');
    } else {
      print('Deu ruim');
    }
  } catch (e) {
    print('Deu ruim');
    print(e);
  }

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(),
        useMaterial3: true,
      ),
      routerConfig: RouterApp().router,
    );
  }
}
