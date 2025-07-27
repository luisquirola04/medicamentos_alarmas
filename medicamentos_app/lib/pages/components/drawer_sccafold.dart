import 'package:flutter/material.dart';
import 'package:medicamentos_app/pages/agregar_horario_screen.dart';
import 'package:medicamentos_app/pages/home_page.dart';
import 'package:medicamentos_app/pages/medicamento_all.dart';
import 'package:medicamentos_app/pages/medicamento.dart';

class DrawerScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DrawerScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal[600],
        elevation: 4,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.teal[400]),
                accountName: const Text('Gestión de Medicamentos'),
                accountEmail: const Text(""),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.local_hospital,
                    color: Colors.teal[700],
                    size: 40,
                  ),
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.home_rounded,
                text: 'Inicio',
                destination: const HomePage(),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.medication_outlined,
                text: 'Creación de Medicamentos',
                destination: MedicamentoView(),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.schedule_rounded,
                text: 'Creación de Horarios',
                destination: AgregarHorarioScreen(),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.list_alt_outlined,
                text: 'Lista de Medicamentos',
                destination: MedicamentoListView(),
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal[700]),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
