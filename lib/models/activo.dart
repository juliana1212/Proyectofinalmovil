// lib/models/activo.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Activo {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String estado;
  final int cantidadTotal;
  final int cantidadDisponible;
  final String syncStatus;
  final DateTime? fechaVencimiento;

  Activo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    this.syncStatus = 'synced',
    this.fechaVencimiento,
  });

  factory Activo.fromMap(String id, Map<String, dynamic> data) {
    return Activo(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? 'Sin categoría',
      estado: data['estado'] ?? 'disponible',

      // Compatibilidad temporal con documentos antiguos de Firebase.
      // Después actualizaremos todos los activos en Firestore.
      cantidadTotal: data['cantidadTotal'] ?? 1,
      cantidadDisponible: data['cantidadDisponible'] ?? 1,

      syncStatus: data['syncStatus'] ?? 'synced',
      fechaVencimiento: _convertirFecha(data['fechaVencimiento']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'cantidadTotal': cantidadTotal,
      'cantidadDisponible': cantidadDisponible,
      'syncStatus': syncStatus,
      if (fechaVencimiento != null)
        'fechaVencimiento': Timestamp.fromDate(fechaVencimiento!),
    };
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