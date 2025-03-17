import 'package:flutter/material.dart';

import '../customer/view.dart';

class ServiceTab extends StatelessWidget {
  const ServiceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.lightBlue.shade900,
        appBar: AppBar(
          title: const Text("Registrar serviço"),
          backgroundColor: Colors.blue.shade700,
          bottom: const TabBar(
            labelColor: Colors.white,
            dividerColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Cliente", icon: Icon(Icons.people)),
              Tab(text: "Serviço", icon: Icon(Icons.build)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RegisterCustomer(),
            RegisterCustomer(),
          ],
        ),
      ),
    );
  }
}

