// lib/models/activo.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Activo {
  final String id;
  final String referencia;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String estado;
  final int cantidadTotal;
  final int cantidadDisponible;
  final int cantidadMantenimiento;
  final int cantidadBaja;
  final String syncStatus;
  final DateTime? fechaVencimiento;

  Activo({
    required this.id,
    required this.referencia,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.cantidadMantenimiento,
    required this.cantidadBaja,
    this.syncStatus = 'synced',
    this.fechaVencimiento,
  });

  factory Activo.fromMap(String id, Map<String, dynamic> data) {
    final String estadoActual =
        (data['estado'] ?? 'disponible').toString();

    return Activo(
      id: id,

      // Compatibilidad temporal:
      // si aún no existe referencia en Firebase, usa el id del documento.
      referencia: data['referencia'] ?? id,

      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? 'Sin categoría',
      estado: estadoActual,

      cantidadTotal: data['cantidadTotal'] ?? 1,
      cantidadDisponible: data['cantidadDisponible'] ?? 1,

      // Compatibilidad con activos antiguos que ya estaban
      // en mantenimiento o dados de baja.
      cantidadMantenimiento: data['cantidadMantenimiento'] ??
          (estadoActual == 'mantenimiento' ? 1 : 0),

      cantidadBaja: data['cantidadBaja'] ??
          (estadoActual == 'dadoDeBaja' ? 1 : 0),

      syncStatus: data['syncStatus'] ?? 'synced',
      fechaVencimiento: _convertirFecha(data['fechaVencimiento']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referencia': referencia,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'cantidadTotal': cantidadTotal,
      'cantidadDisponible': cantidadDisponible,
      'cantidadMantenimiento': cantidadMantenimiento,
      'cantidadBaja': cantidadBaja,
      'syncStatus': syncStatus,
      if (fechaVencimiento != null)
        'fechaVencimiento': Timestamp.fromDate(fechaVencimiento!),
    };
  }

  int get cantidadPrestada {
    final cantidad = cantidadTotal -
        cantidadDisponible -
        cantidadMantenimiento -
        cantidadBaja;

    return cantidad < 0 ? 0 : cantidad;
  }

  static DateTime? _convertirFecha(dynamic fecha) {
    if (fecha == null) {
      return null;
    }

    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    return null;
  }
}