import 'package:flutter/material.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/common/widgets/button/button_app_small.dart';
import 'package:tesis_v2/presentation/home/pages/addiction.dart';
import 'package:usage_stats_new/usage_stats.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Tiktok extends StatefulWidget {
  const Tiktok({super.key});

  @override
  State<Tiktok> createState() => _TiktokState();
}

class _TiktokState extends State<Tiktok> {
  String _averageDailyUsage = "Cargando...";
  String _averageDailyAccesses = "Cargando...";
  String _averageDailyFrecuency = "Cargando...";
  bool _isTiktokInstalled = true;

  @override
  void initState() {
    super.initState();
    _fetchTiktokUsage();
  }

  Future<void> _fetchTiktokUsage() async {
    try {
      bool isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;
      if (!isPermissionGranted) {
        await UsageStats.grantUsagePermission();
        isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;

        if (!isPermissionGranted) {
          setState(() {
            _averageDailyUsage = "Permiso denegado.";
            _isTiktokInstalled = false;
          });
          return;
        }
      }
  
    if (isPermissionGranted == true) {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 7));

      List<UsageInfo> usageInfoList = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

    var tiktokUsage = usageInfoList.where((info) => 
      info.packageName!.contains('com.zhiliaoapp.musically') || 
      info.packageName!.contains('com.ss.android.ugc.trill')
    ).toList();

    List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
    Map<String, int> opensPerDay = {};
    
    // Filtrar eventos de Facebook
    const int sessionThresholdMillis = 5 * 60 * 1000; // 5 minutos entre sesiones
    DateTime? lastEventTime;

    Map<String, int> frequency = {
        "Mañana": 0, // 6:00 AM - 12:00 PM
        "Tarde": 0,  // 12:00 PM - 6:00 PM
        "Noche": 0,  // 6:00 PM - 12:00 AM
        "Madrugada": 0, // 12:00 AM - 6:00 AM
      };

    for (var event in events) {
      if (event.packageName != null &&
          (event.packageName!.contains('com.zhiliaoapp.musically') ||
          event.packageName!.contains('com.zhiliaoapp.musically.go')) &&
          event.timeStamp != null &&
          event.eventType == '1') {

        DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(event.timeStamp!)
        );

        if (lastEventTime == null || 
            eventTime.difference(lastEventTime).inMilliseconds > sessionThresholdMillis) {
          String day = "${eventTime.year}-${eventTime.month.toString().padLeft(2, '0')}-${eventTime.day.toString().padLeft(2, '0')}";
          opensPerDay[day] = (opensPerDay[day] ?? 0) + 1;
          lastEventTime = eventTime;
        }

        int hour = eventTime.hour;
        if (hour >= 6 && hour < 12) {
          frequency["Mañana"] = frequency["Mañana"]! + 1;
        } else if (hour >= 12 && hour < 18) {
          frequency["Tarde"] = frequency["Tarde"]! + 1;
        } else if (hour >= 18 && hour < 24) {
          frequency["Noche"] = frequency["Noche"]! + 1;
        } else {
          frequency["Madrugada"] = frequency["Madrugada"]! + 1;
        }
      }
    }

    String mostFrequentTime = frequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    int totalAperturas = opensPerDay.values.fold(0, (sum, count) => sum + count);
    int totalUsageTime = tiktokUsage.fold(0, (sum, info) => 
      sum + int.parse(info.totalTimeInForeground ?? '0')
    );
      // Calcular promedios
      int averageMinutes = (totalUsageTime ~/ (1000 * 60)) ~/ 7; // Promedio semanal
      int totalOpens = totalAperturas ~/ opensPerDay.length;

      setState(() {
        _averageDailyFrecuency = mostFrequentTime;
        _averageDailyUsage = averageMinutes.toString();
        _averageDailyAccesses = totalOpens.toString();
      });
    }} catch (e) {
      setState(() {
        _isTiktokInstalled = false;
        _averageDailyUsage = "Error al obtener datos.";
        _averageDailyAccesses = "0 veces/día";
        _averageDailyFrecuency = "No hay";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono
              Icon(FontAwesomeIcons.tiktok, color: context.isDarkMode? Colors.white : Colors.black, size: 64),
              SizedBox(height: 16),

              // Título
              Text(
                "Tiktok",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Contenido
              _isTiktokInstalled
                  ? Column(
                      children: [
                        Text(
                          "Promedio diario de uso: $_averageDailyUsage min/dia",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Accesos promedio al día: $_averageDailyAccesses veces/dia",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Mayor frecuencia: $_averageDailyFrecuency",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 25),
                        AppButtonSmall(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddictionPage(
                                  appName: 'Tiktok',
                                  averageDailyUsage: _averageDailyUsage,
                                  averageDailyAccesses: _averageDailyAccesses,
                                  averageDailyFrecuency: _averageDailyFrecuency,
                                ),
                              ),
                            );
                          },
                          title: 'Diagnóstico de Adicción',
                        ),
                      ],
                    )
                  : Text(
                      "Tiktok no está instalado o no hay datos disponibles.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

