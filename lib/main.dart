import 'package:flutter/material.dart';
import 'package:tesis_v2/core/configs/theme/app_theme.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tesis_v2/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:tesis_v2/presentation/intro/bloc/consent_cubit.dart';
import 'package:tesis_v2/presentation/splash/pages/splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesis_v2/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesis_v2/firebase_options.dart';
import 'package:flutter/foundation.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await initializeDependencies();
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ConsentCubit()),
      ],
      child: BlocBuilder<ThemeCubit,ThemeMode>(
        builder: (context,mode) => MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode, 
          debugShowCheckedModeBanner: false,
          home: const SplashPage()
        ),
      ),
    );
  }
}
