-- AlterTable: Agregar fechaCaducidad a productos
ALTER TABLE `productos` ADD COLUMN `fechaCaducidad` DATETIME(3) NULL;

-- CreateTable: Crear tabla materiales
CREATE TABLE IF NOT EXISTS `materiales` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(191) NOT NULL,
    `descripcion` TEXT NULL,
    `costo` DECIMAL(10, 2) NULL,
    `stock` INTEGER NOT NULL DEFAULT 0,
    `stockMinimo` INTEGER NOT NULL DEFAULT 5,
    `fechaCaducidad` DATETIME(3) NULL,
    `categoria` VARCHAR(191) NULL,
    `activo` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable: Crear tabla usos_materiales
CREATE TABLE IF NOT EXISTS `usos_materiales` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `materialId` INTEGER NOT NULL,
    `pacienteId` INTEGER NOT NULL,
    `doctorId` INTEGER NOT NULL,
    `tratamientoId` INTEGER NULL,
    `cantidad` INTEGER NOT NULL DEFAULT 1,
    `observaciones` TEXT NULL,
    `usuarioId` INTEGER NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `usos_materiales` ADD CONSTRAINT `usos_materiales_materialId_fkey` FOREIGN KEY (`materialId`) REFERENCES `materiales`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `usos_materiales` ADD CONSTRAINT `usos_materiales_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `usos_materiales` ADD CONSTRAINT `usos_materiales_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `usos_materiales` ADD CONSTRAINT `usos_materiales_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;








