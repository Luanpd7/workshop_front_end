import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/domain/use_case_user.dart';

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

  late User _user;

  bool _isSignUp = false;

  bool get isSignUp => _isSignUp;

  User get user => _user;

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set isSignUp(bool value) {
    _isSignUp = value;
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
      {required User user, required BuildContext context}) async {
    var state = Provider.of<LoginState>(context, listen: false);

    final repositoryUser = RepositoryUser();
    final useCaseUser = UseCaseUser(repositoryUser);
    final User? userResult;

    if (_isSignUp) {
      return await useCaseUser.addNewUser(user: user);
    } else {
      userResult = await useCaseUser.getLoginUser(user: user);

      if (userResult != null) {
        state.user = userResult;
        return true;
      } else {
        return false;
      }
    }
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Consumer<LoginState>(
          builder: (context, state, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 380,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.grey.withAlpha(10),
                    ],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  border: Border.all(
                    width: 0.5,
                    color: Colors.lightBlue,
                  ),
                ),
                child: Form(
                  key: state._formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: _TitleLogin(
                          label: state.isSignUp ? 'Inscrever-se' : 'Acessar',
                        ),
                      ),
                      if (state.isSignUp) ...[
                        _NameInput(label : 'Digite seu nome:'),
                        _EmailInput(label: 'Digite seu e-mail:'),
                        _PasswordInput(
                          label: 'Digite uma nova senha:',
                          controller: state.passwordController,
                        ),
                        _PasswordInput(
                          label: 'Digite novamente a senha:',
                          controller: state.passwordRepeatController,
                        ),
                      ],
                      if (!state.isSignUp) ...[
                        _NameInput(
                          label: 'Usuário',
                        ),
                        _PasswordInput(
                          label: 'Senha',
                          controller: state.passwordController,
                        ),
                      ],
                      Focus(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: GestureDetector(
                            child: Text(
                              state.isSignUp
                                  ? 'Já tenho conta.'
                                  : 'Não tenho login.',
                              style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              state.clearFields();
                              state.isSignUp = !state.isSignUp;
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 25.0,
                          children: [
                            Expanded(
                              child: _CancelButton(
                                onPressed: state.clearFields,
                              ),
                            ),
                            Expanded(
                              child: _ConfirmButton(onPressed: () async {
                                final user = User(
                                  name: state.nameController.text,
                                  email: state.emailController.text,
                                  password: state.passwordController.text,
                                );
                                bool result = await state.saveForm(
                                    user: user, context: context);
                                if (result) {
                                  if (context.mounted) {
                                    context.go('/home');
                                  }
                                } else if (context.mounted) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialogUtil(
                                          title: 'Erro',
                                          content: 'Credênciais inválidas!',
                                        );
                                      });
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
          },
        ),
      ),
    );
  }
}

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _TitleLogin extends StatelessWidget {
  const _TitleLogin({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(
        label,
        style: theme.textTheme.titleLarge,
      ),
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
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                width: 0.3,
                color: Colors.lightBlue,
              ),
            ),
            child: TextFormField(
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
              ),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var state = Provider.of<LoginState>(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                width: 0.3,
                color: Colors.lightBlue,
              ),
            ),
            child: TextFormField(
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
              ),
              controller: state.emailController,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var state = Provider.of<LoginState>(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                width: 0.3,
                color: Colors.lightBlue,
              ),
            ),
            child: TextFormField(
              validator: validator,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
              ),
              controller: state.nameController,
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
      child: Text(
        'Cancelar',
        style: theme.textTheme.titleSmall,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onPressed});

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var state = Provider.of<LoginState>(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade900,
      ),
      child: Text(
        'Confirmar',
        style: theme.textTheme.titleSmall,
      ),
      onPressed: () {
        if (state._formKey.currentState!.validate()) {
          onPressed();
        }
      },
    );
  }
}

String? validator(String? value) {
  if (value!.isEmpty) {
    return 'Precisa preencher o campo';
  }

  if (value.trim().length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}
