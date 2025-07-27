import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:io' show Platform;

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) {
  print(
    'Notificación de fondo tocada. Payload: ${notificationResponse.payload}',
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void inicializarNotificaciones({bool fromBackground = false}) {
  tzdata.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
          print(
            'Notificación en primer plano tocada. Payload: ${notificationResponse.payload}',
          );
        },
    onDidReceiveBackgroundNotificationResponse:
        onBackgroundNotificationResponse,
  );

  if (!fromBackground) {
    _requestNotificationPermission();
  }
}

Future<void> _requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? grantedNotificationPermission = await androidImplementation
          .requestNotificationsPermission();
      final bool? grantedExactAlarmPermission = await androidImplementation
          .requestExactAlarmsPermission();

      if (grantedNotificationPermission == true) {
        print(' Permiso de notificaciones concedido para Android.');
      } else {
        print(' Permiso de notificaciones denegado para Android.');
      }
      if (grantedExactAlarmPermission == true) {
        print(' Permiso de alarmas exactas concedido para Android.');
      } else {
        print(' Permiso de alarmas exactas denegado para Android.');
      }
    }
  }
}

Future<void> mostrarNotificacion(int id, String titulo, String cuerpo) async {
  await flutterLocalNotificationsPlugin.show(
    id,
    titulo,
    cuerpo,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_medicamentos',
        'Medicamentos',
        channelDescription: 'Recordatorios de medicamentos',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: '{"id": $id, "titulo": "$titulo", "cuerpo": "$cuerpo"}',
  );
}

// --- FUNCIÓN programarNotificacion PERSISTENTE Y CON SONIDO ---
Future<void> programarNotificacion(
  int id,
  String titulo,
  String cuerpo,
  DateTime fechaHora,
) async {
  final androidNotificationDetails = const AndroidNotificationDetails(
    'canal_medicamentos_alarma_simple',
    'Alerta de Medicamento',
    channelDescription: 'Alerta persistente para tomar tu medicamento',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true,
    fullScreenIntent: false,

    sound: RawResourceAndroidNotificationSound('alarma'),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    titulo,
    cuerpo,
    tz.TZDateTime.from(fechaHora, tz.local),
    NotificationDetails(android: androidNotificationDetails),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: '{"id": $id, "titulo": "$titulo", "cuerpo": "$cuerpo"}',
  );
}

Future<void> cancelarNotificacionesDeHorario(
  int horarioId,
  int cantidadTomas,
) async {
  for (int i = 0; i < cantidadTomas; i++) {
    await flutterLocalNotificationsPlugin.cancel(horarioId * 100 + i);
  }
}
