import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:tesis_v2/presentation/intro/bloc/consent_cubit.dart';
import 'package:usage_stats_new/usage_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionManager {
  Future<bool> requestPermissions(BuildContext context) async {
    bool allGranted = true;
    final consentCubit = context.read<ConsentCubit>();
    if (!consentCubit.state) {
      final consentGranted = await _showConsentDialog(context);
      if (consentGranted) {
        consentCubit.grantConsent(); 
      } else {
        allGranted = false;
      }
    }

    // Solicitar permiso de notificaciones
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        allGranted = false;
      }
    }

    // Solicitar permiso de usage stats
    final hasUsagePermission = await UsageStats.checkUsagePermission();
    if (hasUsagePermission == null || !hasUsagePermission) {
      await UsageStats.grantUsagePermission();

      final recheckPermission = await UsageStats.checkUsagePermission();
      if (recheckPermission == null || !recheckPermission) {
        allGranted = false;
      }
    }

    // Verificar y solicitar desactivación de optimización de batería
    final isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    if (isBatteryOptimizationDisabled != null && !isBatteryOptimizationDisabled) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      final recheckBatteryOptimization =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;

      if (recheckBatteryOptimization == null || !recheckBatteryOptimization) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  Future<bool> _showConsentDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Consentimiento de Datos Personales'),
              content: const Text(
                'Al aceptar, permites el tratamiento de tus datos personales para fines investigativos y de mejora del servicio. ¿Deseas continuar?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No aceptar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
