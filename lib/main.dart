import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/repository/api_config.dart';
import 'package:workshop_front_end/router/router.dart';
import 'package:http/http.dart' as http;
import 'package:workshop_front_end/setting/view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'customer/view.dart';
import 'login/view.dart';

final Logger _logger = Logger('RepositoryCustomer');

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.indigo,
  scaffoldBackgroundColor: Color(0xFFD6EAF8),
  appBarTheme: AppBarTheme(backgroundColor: Colors.blue[100]),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey,

  /// cor 2 gradient no item home
  scaffoldBackgroundColor: Colors.lightBlue.shade900,
  appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey[900]),
);

void main() async {
  try {
    final baseURl = ApiConfig().baseUrl;
    final response = await http.get(
      Uri.parse('$baseURl/get_servidor'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      _logger.info('Servidor rodando no front');
    }
  } catch (e) {
    _logger.severe('Não rodou $e');
  }
  runApp(
    MultiProvider(

      providers: [
        ChangeNotifierProvider<LoginState>(
          create: (context) => LoginState(),
        ),
        ChangeNotifierProvider<SettingsState>(
          create: (context) => SettingsState(),
        ),
        ChangeNotifierProvider<CustomerState>(
          create: (context) => CustomerState(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsState>(context);

    return MaterialApp.router(
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
     // supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: RouterApp().router,
    );
  }
}
