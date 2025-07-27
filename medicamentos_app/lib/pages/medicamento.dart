import 'package:flutter/material.dart';
import 'package:medicamentos_app/controller/medicamento_dao.dart';
import 'package:medicamentos_app/pages/components/drawer_sccafold.dart';
import 'package:medicamentos_app/models/medicamento.dart';
import 'package:medicamentos_app/pages/medicamento_all.dart';

class MedicamentoView extends StatefulWidget {
  const MedicamentoView({super.key});

  @override
  _MedicamentoViewState createState() => _MedicamentoViewState();
}

class _MedicamentoViewState extends State<MedicamentoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _dosisController = TextEditingController();

  final _dao = MedicamentoDao();

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    _dosisController.dispose();
    super.dispose();
  }

  void _guardarMedicamento() async {
    if (_formKey.currentState!.validate()) {
      final medicamento = Medicamento(
        nombre: _nombreController.text,
        // Usar un string vacío si la descripción está vacía, para evitar null
        descripcion: _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : '',
        cantidad: int.tryParse(_cantidadController.text) ?? 0,
        dosis: double.tryParse(_dosisController.text) ?? 0.0,
        estado: 0, // Siempre activo
      );

      await _dao.insert(medicamento);

      _showSnackBar(
        'Medicamento "${medicamento.nombre}" guardado con éxito!',
        const Color(0xFF4CAF50),
        Icons.check_circle_outline,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MedicamentoListView()),
      );
    } else {
      _showSnackBar(
        'Por favor, corrige los errores en el formulario.',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
    }
  }

  // Helper para mostrar SnackBar con estilo mejorado
  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // Widget para contenedores estilizados (ahora más ligero, solo padding y color de fondo)
  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ), // Padding más ajustado para TextFormFields
      margin: const EdgeInsets.only(bottom: 16), // Espacio entre campos
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Fondo blanco suave
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerScaffold(
      title: 'Agregar Medicamento',
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCCEFF0),
              Color(0xFFB2DFDB),
            ], // Degradado de fondo consistente
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding general
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Ingresa los detalles del nuevo medicamento.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4DB6AC),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Nombre del Medicamento
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Medicamento',
                      border: InputBorder
                          .none, // Eliminar el borde del TextFormField
                      icon: Icon(
                        Icons.medication_outlined,
                        color: Color(0xFF80CBC4),
                      ), // Icono a la izquierda del label
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'El nombre es requerido' : null,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Descripción
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.description_outlined,
                        color: Color(0xFF80CBC4),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Cantidad total
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Total (Ej: 30)',
                      border: InputBorder.none,
                      icon: Icon(Icons.numbers, color: Color(0xFF80CBC4)),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La cantidad es requerida';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Ingresa un número entero positivo';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                // Dosis por toma
                _buildFieldContainer(
                  child: TextFormField(
                    controller: _dosisController,
                    decoration: const InputDecoration(
                      labelText: 'Dosis por Toma (Ej: 1.5)',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.medical_information,
                        color: Color(0xFF80CBC4),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La dosis es requerida';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Ingresa un número válido (> 0)';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 30),

                // Botón de Guardar
                ElevatedButton.icon(
                  onPressed: _guardarMedicamento,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Medicamento',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF26A69A), // Color vibrante
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Bordes redondeados
                    ),
                    elevation: 5, // Sombra para realzar
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
