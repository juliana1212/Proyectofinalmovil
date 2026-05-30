import 'package:shared_preferences/shared_preferences.dart';

class ServicioPreferencias {
  static const String _claveUltimaSincronizacion =
      'ultima_sincronizacion';

  Future<void> guardarUltimaSincronizacion(DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _claveUltimaSincronizacion,
      fecha.toIso8601String(),
    );
  }

  Future<DateTime?> obtenerUltimaSincronizacion() async {
    final prefs = await SharedPreferences.getInstance();

    final fechaTexto = prefs.getString(_claveUltimaSincronizacion);

    if (fechaTexto == null || fechaTexto.isEmpty) {
      return null;
    }

    return DateTime.tryParse(fechaTexto);
  }
}