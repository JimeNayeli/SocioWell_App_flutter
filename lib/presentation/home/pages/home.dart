import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/common/widgets/notifications/social_media_notification.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';
import 'package:tesis_v2/domain/usescases/auth/logout.dart';
import 'package:tesis_v2/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:tesis_v2/presentation/home/pages/app_info.dart';
import 'package:tesis_v2/presentation/home/widgets/home_top_card.dart';
import 'package:tesis_v2/presentation/home/widgets/instructions.dart';
import 'package:tesis_v2/presentation/intro/pages/get_started.dart';
import '../../../service_locator.dart';

class HomePage extends StatefulWidget {
  final String fullName;
  // ignore: use_super_parameters
  const HomePage({Key? key, required this.fullName}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  bool _isLoading = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeBackgroundMonitor();
  }

  Future<void> _initializeBackgroundMonitor() async {
  await BackgroundMonitor.initialize();
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Fondo verde
        Container(
          color: AppColors.backTab,
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
        ),
        Column(
          children: [
            // Fila con tres íconos: uno a la izquierda, usuario al centro, logout a la derecha
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ícono a la izquierda
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? AppColors.backCard : Colors.white, // Fondo del círculo
                        shape: BoxShape.circle, 
                      ),
                      padding: const EdgeInsets.all(12), 
                      child: Icon(
                        context.isDarkMode ? Icons.light_mode : Icons.dark_mode, // Alterna entre los íconos
                        color: context.isDarkMode ? Colors.white : AppColors.backCard, // Color del ícono
                      ),
                    ),
                    onPressed: () {
                      // Cambiar el modo usando ThemeCubit
                      context.read<ThemeCubit>().updateTheme(
                        context.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );

                      // Mostrar un mensaje
                      var snackbar = SnackBar(
                        content: Text(
                          context.isDarkMode ? "Light Mode Activado" : "Dark Mode Activado",
                        ),
                        behavior: SnackBarBehavior.floating,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    },
                  ),

                  // Ícono de usuario en el centro
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: context.isDarkMode ? AppColors.backCard : Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: context.isDarkMode ? Colors.white : AppColors.backCard,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar Sesión'),
                          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() => _isLoading = true);

                                var result = await sl<LogoutCase>().call();

                                setState(() => _isLoading = false);

                                result.fold(
                                  (l) {
                                    var snackbar = SnackBar(
                                      content: Text(l),
                                      behavior: SnackBarBehavior.floating,
                                    );
                                    scaffoldMessengerKey.currentState?.showSnackBar(snackbar);
                                  },
                                  (r) {
                                    var snackbar = SnackBar(
                                      content: Text(r),
                                      behavior: SnackBarBehavior.floating,
                                    );
                                    scaffoldMessengerKey.currentState?.showSnackBar(snackbar);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const GetStartedPage()),
                                      (route) => false,
                                    );
                                  },
                                );
                              },
                              child: const Text('Cerrar Sesión'),
                            ),



                          ],
                        ),
                      );
                    },
                    icon: Container(
                      width: 50, // Ajusta el tamaño del círculo
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.backCard, // Fondo negro
                        shape: BoxShape.circle, // Forma circular
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white, // Icono blanco
                        size: 30, // Tamaño del ícono
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // Texto debajo del ícono de usuario
            Column(
              children: [
                Text(
                  'Bienvenid@ ${widget.fullName}',
                  style: TextStyle(
                    fontSize: 20,
                    color: context.isDarkMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _tabs(),
              ],
            ),

            // Parte inferior blanca con contenido
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InstructionCard(),
                    HomeTopCard(),
                    const AppInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor:  Colors.black,
      indicatorColor:  Colors.black,
      unselectedLabelColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 20
      ),
      tabs: const [
        Text(
          'Instrucciones',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        Text(
          'Cuestionario\n de uso',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15
          ),
        ),
        Text(
          'Información\n de uso',
           style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15
          ),
        )
      ],
    );
  }
}

