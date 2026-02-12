-- CreateTable
CREATE TABLE `tratamientos_plazo` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `pacienteId` INTEGER NOT NULL,
    `doctorId` INTEGER NOT NULL,
    `servicioId` INTEGER NOT NULL,
    `montoTotal` DECIMAL(10, 2) NOT NULL,
    `montoPagado` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `montoAdeudado` DECIMAL(10, 2) NOT NULL,
    `estado` VARCHAR(191) NOT NULL DEFAULT 'pendiente',
    `notas` TEXT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`),
    INDEX `tratamientos_plazo_pacienteId_idx`(`pacienteId`),
    INDEX `tratamientos_plazo_doctorId_idx`(`doctorId`),
    INDEX `tratamientos_plazo_servicioId_idx`(`servicioId`),
    CONSTRAINT `tratamientos_plazo_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `tratamientos_plazo_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `tratamientos_plazo_servicioId_fkey` FOREIGN KEY (`servicioId`) REFERENCES `servicios`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `abonos_tratamiento` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `tratamientoPlazoId` INTEGER NOT NULL,
    `monto` DECIMAL(10, 2) NOT NULL,
    `saldoAnterior` DECIMAL(10, 2) NOT NULL,
    `saldoNuevo` DECIMAL(10, 2) NOT NULL,
    `ventaId` INTEGER NULL,
    `notas` TEXT NULL,
    `usuarioId` INTEGER NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`),
    INDEX `abonos_tratamiento_tratamientoPlazoId_idx`(`tratamientoPlazoId`),
    INDEX `abonos_tratamiento_ventaId_idx`(`ventaId`),
    INDEX `abonos_tratamiento_usuarioId_idx`(`usuarioId`),
    CONSTRAINT `abonos_tratamiento_tratamientoPlazoId_fkey` FOREIGN KEY (`tratamientoPlazoId`) REFERENCES `tratamientos_plazo`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `abonos_tratamiento_ventaId_fkey` FOREIGN KEY (`ventaId`) REFERENCES `ventas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `abonos_tratamiento_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;



