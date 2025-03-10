
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeState with ChangeNotifier{
  
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade900,
      appBar: AppBar(title: Text("Oficina do Paulo"),
      backgroundColor: Colors.blue.shade700,
      ),

      drawer: _Drawer(),
      body: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: [
              Container(
                height: 350,
                width: 200,
              ),
              _ItemsHome(),
            ],
          ),
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
        _ItemHome(label: 'Digitar serviço', icon: Icons.add),
        _ItemHome(label: 'Lista de serviços', icon: Icons.list),

      ],
    );
  }
}



class _ItemHome extends StatelessWidget {
  const _ItemHome({ required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    child: Expanded(
      child: Container(
        height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        gradient: LinearGradient(
          colors: [
            Colors.grey.withAlpha(10),
            Colors.blueGrey,
          ],
            ),
      ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Theme.of(context).textTheme.headlineMedium,),
                  Icon(icon, size: 30,),
                ],
              ),),
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text("Usuário", style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("email@example.com", style: TextStyle(color: Colors.white70)),
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
              context.go("/scanner");
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Configurações"),
            onTap: () {
              context.go("/tarefa");
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


