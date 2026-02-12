-- ============================================
-- CONSULTAR SALDO INICIAL DE EFECTIVO
-- ============================================

-- Ver el saldo inicial más reciente (donde hora es NULL)
SELECT 
    id,
    fecha,
    hora,
    saldoInicial AS 'Saldo Inicial Total',
    saldoInicialEfectivo AS 'Saldo Inicial Efectivo',
    saldoInicialTarjetaAzteca AS 'Saldo Inicial Tarjeta Azteca',
    saldoInicialTarjetaBbva AS 'Saldo Inicial Tarjeta BBVA',
    saldoInicialTarjetaMp AS 'Saldo Inicial Tarjeta MP',
    saldoInicialTransferencia AS 'Saldo Inicial Transferencia',
    createdAt AS 'Fecha de Creación',
    updatedAt AS 'Última Actualización'
FROM cortes_caja
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC
LIMIT 1;

-- Ver todos los saldos iniciales registrados
SELECT 
    id,
    DATE(fecha) AS 'Fecha',
    saldoInicial AS 'Saldo Total',
    saldoInicialEfectivo AS 'Efectivo',
    saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp AS 'Tarjeta Total',
    saldoInicialTransferencia AS 'Transferencia',
    createdAt AS 'Creado',
    updatedAt AS 'Actualizado'
FROM cortes_caja
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC;

-- Ver el saldo inicial del día actual
SELECT 
    id,
    fecha,
    saldoInicial AS 'Saldo Total',
    saldoInicialEfectivo AS 'Efectivo',
    saldoInicialTarjetaAzteca AS 'Tarjeta Azteca',
    saldoInicialTarjetaBbva AS 'Tarjeta BBVA',
    saldoInicialTarjetaMp AS 'Tarjeta MP',
    saldoInicialTransferencia AS 'Transferencia'
FROM cortes_caja
WHERE hora IS NULL 
  AND DATE(fecha) = CURDATE()
ORDER BY createdAt DESC
LIMIT 1;

