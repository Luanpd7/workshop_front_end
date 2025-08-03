import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações do temas
class SettingsState with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  themeProvider() {
    _loadTheme();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('themeMode');

    if (savedTheme == ThemeMode.light.toString()) {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == ThemeMode.dark.toString()) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsState>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: Consumer<SettingsState>(
          builder: (context, state, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Text('Tema', style: Theme.of(context).textTheme.labelLarge,),
                    ),
                    RadioListTile(
                      title: Text('Claro'),
                      value: ThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        themeProvider.setTheme(value!);
                      },
                    ),
                    RadioListTile(
                      title: Text('Escuro'),
                      value: ThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        themeProvider.setTheme(value!);
                      },
                    ),
                    RadioListTile(
                      title: Text('Padrão do Sistema'),
                      value: ThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        themeProvider.setTheme(value!);
                      },
                    ),
                    Divider()
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
