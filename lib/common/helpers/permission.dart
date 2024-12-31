import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:usage_stats_new/usage_stats.dart';

class PermissionManager {
  Future<bool> requestPermissions() async {
    bool allGranted = true;

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

      // Verificar nuevamente después de que el usuario regrese
      final recheckPermission = await UsageStats.checkUsagePermission();
      if (recheckPermission == null || !recheckPermission) {
        allGranted = false;
      }
    }

    // Verificar y solicitar desactivación de optimización de batería
    final isBatteryOptimizationDisabled =
    await DisableBatteryOptimization.isBatteryOptimizationDisabled;

if (isBatteryOptimizationDisabled != null && !isBatteryOptimizationDisabled) {
  // Redirigir al usuario a desactivar optimización de batería
  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();

  // Rechequear después de redirigir
  final recheckBatteryOptimization =
      await DisableBatteryOptimization.isBatteryOptimizationDisabled;

  if (recheckBatteryOptimization == null || !recheckBatteryOptimization) {
    allGranted = false;
  }
}

    return allGranted;
  }

  Future<bool> checkPermissions() async {
    final notificationPermission = await Permission.notification.status;
    final usageStatsPermission = await UsageStats.checkUsagePermission();
    final isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    return notificationPermission.isGranted &&
        (usageStatsPermission ?? false) &&
        (isBatteryOptimizationDisabled ?? false);
  }
}
