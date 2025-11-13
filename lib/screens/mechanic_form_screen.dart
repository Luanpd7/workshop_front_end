import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../providers/mechanic_provider.dart';
import '../models/mechanic.dart';

class MechanicFormScreen extends StatefulWidget {
  final Mechanic? mechanic;

  const MechanicFormScreen({super.key, this.mechanic});

  @override
  State<MechanicFormScreen> createState() => _MechanicFormScreenState();
}

class _MechanicFormScreenState extends State<MechanicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool get isEditing => widget.mechanic != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.mechanic!.name;
      _phoneController.text = widget.mechanic!.phone;
      _emailController.text = widget.mechanic!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Mascara dinâmica para telefone brasileiro (10 ou 11 dígitos)
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { '#': RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );


  void _saveMechanic() {
    if (_formKey.currentState!.validate()) {
      final mechanic = Mechanic(
        id: widget.mechanic?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        registrationDate: widget.mechanic?.registrationDate ?? DateTime.now(),
      );

      if (isEditing) {
        context.read<MechanicProvider>().updateMechanic(mechanic);
      } else {
        context.read<MechanicProvider>().createMechanic(mechanic);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Mecânico' : 'Novo Mecânico'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<MechanicProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: _saveMechanic,
                child: const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Digite o nome completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Campo Telefone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone *',
                  hintText: '(11) 99999-9999',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Telefone é obrigatório';
                  }
                  if (value.trim().length < 10) {
                    return 'Telefone deve ter pelo menos 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                  hintText: 'mecanico@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return 'Email inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveMechanic,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Atualizar Mecânico' : 'Criar Mecânico'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Mostrar erro se houver
              Consumer<MechanicProvider>(
                builder: (context, provider, child) {
                  if (provider.error != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}




