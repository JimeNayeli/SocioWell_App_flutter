import 'package:flutter/material.dart';
import 'package:tesis_v2/common/widgets/appbar/app_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tesis_v2/core/configs/assets/app_vectors.dart';
import 'package:tesis_v2/data/models/auth/signin_user_req.dart';
import 'package:tesis_v2/domain/usescases/auth/signin_google.dart';
import '../../../common/widgets/button/basic_app_button.dart';
import '../../../domain/usescases/auth/signin.dart';
import '../../../service_locator.dart';
import '../../home/pages/home.dart';
import 'package:tesis_v2/presentation/auth/pages/signup.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : BasicAppButton(
                    onPressed: () async {
                      if (_email.text.isEmpty || _password.text.isEmpty) {
                        var snackbar = const SnackBar(
                          content: Text("Por favor, completa todos los campos."),
                          behavior: SnackBarBehavior.floating,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        return;
                      }

                      setState(() {
                        _isLoading = true; // Mostrar el círculo de carga
                      });

                      var result = await sl<SigninUseCase>().call(
                        params: SigninUserReq(
                          email: _email.text.toString(),
                          password: _password.text.toString(),
                        ),
                      );

                      setState(() {
                        _isLoading = false; // Ocultar el círculo de carga
                      });

                      result.fold(
                        (l) {
                          var snackbar = SnackBar(
                            content: Text(l),
                            behavior: SnackBarBehavior.floating,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        (r) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  HomePage(fullName: r.fullName),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    },
                    title: 'Ingresar',
                  ),
            const SizedBox(height: 25),
            const Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey, // Cambia el color de la línea si es necesario
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "o",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
            _googleSignInButton(), // Botón de Google Sign-In
          ],
        ),
      ),
    );
  }

Widget _googleSignInButton() {
  return GestureDetector(
    onTap: () async {
      setState(() => _isLoading = true);
      var result = await sl<SigninGoogleCase>().call();
      setState(() => _isLoading = false);
      
      result.fold(
        (l) {
          var snackbar = SnackBar(
            content: Text(l),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        (r) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => HomePage(fullName: r.fullName),
            ),
            (route) => false,
          );
        },
      );
    },
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppVectors.google,  // Asegúrate de tener definida esta constante
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuar con Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _registerText() {
    return const Text(
      'Inicio de Sesión',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(hintText: 'Correo electrónico')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

   Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: !_isPasswordVisible, // Cambia según el estado de visibilidad
      decoration: InputDecoration(
        hintText: 'Contraseña',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Cambia el estado
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No tienes cuenta? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignupPage(),
                ),
              );
            },
            child: const Text('Regístrate ahora!'),
          ),
        ],
      ),
    );
  }
}
