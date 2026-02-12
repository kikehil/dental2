# Guía para Manejar Saldo Inicial de Efectivo en MySQL

## Información General

El saldo inicial de efectivo se almacena en la tabla `cortes_caja`. Un registro de saldo inicial se identifica porque el campo `hora` es `NULL`.

## Estructura de la Tabla

**Tabla:** `cortes_caja`

**Campos importantes para saldo inicial:**
- `id`: ID único del registro
- `fecha`: Fecha del saldo inicial
- `hora`: `NULL` para saldo inicial (no NULL para cortes de caja)
- `saldoInicial`: Saldo inicial total (suma de todos los métodos de pago)
- `saldoInicialEfectivo`: Saldo inicial en efectivo
- `saldoInicialTarjetaAzteca`: Saldo inicial en tarjeta Azteca
- `saldoInicialTarjetaBbva`: Saldo inicial en tarjeta BBVA
- `saldoInicialTarjetaMp`: Saldo inicial en tarjeta Mercado Pago
- `saldoInicialTransferencia`: Saldo inicial en transferencias

## Comandos SQL

### 1. Consultar Saldo Inicial Actual

```sql
-- Ver el saldo inicial más reciente
SELECT 
    id,
    fecha,
    saldoInicial AS 'Saldo Total',
    saldoInicialEfectivo AS 'Efectivo',
    saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp AS 'Tarjeta Total',
    saldoInicialTransferencia AS 'Transferencia',
    createdAt AS 'Creado'
FROM cortes_caja
WHERE hora IS NULL
ORDER BY fecha DESC, createdAt DESC
LIMIT 1;
```

### 2. Actualizar Saldo Inicial de Efectivo

```sql
-- Actualizar por ID (más seguro)
UPDATE cortes_caja
SET 
    saldoInicialEfectivo = 1000.00,  -- Nuevo valor de efectivo
    saldoInicial = saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia + 1000.00,
    updatedAt = NOW()
WHERE id = 123;  -- Reemplaza con el ID del registro
```

### 3. Crear Nuevo Saldo Inicial

```sql
INSERT INTO cortes_caja (
    fecha, hora, saldoInicial, saldoInicialEfectivo,
    saldoInicialTarjetaAzteca, saldoInicialTarjetaBbva, saldoInicialTarjetaMp,
    saldoInicialTransferencia,
    ventasEfectivo, ventasTarjeta, ventasTransferencia,
    totalVentas,
    saldoFinal, saldoFinalEfectivo,
    diferencia,
    createdAt, updatedAt
) VALUES (
    CURDATE(), NULL, 1000.00, 1000.00,
    0.00, 0.00, 0.00,
    0.00,
    0.00, 0.00, 0.00,
    0.00,
    1000.00, 1000.00,
    0.00,
    NOW(), NOW()
);
```

## Archivos Disponibles

1. **consultar-saldo-inicial.sql**: Scripts para consultar el saldo inicial
2. **actualizar-saldo-inicial.sql**: Scripts para actualizar el saldo inicial
3. **crear-saldo-inicial.sql**: Script para crear un nuevo saldo inicial

## Precauciones

⚠️ **IMPORTANTE:**
- Siempre haz un backup antes de modificar datos directamente en la base de datos
- Verifica el registro antes de actualizarlo
- Asegúrate de actualizar también `saldoInicial` (total) cuando cambies `saldoInicialEfectivo`
- Si hay cortes de caja después del saldo inicial, también deberías actualizar los saldos finales

## Ejemplo de Uso Completo

```sql
-- 1. Ver el registro actual
SELECT id, fecha, saldoInicialEfectivo 
FROM cortes_caja 
WHERE hora IS NULL 
ORDER BY fecha DESC 
LIMIT 1;

-- 2. Actualizar (reemplaza ID y valor)
UPDATE cortes_caja
SET 
    saldoInicialEfectivo = 1500.00,
    saldoInicial = saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia + 1500.00,
    updatedAt = NOW()
WHERE id = 123;

-- 3. Verificar el cambio
SELECT id, fecha, saldoInicialEfectivo, saldoInicial 
FROM cortes_caja 
WHERE id = 123;
```

