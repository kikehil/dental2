-- ============================================
-- CREAR NUEVO SALDO INICIAL DE EFECTIVO
-- ============================================

-- Crear un nuevo registro de saldo inicial
-- Reemplaza los valores según necesites

INSERT INTO cortes_caja (
    fecha,
    hora,
    saldoInicial,
    saldoInicialEfectivo,
    saldoInicialTarjetaAzteca,
    saldoInicialTarjetaBbva,
    saldoInicialTarjetaMp,
    saldoInicialTransferencia,
    ventasEfectivo,
    ventasTarjeta,
    ventasTransferencia,
    ventasTarjetaAzteca,
    ventasTarjetaBbva,
    ventasTarjetaMp,
    ventasTransferenciaAzteca,
    ventasTransferenciaBbva,
    ventasTransferenciaMp,
    totalVentas,
    saldoFinal,
    saldoFinalEfectivo,
    saldoFinalTarjetaAzteca,
    saldoFinalTarjetaBbva,
    saldoFinalTarjetaMp,
    saldoFinalTransferencia,
    saldoFinalTransferenciaAzteca,
    saldoFinalTransferenciaBbva,
    saldoFinalTransferenciaMp,
    diferencia,
    observaciones,
    usuarioId,
    createdAt,
    updatedAt
) VALUES (
    CURDATE(),                    -- fecha: fecha actual
    NULL,                         -- hora: NULL para saldo inicial
    1000.00,                      -- saldoInicial: total inicial (efectivo + tarjetas + transferencias)
    1000.00,                      -- saldoInicialEfectivo: efectivo inicial
    0.00,                         -- saldoInicialTarjetaAzteca
    0.00,                         -- saldoInicialTarjetaBbva
    0.00,                         -- saldoInicialTarjetaMp
    0.00,                         -- saldoInicialTransferencia
    0.00,                         -- ventasEfectivo
    0.00,                         -- ventasTarjeta
    0.00,                         -- ventasTransferencia
    0.00,                         -- ventasTarjetaAzteca
    0.00,                         -- ventasTarjetaBbva
    0.00,                         -- ventasTarjetaMp
    0.00,                         -- ventasTransferenciaAzteca
    0.00,                         -- ventasTransferenciaBbva
    0.00,                         -- ventasTransferenciaMp
    0.00,                         -- totalVentas
    1000.00,                      -- saldoFinal: igual al inicial al inicio
    1000.00,                      -- saldoFinalEfectivo: igual al inicial
    0.00,                         -- saldoFinalTarjetaAzteca
    0.00,                         -- saldoFinalTarjetaBbva
    0.00,                         -- saldoFinalTarjetaMp
    0.00,                         -- saldoFinalTransferencia
    0.00,                         -- saldoFinalTransferenciaAzteca
    0.00,                         -- saldoFinalTransferenciaBbva
    0.00,                         -- saldoFinalTransferenciaMp
    0.00,                         -- diferencia
    'Saldo inicial creado manualmente', -- observaciones
    NULL,                         -- usuarioId: NULL o el ID del usuario
    NOW(),                        -- createdAt
    NOW()                         -- updatedAt
);

-- Verificar que se creó correctamente
SELECT * FROM cortes_caja WHERE id = LAST_INSERT_ID();

