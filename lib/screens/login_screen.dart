import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mechanic_provider.dart';
import '../models/mechanic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MechanicProvider>().loadMechanics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(Icons.build_circle, size: 100, color: Colors.white),
                  const SizedBox(height: 24),

                  Text(
                    'Sistema de Oficina',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 48),

                  _ManagerAndMechanicCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _ManagerAndMechanicCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecione seu perfil',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthProvider>().loginAsManager();
              },
              icon: const Icon(Icons.person_outline, size: 28),
              label: const Text('Entrar como Gerente', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OU', style: TextStyle(color: Colors.grey[600])),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Selecione um mecânico:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            _MechanicDropdown(),
          ],
        ),
      ),
    );
  }
}

class _MechanicDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MechanicProvider>(
      builder: (context, mechanicProvider, child) {
        if (mechanicProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (mechanicProvider.mechanics.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nenhum mecânico cadastrado',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<Mechanic>(
          decoration: InputDecoration(
            labelText: 'Mecânico',
            prefixIcon: const Icon(Icons.build),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: mechanicProvider.mechanics.map((mechanic) {
            return DropdownMenuItem<Mechanic>(
              value: mechanic,
              child: Text(mechanic.name),
            );
          }).toList(),
          onChanged: (mechanic) {
            if (mechanic != null) {
              context.read<AuthProvider>().loginAsMechanic(mechanic.id!);
            }
          },
        );
      },
    );
  }
}

