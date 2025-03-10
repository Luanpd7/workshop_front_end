import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../repository/repository_user.dart';
import '../util/modal.dart';

class LoginState with ChangeNotifier {
  LoginState() ;


  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;

  bool get isSignUp => _isSignUp;


  set isSignUp(bool value) {
    _isSignUp = value;
    notifyListeners();
  }

  void clearFields() {
    nomeController.clear();
    emailController.clear();
    passwordRepeatController.clear();
    passwordController.clear();
    notifyListeners();
  }


  Future<bool> saveForm() async {
   final repositoryUser = RepositoryUser();
    return await repositoryUser.getLoginUser(
     email: emailController.text,
     password: passwordController.text,
   );
  }


}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<LoginState>(
      create: (context) => LoginState(),
      child: Scaffold(
        backgroundColor: Colors.lightBlue.shade900,
        body: Center(
          child: Consumer<LoginState>(
            builder: (context, state, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
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
                          _NameInput(),
                          _EmailInput(label: 'Digite seu e-mail:'),
                          _PasswordInput(label: 'Digite uma nova senha:',
                            controller: state.passwordController,),
                          _PasswordInput(label: 'Digite novamente a senha:',
                            controller: state.passwordRepeatController,),
                        ],
                        if (!state.isSignUp) ...[
                          _EmailInput(label: 'Emai-l',),
                          _PasswordInput(label: 'Senha',
                            controller: state.passwordController,),
                        ],
                        Focus(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: GestureDetector(
                              child: Text(
                                state.isSignUp
                                    ? 'Já tenho conta.'
                                    : 'Não tenho login.',
                                style: TextStyle(color: Colors.red,
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
                                child: _ConfirmButton(
                                  onPressed: () async {
                                    if(!state.isSignUp) {
                                      bool result = await state.saveForm();
                                      if (result) {
                                        context.go('/home');
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialogUtil(
                                                title: 'Erro',
                                                content: 'Credênciais inválidas!',
                                              );
                                            }
                                        );
                                      }
                                    }
                                  }
                                ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 25, color: Colors.lightBlue.shade900),
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
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.lightBlue.shade900),),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
    var state = Provider.of<LoginState>(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label , style: TextStyle(color: Colors.lightBlue.shade900),),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<LoginState>(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Digite seu nome:' , style: TextStyle(color: Colors.lightBlue.shade900),),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
              controller: state.nomeController,
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade900,
      ),
      onPressed: onPressed,
      child: Text(
        'Cancelar',
          style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onPressed});

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<LoginState>(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade900,
      ),
      child: Text('Confirmar'   , style: TextStyle(color: Colors.white),),
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

  if (value
      .trim()
      .length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}




