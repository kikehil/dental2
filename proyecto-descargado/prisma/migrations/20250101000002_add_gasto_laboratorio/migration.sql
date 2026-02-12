-- AlterTable
ALTER TABLE `gastos` ADD COLUMN `tipo` VARCHAR(191) NOT NULL DEFAULT 'general',
ADD COLUMN `laboratorioId` INTEGER NULL,
ADD COLUMN `pacienteId` INTEGER NULL;

-- AddForeignKey
ALTER TABLE `gastos` ADD CONSTRAINT `gastos_laboratorioId_fkey` FOREIGN KEY (`laboratorioId`) REFERENCES `laboratorios`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `gastos` ADD CONSTRAINT `gastos_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;



