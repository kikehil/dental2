-- ============================================
-- ACTUALIZAR SALDO INICIAL DE EFECTIVO
-- ============================================

-- IMPORTANTE: Reemplaza los valores según necesites
-- Ejemplo: Actualizar el saldo inicial más reciente

-- 1. Ver el registro actual antes de modificar
SELECT 
    id,
    fecha,
    saldoInicial,
    saldoInicialEfectivo,
    saldoInicialTarjetaAzteca,
    saldoInicialTarjetaBbva,
    saldoInicialTarjetaMp,
    saldoInicialTransferencia
FROM cortes_caja
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC
LIMIT 1;

-- 2. Actualizar el saldo inicial de efectivo del registro más reciente
-- Reemplaza 1000.00 con el valor que necesites
UPDATE cortes_caja
SET 
    saldoInicialEfectivo = 1000.00,
    saldoInicial = saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia + 1000.00,
    saldoFinalEfectivo = saldoFinalEfectivo - saldoInicialEfectivo + 1000.00,
    saldoFinal = saldoFinalTarjetaAzteca + saldoFinalTarjetaBbva + saldoFinalTarjetaMp + saldoFinalTransferencia + saldoFinalTransferenciaAzteca + saldoFinalTransferenciaBbva + saldoFinalTransferenciaMp + (saldoFinalEfectivo - saldoInicialEfectivo + 1000.00),
    updatedAt = NOW()
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC
LIMIT 1;

-- 3. Actualizar saldo inicial por ID específico (más seguro)
-- Reemplaza 123 con el ID del registro que quieres modificar
-- Reemplaza 1000.00 con el nuevo valor de efectivo
UPDATE cortes_caja
SET 
    saldoInicialEfectivo = 1000.00,
    saldoInicial = saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia + 1000.00,
    saldoFinalEfectivo = saldoFinalEfectivo - saldoInicialEfectivo + 1000.00,
    saldoFinal = saldoFinalTarjetaAzteca + saldoFinalTarjetaBbva + saldoFinalTarjetaMp + saldoFinalTransferencia + saldoFinalTransferenciaAzteca + saldoFinalTransferenciaBbva + saldoFinalTransferenciaMp + (saldoFinalEfectivo - saldoInicialEfectivo + 1000.00),
    updatedAt = NOW()
WHERE id = 123;

-- 4. Actualizar todos los saldos iniciales del día actual
UPDATE cortes_caja
SET 
    saldoInicialEfectivo = 1000.00,
    saldoInicial = saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia + 1000.00,
    updatedAt = NOW()
WHERE hora IS NULL 
  AND DATE(fecha) = CURDATE();

-- 5. Verificar el cambio después de actualizar
SELECT 
    id,
    fecha,
    saldoInicial,
    saldoInicialEfectivo,
    saldoFinal,
    saldoFinalEfectivo,
    updatedAt
FROM cortes_caja
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC
LIMIT 1;

