import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/login/view.dart';


class HomeState with ChangeNotifier {}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Oficina do Paulo"),
        backgroundColor: Colors.blue.shade700,
      ),
      drawer: _Drawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              width: 200,
            ),
            _ItemsHome(),
          ],
        ),
      ),
    );
  }
}

class _ItemsHome extends StatelessWidget {
  const _ItemsHome();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ItemHome(
            label: 'Serviços',
            icon: Icons.add,
            subtitle: 'Registrar, editar ou visualizar serviços ativos',
            onPressed: () {
              context.push('/registerService');
            }),
        _ItemHome(
            label: 'Histórico Serviços',
            icon: Icons.account_balance,
            subtitle: 'Visualizar serviços que já foram finalizados',
            onPressed: () {}),
      ],
    );
  }
}

class _ItemHome extends StatelessWidget {
  const _ItemHome({
    required this.label,
    required this.subtitle,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Expanded(
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.grey.withAlpha(50),

                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Icon(
                          icon,
                          size: 30,
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: theme.disabledColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<LoginState>(context, listen: false).user;
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${user.name}',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('${user.email}',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Início"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_filter),
            title: Text("Digitalizar documento"),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Configurações"),
            onTap: () {
              context.go("/settings");
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sair"),
            onTap: () {
              context.go("/");
            },
          ),
        ],
      ),
    );
  }
}
