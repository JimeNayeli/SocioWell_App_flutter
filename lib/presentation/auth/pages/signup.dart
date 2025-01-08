import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tesis_v2/common/widgets/appbar/app_bar.dart';
import 'package:tesis_v2/common/widgets/button/basic_app_button.dart';
import 'package:tesis_v2/core/configs/assets/app_vectors.dart';
import 'package:tesis_v2/data/models/auth/create_user_req.dart';
import 'package:tesis_v2/domain/usescases/auth/signup.dart';
import 'package:tesis_v2/presentation/auth/pages/signin.dart';
import 'package:tesis_v2/presentation/home/pages/home.dart';
import 'package:tesis_v2/service_locator.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> _isConfirmPasswordVisible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _siginText(context),
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 30
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 30,),
            _fullNameField(context),
            const SizedBox(height: 20,),
            _emailField(context),
            const SizedBox(height: 20,),
            _passwordField(context),
            const SizedBox(height: 20,),
            _confirmPasswordField(context),
            const SizedBox(height: 20,),
            BasicAppButton(
              onPressed: () async {
                if (_email.text.isEmpty || _password.text.isEmpty || _confirmPassword.text.isEmpty) {
                  var snackbar = const SnackBar(
                    content: Text("Por favor, completa todos los campos."),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  return;
                }
                
                if (_password.text != _confirmPassword.text) {
                  var snackbar = const SnackBar(
                    content: Text("Las contraseñas no coinciden."),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  return;
                }

                var result = await sl<SignupUseCase>().call(
                  params: CreateUserReq(
                    fullName: _fullName.text.toString(),
                    email: _email.text.toString(),
                    password: _password.text.toString()
                  )
                );
                result.fold(
                  (l){
                    var snackbar = SnackBar(content: Text(l),behavior: SnackBarBehavior.floating,);
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  },
                  (r){
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (BuildContext context) => HomePage(fullName: _fullName.text),), 
                      (route) => false
                    );
                  }
                );
              },
              title: 'Crear Cuenta'
            )
          ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Registrar',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        hintText: 'Nombre'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Correo electrónico'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPasswordVisible,
      builder: (context, isVisible, child) {
        return TextField(
          controller: _password,
          obscureText: !isVisible, // Cambia según el estado de visibilidad
          decoration: InputDecoration(
            hintText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                _isPasswordVisible.value = !_isPasswordVisible.value; // Cambia el estado
              },
            ),
          ).applyDefaults(
            Theme.of(context).inputDecorationTheme,
          ),
        );
      },
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isConfirmPasswordVisible,
      builder: (context, isVisible, child) {
        return TextField(
          controller: _confirmPassword,
          obscureText: !isVisible, // Cambia según el estado de visibilidad
          decoration: InputDecoration(
            hintText: 'Confirmar Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value; // Cambia el estado
              },
            ),
          ).applyDefaults(
            Theme.of(context).inputDecorationTheme,
          ),
        );
      },
    );
  }

  Widget _siginText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ya tienes cuenta? ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SigninPage()
                )
              );
            },
            child: const Text(
              'Iniciar Sesión'
            )
          )
        ],
      ),
    );
  }
}
