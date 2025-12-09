import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../models/client.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Main screen responsible for creating or editing a client.
class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final controller = ClientFormController();

  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    controller.initialize(widget.client);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _save() {
    if (controller.formKey.currentState!.validate()) {
      final client = controller.buildClient(widget.client);
      final provider = context.read<ClientProvider>();

      isEditing ? provider.updateClient(client) : provider.createClient(client);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClientFormAppBar(isEditing: isEditing, onSave: _save),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ClientFormFields(
              controller: controller,
              isEditing: isEditing,
              onSave: _save,
            ),
            Consumer<ClientProvider>(
              builder: (_, provider, __) =>
                  ClientErrorBox(error: provider.error),
            ),
          ],
        ),
      ),
    );
  }
}



/// Controller handling text controllers, masks, initialization and client build.
class ClientFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void initialize(Client? client) {
    if (client != null) {
      nameController.text = client.name;
      phoneController.text = client.phone;
      emailController.text = client.email ?? '';
    }
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }

  Client buildClient(Client? existing) {
    return Client(
      id: existing?.id,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      registrationDate: existing?.registrationDate ?? DateTime.now(),
    );
  }
}



/// AppBar showing screen title, save button and loading indicator.
class ClientFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;
  final VoidCallback onSave;

  const ClientFormAppBar({
    super.key,
    required this.isEditing,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        Consumer<ClientProvider>(
          builder: (context, provider, _) {
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
              onPressed: onSave,
              child: const Text('Salvar'),
            );
          },
        ),
      ],
    );
  }
}



/// Widget containing all text fields and form validations.
class ClientFormFields extends StatelessWidget {
  final ClientFormController controller;
  final bool isEditing;
  final VoidCallback onSave;

  const ClientFormFields({
    super.key,
    required this.controller,
    required this.isEditing,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
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

          TextFormField(
            controller: controller.phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone *',
              hintText: '(11) 99999-9999',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [controller.phoneMask],
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

          TextFormField(
            controller: controller.emailController,
            decoration: const InputDecoration(
              labelText: 'Email (opcional)',
              hintText: 'cliente@email.com',
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Atualizar Cliente' : 'Criar Cliente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// Widget showing provider error inside a styled red container.
class ClientErrorBox extends StatelessWidget {
  final String? error;

  const ClientErrorBox({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

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
              error!,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }
}

