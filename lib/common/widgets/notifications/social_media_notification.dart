import 'package:usage_stats_new/usage_stats.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';

class BackgroundMonitor {
  static const Map<String, String> socialApps = {
    'com.facebook.katana': 'Facebook',
    'com.facebook.lite': 'Facebook Lite',
    'com.instagram.android': 'Instagram',
    'com.instagram.lite': 'Instagram Lite',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.zhiliaoapp.musically.go': 'TikTok Lite'
  };

  static final FlutterLocalNotificationsPlugin _notifications = 
    FlutterLocalNotificationsPlugin();
    
  // Mapa para rastrear apps activas y sus tiempos de inicio
  static final Map<String, DateTime> _activeApps = {};

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    
    await _initNotifications();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
        foregroundServiceTypes: [
          AndroidForegroundType.dataSync,
        ],
        initialNotificationTitle: 'Monitoreo activo',
        initialNotificationContent: 'El monitoreo de uso está funcionando en segundo plano.',
        notificationChannelId: 'background_monitor',
        foregroundServiceNotificationId: 112233,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
     await service.startService();
  }


  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {

     if (service is AndroidServiceInstance) {
      await service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: 'Monitoreo activo',
        content: 'El monitoreo está funcionando en segundo plano.',
      );
      //print('se ejecuta en servicio: ');
    }
    final hasPermission = await UsageStats.checkUsagePermission();
    if (hasPermission == null || !hasPermission) {
      return;
    }

    
Timer.periodic(const Duration(seconds: 10), (timer) async {
    final now = DateTime.now();
    final events = await UsageStats.queryEvents(
      now.subtract(const Duration(seconds: 10)),
      now,
    );

    for (var event in events) {
      //print('Evento: ${event.packageName}, Tipo: ${event.eventType}');
      if (!socialApps.containsKey(event.packageName)) continue;
      final appName = socialApps[event.packageName]!;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(event.timeStamp!) ?? 0,
      );

      // MOVE_TO_FOREGROUND (1) - App abierta
      if (event.eventType == '1') {
        // Ignorar si ya está activa
        if (_activeApps.containsKey(appName)) {
          //print('Evento duplicado de apertura ignorado: $appName');
          continue;
        }
        //print('App iniciada: $appName a las $timestamp');
        _activeApps[appName] = timestamp;
      }

      // MOVE_TO_BACKGROUND (23) - App enviada al fondo o cerrada
      else if (event.eventType == '23') {
        // Ignorar si no estaba activa
        if (!_activeApps.containsKey(appName)) {
          //print('Evento duplicado de cierre ignorado: $appName');
          continue;
        }

        final startTime = _activeApps[appName]!;
        final usageTime = timestamp.difference(startTime);

        // Ignorar cierres que ocurren inmediatamente después de abrir
        if (usageTime.inSeconds < 5) {
          //print('Cierre ignorado debido a tiempo muy corto: $appName');
          continue;
        }

        // Eliminar la app del tracking
        _activeApps.remove(appName);
      }
    }

    // Verificar apps activas por tiempo excesivo
    _activeApps.forEach((appName, startTime) {
      final usageTime = now.difference(startTime);
      //print('Notificación de 10 minutos activada para $appName. Tiempo: ${usageTime.inMinutes} minutos');
      if (usageTime.inMinutes == 125) {
        _showNotification(
          'Alerta de uso',
          'Has usado $appName por más de 2 horas. ¿Qué tal tomar un descanso?',
        );
      }
      if (usageTime.inMinutes == 185) {
        _showNotification(
          'Uso excesivo',
          'Has usado $appName por más de 3 horas. El uso prolongado puede afectar tu bienestar. ¡Toma un descanso!.',
        );
      }
      if (usageTime.inMinutes >= 60 && usageTime.inMinutes % 60 == 0) {
        _showNotification(
          'Alerta de uso continuo',
          'Has estado usando $appName por  ${usageTime.inMinutes}. Recuerda hacer una pausa',
        );
      }
    });
  });
  }

  static Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);

  await _notifications.initialize(settings);

  const androidChannel = AndroidNotificationChannel(
    'background_monitor', // ID del canal
    'Background Monitor',
    description: 'Notificaciones del servicio en segundo plano',
    importance: Importance.max,
  );

  final notifications = FlutterLocalNotificationsPlugin();
  await notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}


  static Future<void> _showNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'background_monitor', // Cambia a 'background_monitor'
    'Background Monitor',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
  );

  await _notifications.show(
    0,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}

}