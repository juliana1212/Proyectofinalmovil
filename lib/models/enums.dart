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

enum AssetStatus {
  disponible,
  prestado,
  vencido,
  devuelto,
  enMantenimiento,
  dadoDeBaja,
}

enum LoanStatus {
  pendiente,
  activo,
  vencido,
  devuelto,
  cancelado,
}

enum SyncStatus {
  synced,
  pendingSync,
  failedSync,
}