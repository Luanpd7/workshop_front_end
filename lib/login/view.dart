import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/domain/use_case_user.dart';

import '../id_context.dart';
import '../repository/repository_user.dart';
import '../util/modal.dart';
import 'entities/login.dart';

class LoginState with ChangeNotifier {
  LoginState();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  User? _user;
  bool _isManager = false;

  User? get user => _user;
  bool get isManager => _isManager;

  set user(User? value) {
    _user = value;
    notifyListeners();
  }

  set isManager(bool value) {
    _isManager = value;
    notifyListeners();
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordRepeatController.clear();
    passwordController.clear();
    notifyListeners();
  }

  Future<bool> saveForm(
      {required User user, required BuildContext context, required bool isSignUp}) async {
    clearFields();
    var state = Provider.of<LoginState>(context, listen: false);

    final repositoryUser = RepositoryUser();
    final useCaseUser = UseCaseUser(repositoryUser);
    final User? userResult;

    if (isSignUp) {
      var result = await useCaseUser.addNewUser(user: user);
      userResult = await useCaseUser.getLoginUser(user: user);
      UserContext().id = userResult?.id;
      if (userResult != null) {
        state.user = userResult;
      }
      return result;
    } else {
      userResult = await useCaseUser.getLoginUser(user: user);

      isManager = userResult?.id == 1;
      UserContext().id = userResult?.id;

      if (userResult != null) {
        state.user = userResult;
        return true;
      } else {
        return false;
      }
    }
  }
}

/// -----------------------------
/// LOGIN SCREEN
/// -----------------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Consumer<LoginState>(
          builder: (context, state, _) {
            return _LoginSignUpContainer(
              title: "Acessar",
              children: [
                _EmailInput(label: "E-mail", controller: state.emailController),
                _PasswordInput(
                  label: "Senha",
                  controller: state.passwordController,
                ),
              ],

              onConfirm: () async {
                final user = User(
                  email: state.emailController.text,
                  password: state.passwordController.text,
                  name: "", // opcional para login
                );
                bool result =
                await state.saveForm(user: user, context: context, isSignUp: false);

                if (result) {
                  if (context.mounted) {
                    context.go('/home', extra: state.isManager);
                  }
                } else if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialogUtil(
                      title: "Erro",
                      content: "Credênciais inválidas!",
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// -----------------------------
/// SIGN UP SCREEN
/// -----------------------------
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Consumer<LoginState>(
          builder: (context, state, _) {
            return _LoginSignUpContainer(
              title: "Novo mecânico",
              children: [
                _NameInput(label: "Digite seu nome:", controller: state.nameController),
                _EmailInput(label: "Digite seu e-mail:", controller: state.emailController),
                _PasswordInput(
                  label: "Digite uma nova senha:",
                  controller: state.passwordController,
                ),
                _PasswordInput(
                  label: "Digite novamente a senha:",
                  controller: state.passwordRepeatController,
                ),
              ],
              onConfirm: () async {
                if (state.passwordController.text !=
                    state.passwordRepeatController.text) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialogUtil(
                      title: "Erro",
                      content: "As senhas não coincidem!",
                    ),
                  );
                  return;
                }

                final user = User(
                  name: state.nameController.text,
                  email: state.emailController.text,
                  password: state.passwordController.text,
                );

                bool result =
                await state.saveForm(user: user, context: context, isSignUp: true);

                if (result && context.mounted) {
                  context.go('/home', extra: state.isManager);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// -----------------------------
/// COMPONENTE BASE REUTILIZÁVEL
/// -----------------------------
class _LoginSignUpContainer extends StatelessWidget {
  const _LoginSignUpContainer({
    required this.title,
    required this.children,
    required this.onConfirm,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LoginState>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
        width: 380,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.grey.withAlpha(10)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(width: 0.5, color: Colors.lightBlue),
        ),
        child: Form(
          key: state._formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TitleLogin(label: title),
              ...children,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Row(
                  spacing: 25.0,
                  children: [
                    Expanded(child: _CancelButton(onPressed: state.clearFields)),
                    Expanded(
                      child: _ConfirmButton(onPressed: () {
                        if (state._formKey.currentState!.validate()) {
                          onConfirm();
                        }
                      }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// WIDGETS REUTILIZÁVEIS
/// -----------------------------
class _TitleLogin extends StatelessWidget {
  const _TitleLogin({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(label, style: theme.textTheme.titleLarge),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 0.3, color: Colors.lightBlue),
            ),
            child: TextFormField(
              validator: validator,
              obscureText: true,
              decoration: const InputDecoration(enabledBorder: InputBorder.none),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 0.3, color: Colors.lightBlue),
            ),
            child: TextFormField(
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(enabledBorder: InputBorder.none),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 0.3, color: Colors.lightBlue),
            ),
            child: TextFormField(
              validator: validator,
              decoration: const InputDecoration(enabledBorder: InputBorder.none),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade900,
      ),
      onPressed: onPressed,
      child: Text("Cancelar", style: theme.textTheme.titleSmall),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade900,
      ),
      onPressed: onPressed,
      child: Text("Confirmar", style: theme.textTheme.titleSmall),
    );
  }
}

String? validator(String? value) {
  if (value!.isEmpty) return "Precisa preencher o campo";
  if (value.trim().length < 3) return "Mínimo de caracteres é 3";
  return null;
}
