import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsState with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade900,
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: ChangeNotifierProvider(
          create: (context) => SettingsState(),
          child: Consumer<SettingsState>(
            builder: (context, state, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text('Tema'),
                      Radio(
                        value: ThemeMode.light,
                        groupValue: state.themeMode,
                        onChanged: (ThemeMode? value) {
                          state.setTheme(value!);
                        },
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
