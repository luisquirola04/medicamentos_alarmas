import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:medicamentos_app/models/medicamento.dart';
import 'package:medicamentos_app/models/horario.dart';
import 'package:medicamentos_app/controller/notificaciones_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

const String tareaNotificacion = "tarea_medicamento";

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print(
    'Notificación de fondo tocada. Payload: ${notificationResponse.payload}',
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    inicializarNotificaciones(fromBackground: true);

    await flutterLocalNotificationsPlugin.show(
      0,
      'DEBUG: Workmanager Activo',
      'Tarea "${task}" ejecutada a las ${DateTime.now().toLocal()}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_workmanager_channel',
          'Workmanager Debug',
          channelDescription: 'Canal para depurar la ejecución de Workmanager',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
    print('DEBUG: Workmanager: Tarea "$task" iniciada en callbackDispatcher.');

    if (task == tareaNotificacion && inputData != null) {
      try {
        final medicamento = Medicamento.fromMap(jsonDecode(inputData['med']));
        final horario = Horario.fromMap(jsonDecode(inputData['horario']));
        final iteracion = inputData['iteracion'] as int;

        DateTime fechaNotificacion = horario.hora.add(
          Duration(hours: (horario.intervalo * iteracion).toInt()),
        );

        final now = tz.TZDateTime.now(tz.local);

        if (fechaNotificacion.isBefore(now)) {
          print(
            'DEBUG: La fecha calculada está en el pasado. Ajustando para el futuro inmediato.',
          );
          fechaNotificacion = now.add(const Duration(seconds: 5));
        }

        print('DEBUG: Programando Notificación...');
        print('DEBUG: Medicamento: ${medicamento.nombre}');
        print('DEBUG: Horario ID: ${horario.id}');
        print('DEBUG: Iteración: $iteracion');
        print(
          'DEBUG: Fecha de la primera toma (_hora): ${horario.hora.toLocal()}',
        );
        print('DEBUG: Intervalo: ${horario.intervalo} horas');
        print(
          'DEBUG: Fecha y Hora de la notificación calculada (ajustada): ${fechaNotificacion.toLocal()}',
        );
        print(
          'DEBUG: ID de notificación final: ${medicamento.id! * 100 + iteracion}',
        );

        await programarNotificacion(
          medicamento.id! * 100 + iteracion,
          '¡Es hora de tu medicamento!',
          'Toma ${medicamento.nombre} - Dosis: ${medicamento.dosis}',
          fechaNotificacion,
        );
        print('DEBUG: Notificación programada correctamente por Workmanager.');
      } catch (e) {
        print('ERROR en tareaNotificacion (Workmanager): $e');
        await flutterLocalNotificationsPlugin.show(
          999,
          'Error en Workmanager',
          'No se pudo programar el medicamento. Revisar logs. Error: $e',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'error_workmanager_channel',
              'Errores del Sistema',
              channelDescription:
                  'Canal para notificar errores en segundo plano',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    } else {
      print(
        'DEBUG: Workmanager: Tarea no reconocida o inputData nulo para task: $task',
      );
    }

    return Future.value(true);
  });
}
