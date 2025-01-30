
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';

import '../pages/addiction.dart';
import 'package:flutter/material.dart';
import 'package:tesis_v2/common/widgets/button/button_app_small.dart';
import 'package:usage_stats_new/usage_stats.dart';


class Facebook extends StatefulWidget {
  const Facebook({super.key});

  @override
  State<Facebook> createState() => _FacebookState();
}

class _FacebookState extends State<Facebook> {
  String _averageDailyUsage = "Cargando...";
  String _averageDailyAccesses = "Cargando...";
  String _averageDailyFrecuency = "Cargando...";
  bool _isFacebookInstalled = true;
  // ignore: prefer_final_fields
  Map<String, Map<String, dynamic>> _dailyUsage = {};
  Map<String, Map<String, dynamic>> dailyRanges = {};
  Map<String, int> usageTimePerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchFacebookUsage();
  }

Future<void> _fetchFacebookUsage() async {
  try {
    bool isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;
    if (!isPermissionGranted) {
      await UsageStats.grantUsagePermission();
      isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;

      if (!isPermissionGranted) {
        setState(() {
          _averageDailyUsage = "Permiso denegado.";
          _isFacebookInstalled = false;
        });
        return;
      }
    }

    if (isPermissionGranted == true) {
      DateTime now = DateTime.now();
      //print('🕒 Fecha actual: ${now.toString()}');

      DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      // Inicio hace 4 días a las 00:00:00
      DateTime startDate = DateTime(
        now.year,
        now.month,
        now.day - 4,
        0,
        0,
        0,
      );

    

      List<UsageInfo> usageInfoList = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      var FacebookUsage = usageInfoList.where((info) =>
          info.packageName!.contains('com.facebook.katana') ||
          info.packageName!.contains('com.facebook.lite')).toList();

      //print('📱 Registros de uso encontrados: ${FacebookUsage.length}');

      DateTime? referenceTime;
      for (var usage in FacebookUsage) {
        if (usage.firstTimeStamp != null) {
          DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
            int.parse(usage.firstTimeStamp!),
          );
          if (referenceTime == null || timestamp.isBefore(referenceTime)) {
            referenceTime = timestamp;
          }
        }
      }
      referenceTime ??= DateTime.now();
      // Usar la hora del referenceTime para los rangos
    int referenceHour = referenceTime.hour;
    int referenceMinute = referenceTime.minute;
      Map<String, Map<String, dynamic>> dailyRanges = {};
      Map<String, int> usageTimePerDay = {};
      
      
      // Inicializar el mapa para los últimos 4 días con rangos horarios
      for (int i = 0; i < 4; i++) {
      DateTime rangeStart = DateTime(
        now.year, 
        now.month, 
        now.day - i - 1, 
        referenceHour, 
        referenceMinute
      );
      DateTime rangeEnd = DateTime(
        now.year, 
        now.month, 
        now.day - i, 
        referenceHour, 
        referenceMinute
      );
      
      String formattedDate = "${rangeStart.year}-${rangeStart.month.toString().padLeft(2, '0')}-${rangeStart.day.toString().padLeft(2, '0')}";
      String timeRange = "${referenceHour.toString().padLeft(2, '0')}:${referenceMinute.toString().padLeft(2, '0')} → ${rangeEnd.day.toString().padLeft(2, '0')}/${rangeEnd.month.toString().padLeft(2, '0')} ${referenceHour.toString().padLeft(2, '0')}:${referenceMinute.toString().padLeft(2, '0')}";
      
      dailyRanges[formattedDate] = {
        "start": rangeStart,
        "end": rangeEnd,
        "timeRange": timeRange
      };
      usageTimePerDay[formattedDate] = 0;
      //print('🗓️ Inicializando día: $formattedDate (${timeRange})');
    }

      // Procesar tiempo de uso
      for (var usage in FacebookUsage) {
        if (usage.totalTimeInForeground == null || 
            usage.firstTimeStamp == null || 
            usage.lastTimeStamp == null) {
          continue;
        }

        DateTime firstTimestamp = DateTime.fromMillisecondsSinceEpoch(
          int.parse(usage.firstTimeStamp!),
        );
        
        String formattedDate = "${firstTimestamp.year}-${firstTimestamp.month.toString().padLeft(2, '0')}-${firstTimestamp.day.toString().padLeft(2, '0')}";
        
        if (usageTimePerDay.containsKey(formattedDate)) {
          int totalTime = int.parse(usage.totalTimeInForeground!);
          int timeInMinutes = totalTime ~/ (1000 * 60);
          usageTimePerDay[formattedDate] = (usageTimePerDay[formattedDate] ?? 0) + timeInMinutes;
        }
      }

      // Procesar accesos
      Map<String, int> opensPerDay = {};
      Map<String, Map<String, dynamic>> frequency = {
        "Mañana": {"count": 0, "hours": "6:00 - 11:59"},
        "Tarde": {"count": 0, "hours": "12:00 - 17:59"},
        "Noche": {"count": 0, "hours": "18:00 - 23:59"},
        "Madrugada": {"count": 0, "hours": "0:00 - 5:59"},
      };

      // Inicializar opensPerDay con las mismas fechas
      dailyRanges.keys.forEach((date) {
        opensPerDay[date] = 0;
      });

      DateTime? lastEventTime;
      const int sessionThresholdMillis = 7 * 60 * 1000;

      List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);

      for (var event in events) {
        if (event.packageName != null &&
            (event.packageName!.contains('com.facebook.katana') ||
             event.packageName!.contains('com.facebook.lite')) &&
            event.timeStamp != null &&
            event.eventType == '1') {

          DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(event.timeStamp!),
          );

          // Encontrar el rango al que pertenece este evento
          String? relevantDate;
          for (var entry in dailyRanges.entries) {
            // Modificar la condición del rango para incluir los momentos exactos
            if ((eventTime.isAfter(entry.value["start"]) || eventTime.isAtSameMomentAs(entry.value["start"])) && 
                (eventTime.isBefore(entry.value["end"]) || eventTime.isAtSameMomentAs(entry.value["end"]))) {
              relevantDate = entry.key;
              break;
            }
          }

          if (relevantDate != null) {
            if (lastEventTime == null ||
                eventTime.difference(lastEventTime).inMilliseconds > sessionThresholdMillis) {
              opensPerDay[relevantDate] = (opensPerDay[relevantDate] ?? 0) + 1;

              int hour = eventTime.hour;
              String period;
              if (hour >= 6 && hour < 12) {
                period = "Mañana";
              } else if (hour >= 12 && hour < 18) {
                period = "Tarde";
              } else if (hour >= 18 && hour < 24) {
                period = "Noche";
              } else {
                period = "Madrugada";
              }
              
              frequency[period]!["count"] = (frequency[period]!["count"] ?? 0) + 1;
            }
            lastEventTime = eventTime;
          }
        }
      }
      

      // Calcular promedios y actualizar el estado
      var validDays = usageTimePerDay.values.where((time) => time > 0).toList();
      var validAccessDays = opensPerDay.values.where((count) => count > 0).toList();
      opensPerDay.forEach((date, count) {
      opensPerDay.forEach((date, count) {
      if (usageTimePerDay[date] != null && usageTimePerDay[date]! > 0) {
        // Asignar al menos 1 acceso si hay tiempo de uso y los accesos son 0
        if (count == 0) {
          opensPerDay[date] = 1;
          // print('⚠️ Ajustando accesos para $date: Accesos ahora 1');
        }
      } else {
        // Si el tiempo de uso es 0, asegurarse de que los accesos sean 0
        opensPerDay[date] = 0;
        // print('⚠️ Ajustando accesos para $date: Accesos ahora 0');
      }
});

    });

      
      int averageMinutes = validDays.isEmpty ? 0 : 
          validDays.reduce((a, b) => a + b) ~/ 4;
          
      int avgAccesses = validAccessDays.isEmpty ? 0 : 
          validAccessDays.reduce((sum, count) => sum + count) ~/ 4;

      var mostFrequentTime = frequency.entries
          .reduce((a, b) => (a.value["count"] ?? 0) > (b.value["count"] ?? 0) ? a : b)
          .key;

      //_dailyUsage.clear();
      usageTimePerDay.forEach((day, time) {
      if (!_dailyUsage.containsKey(day)) {
        _dailyUsage[day] = {
          "time": time,
          "accesses": opensPerDay[day] ?? 0,
          "timeRange": dailyRanges[day]?["timeRange"],
        };
      } else {
        _dailyUsage[day]?["time"] += time;
        _dailyUsage[day]?["accesses"] += opensPerDay[day] ?? 0;
      }
    });
      setState(() {
        _averageDailyUsage = averageMinutes.toString();
        _averageDailyAccesses = avgAccesses.toString();
        _averageDailyFrecuency = mostFrequentTime;
      });
    }
  } catch (e) {
    setState(() {
      _isFacebookInstalled = false;
      _averageDailyUsage = "Error al obtener datos.";
    });
  }
}

 @override
Widget build(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono y título
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, color: Colors.blue, size: 64),
              SizedBox(width: 8),
              Text(
                "Facebook",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backCard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          _isFacebookInstalled
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información principal
                    Text(
                      "Promedio diario de uso: $_averageDailyUsage min/día",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Accesos promedio al día: $_averageDailyAccesses veces/día",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mayor frecuencia: $_averageDailyFrecuency",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // Título del historial
                    const Text(
                      "Historial de uso:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.backCard,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _dailyUsage.keys.map((date) {
                        int usageTime = _dailyUsage[date]?['time'] ?? 0;
                        int accesses = _dailyUsage[date]?['accesses'] ?? 0;
                        String timeRange = _dailyUsage[date]?['timeRange'] ?? '';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: context.isDarkMode ? AppColors.backCard : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            title: Text(
                              date,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Rango: $timeRange\nTiempo de uso: $usageTime min\nAccesos: $accesses veces",
                              style: TextStyle(
                                fontSize: 14,
                                color: context.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            leading: const Icon(Icons.calendar_today, color: Colors.blue),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Botón de diagnóstico
                    Center(
                      child: AppButtonSmall(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddictionPage(
                                appName: 'Facebook',
                                averageDailyUsage: _averageDailyUsage,
                                averageDailyAccesses: _averageDailyAccesses,
                                averageDailyFrecuency: _averageDailyFrecuency,
                              ),
                            ),
                          );
                        },
                        title: 'Diagnóstico de Adicción',
                      ),
                    ),
                  ],
                )
              : const Text(
                  "Facebook no está instalado o no hay datos disponibles.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
        ],
      ),
    ),
  );
}
}