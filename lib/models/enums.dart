enum AssetStatus {
  disponible,
  prestado,
  vencido,
  devuelto,
  mantenimiento,
  dadoDeBaja,
}

enum LoanStatus {
  activo,
  vencido,
  devuelto,
}

enum SyncStatus {
  synced,
  pending,
  failed,
}

enum UserRole {
  solicitante,
  encargadoInventario,
  administrador,
}

enum AccountStatus {
  pendingApproval,
  active,
  blocked,
}