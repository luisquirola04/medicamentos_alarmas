import 'package:flutter/material.dart';

import 'package:medicamentos_app/pages/home_page.dart';

import 'package:workmanager/workmanager.dart';

import 'package:medicamentos_app/controller/notificaciones_helper.dart';

import 'package:medicamentos_app/controller/notificaciones_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar TimeZone y Notificaciones

  inicializarNotificaciones();

  // Inicializar WorkManager

  await Workmanager().initialize(
    callbackDispatcher, // función del archivo notificaciones_worker.dart

    isInDebugMode: true,
  );

  runApp(const MedicamentosApp());
}

class MedicamentosApp extends StatelessWidget {
  const MedicamentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Medicamentos App",

      theme: ThemeData(primarySwatch: Colors.blue),

      home: HomePage(),
    );
  }
}
