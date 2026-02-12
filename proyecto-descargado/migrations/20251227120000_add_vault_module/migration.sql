-- Crear tabla para movimientos de vault (ingresos USD, traslados y retiros)
CREATE TABLE IF NOT EXISTS `vault_movimientos` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(191) NOT NULL,
  `metodo` VARCHAR(191) NOT NULL,
  `banco` VARCHAR(191) NULL,
  `monto` DECIMAL(12, 2) NOT NULL,
  `nota` TEXT NULL,
  `usuarioId` INTEGER NULL,
  `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  INDEX `vault_movimientos_usuarioId_idx` (`usuarioId`),
  CONSTRAINT `vault_movimientos_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Asegurar campos necesarios en ventas para moneda y banco (solo se agregan si faltan)
ALTER TABLE `ventas`
  ADD COLUMN IF NOT EXISTS `doctorId` INTEGER NULL AFTER `pacienteId`,
  ADD COLUMN IF NOT EXISTS `banco` VARCHAR(191) NULL AFTER `metodoPago`,
  ADD COLUMN IF NOT EXISTS `moneda` VARCHAR(191) NOT NULL DEFAULT 'MXN' AFTER `banco`;

-- Ajustes de saldos por banco en cortes de caja para tarjetas (si no existieran)
ALTER TABLE `cortes_caja`
  ADD COLUMN IF NOT EXISTS `saldoFinalTarjetaAzteca` DECIMAL(10, 2) NOT NULL DEFAULT 0 AFTER `saldoFinalTarjeta`,
  ADD COLUMN IF NOT EXISTS `saldoFinalTarjetaBbva` DECIMAL(10, 2) NOT NULL DEFAULT 0 AFTER `saldoFinalTarjetaAzteca`,
  ADD COLUMN IF NOT EXISTS `saldoFinalTarjetaMp` DECIMAL(10, 2) NOT NULL DEFAULT 0 AFTER `saldoFinalTarjetaBbva`;





