
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tesis_v2/common/widgets/button/basic_app_button.dart';
import 'package:tesis_v2/core/configs/assets/app_images.dart';
import 'package:tesis_v2/core/configs/assets/app_vectors.dart';
import 'package:tesis_v2/presentation/choose_mode/pages/choose_mode.dart';
import 'package:tesis_v2/common/helpers/permission.dart';

class GetStartedPage extends StatelessWidget{
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
            horizontal: 40),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  AppImages.introBG,
                )
              ) 
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40
            ),
            child: Column(
                children: [
                  Flexible(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(
                      AppVectors.logo,
                    ),
                  ),
                ),
                  
                const Spacer(),
                const Text(
                  'Bienvenido a la aplicación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 21,),
                  const Text(
                    'Otorga todos todos los permisos para usar la app',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40,),
                    BasicAppButton(
                      onPressed: () async {
                        bool permissionsGranted = await PermissionManager().requestPermissions(context);
                        if (permissionsGranted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => const ChooseModePage()
                                )
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se otorgaron todos los permisos.')),
                          );
                        }                                          
                      },
                      title: 'Empecemos')
                ],
              ),
          ),

        ],
      ),
    );
  }

}