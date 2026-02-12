-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: clinica_dental
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `_prisma_migrations`
--

DROP TABLE IF EXISTS `_prisma_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_prisma_migrations` (
  `id` varchar(36) NOT NULL,
  `checksum` varchar(64) NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) NOT NULL,
  `logs` text DEFAULT NULL,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `applied_steps_count` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_prisma_migrations`
--

LOCK TABLES `_prisma_migrations` WRITE;
/*!40000 ALTER TABLE `_prisma_migrations` DISABLE KEYS */;
INSERT INTO `_prisma_migrations` VALUES ('02f74a6f-ebe9-4949-af5b-cdb664594322','9383081a21f7ccd64f20f92d5741d80bfd33419ea9d66522d4df24501492a7ed','2025-12-06 18:29:34.014','20251203050910_add_cortes_caja',NULL,NULL,'2025-12-06 18:29:33.862',1),('16827e0d-9eb5-4da8-be21-88224a6560a3','e09d4ee7f6b50d46992f03aed253c1d3ecf5362c466c6a2e34d4747d80f97562','2025-12-06 18:29:33.859','20251203045806_init',NULL,NULL,'2025-12-06 18:29:32.715',1),('19a8255a-50a3-464f-be6e-37df75d5ddef','907b5a67c604b53f9f3c2283215706dfee921d38d9214dd2f44d30ad734fb120','2025-12-29 06:19:20.925','20251227120000_add_vault_module','',NULL,'2025-12-29 06:19:20.925',0),('1fa59faa-3d83-4072-b673-7a4f6aed3ede','605e380cae4cb325f062fcd2f0b7f5522c0785524c12f9a5f2609159cc766969','2025-12-29 06:18:04.412','20251216000000_add_categorias','',NULL,'2025-12-29 06:18:04.412',0),('286fe7b3-c919-41b6-9e23-f79c1d38c748','1b741139f72796fdc8aa80863c1baff78c228705e1ae1982e33d4e28c2d44c05','2025-12-12 23:05:52.507','20251210212000_add_transferencia_banco_saldos',NULL,NULL,'2025-12-12 23:05:52.462',1),('44aa7df4-5086-4840-ba4c-fc2253d35f1f','d6c1eaf8baac0dc3c2c4b064e336ab700c9f46590f54954c1283cf15c7bbc684','2025-12-30 04:14:25.880','20250101000003_add_configuracion_retiros',NULL,NULL,'2025-12-30 04:14:25.727',1),('51620730-56fa-4797-8867-45f88baf7996','7facca0a30b6786ea8b37ff9e284afc8ca1e6c504cd328be71e9665e7b5eb865','2025-12-06 18:29:34.330','20251205193000_add_new_fields',NULL,NULL,'2025-12-06 18:29:34.128',1),('51c175b0-83a8-49e3-beae-a45bde0ab5a9','2f7876fbc6f1fd0275782ae8013068ff0eb4dd1d3aa62293192d3ce5dce7da2e','2025-12-16 21:43:18.000','20251210212941_add_transferencia_banco_saldos','A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251210212941_add_transferencia_banco_saldos\n\nDatabase error code: 1060\n\nDatabase error:\nDuplicate column name \'saldoFinalTransferenciaAzteca\'\n\nPlease check the query number 1 from the migration file.\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name=\"20251210212941_add_transferencia_banco_saldos\"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name=\"20251210212941_add_transferencia_banco_saldos\"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226',NULL,'2025-12-12 23:05:52.509',1),('529725d0-6c0a-4eeb-a387-725636988d50','895b304ad768b8e2d7e206b057eeea7d9fbfc793bb420dd96fc962327336eb1a','2025-12-29 06:16:34.756','20250101000001_add_laboratorios',NULL,NULL,'2025-12-29 06:16:34.728',1),('600cfaa6-4340-4fbf-b66f-b1bc5f8d720d','23ef139c92d8662823ac72ebb4bf625b88a0e4afd5a64c794be02bbecf3c03e3','2025-12-06 18:29:34.098','20251203052533_make_hora_optional',NULL,NULL,'2025-12-06 18:29:34.019',1),('6f32887f-8ad5-43c0-a34e-6be07b03769b','9baf583e6734b1e98c757ae37c2c9276a9d10ac056ad25aadad4d2973d654a5f','2025-12-12 23:05:52.459','20251208190404_add_banco_to_gasto',NULL,NULL,'2025-12-12 23:05:52.345',1),('7099921d-7520-4bc7-84ca-1f193f8645c2','e59d105e515bd4dcb09c8d8af62a8409074b2ba8a8d5c2360ecd47476a26b677','2026-01-03 18:42:27.313','20250101000004_add_almacen_features',NULL,NULL,'2026-01-03 18:42:26.939',1),('71980b37-37aa-4a04-95e6-a79cc3ed946d','d00ca7f8fe41723b6abd58bf89f0088f83b37ea74d7a206e9f5103c533cc19ed','2025-12-29 06:16:34.921','20250101000002_add_gasto_laboratorio',NULL,NULL,'2025-12-29 06:16:34.759',1),('7b0310b3-7831-4b36-801d-fc4ba078094a','d0b6ac3516f7edc6d6b79b99c90ad08231aa7f8d29acf7307c21feebed39fd03','2025-12-06 18:29:34.125','20251203115915_add_configuracion_cortes',NULL,NULL,'2025-12-06 18:29:34.103',1),('7ca3b0db-3b20-40db-858f-95488179c4f3','850112cc41bbac93daeae80c499b7fd638be0d6736230e82c0d2fc93c58edac0',NULL,'20251228230418_add_tratamientos_plazo','A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251228230418_add_tratamientos_plazo\n\nDatabase error code: 1050\n\nDatabase error:\nTable \'tratamientos_plazo\' already exists\n\nPlease check the query number 1 from the migration file.\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name=\"20251228230418_add_tratamientos_plazo\"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name=\"20251228230418_add_tratamientos_plazo\"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226','2025-12-29 06:20:25.818','2025-12-29 06:19:29.328',0),('86b1bc58-a36f-4a4f-a87a-f0898a4c359d','605e380cae4cb325f062fcd2f0b7f5522c0785524c12f9a5f2609159cc766969',NULL,'20251216000000_add_categorias','A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251216000000_add_categorias\n\nDatabase error code: 1060\n\nDatabase error:\nDuplicate column name \'categoriaId\'\n\nPlease check the query number 2 from the migration file.\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name=\"20251216000000_add_categorias\"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name=\"20251216000000_add_categorias\"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226','2025-12-29 06:18:04.409','2025-12-29 06:16:34.923',0),('ad5e507b-6a12-499a-91b2-eb27d9fc1bf3','907b5a67c604b53f9f3c2283215706dfee921d38d9214dd2f44d30ad734fb120',NULL,'20251227120000_add_vault_module','A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251227120000_add_vault_module\n\nDatabase error code: 1064\n\nDatabase error:\nYou have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near \'IF NOT EXISTS `doctorId` INTEGER NULL AFTER `pacienteId`,\r\n  ADD COLUMN IF NOT E\' at line 3\n\nPlease check the query number 2 from the migration file.\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name=\"20251227120000_add_vault_module\"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name=\"20251227120000_add_vault_module\"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226','2025-12-29 06:19:20.921','2025-12-29 06:18:16.613',0),('b2c80968-33bb-443c-8d50-f0915245549c','850112cc41bbac93daeae80c499b7fd638be0d6736230e82c0d2fc93c58edac0','2025-12-29 06:16:34.722','20250101000000_add_tratamientos_plazo',NULL,NULL,'2025-12-29 06:16:34.335',1),('b7a3a66f-bf19-45d2-8403-92489b9945a0','850112cc41bbac93daeae80c499b7fd638be0d6736230e82c0d2fc93c58edac0','2025-12-29 06:20:25.821','20251228230418_add_tratamientos_plazo','',NULL,'2025-12-29 06:20:25.821',0),('b8bee916-9733-4d51-afd3-2e5be9728d08','33562da4fc2b34da464cb9b9cc20474952c2d8d3a5b33a7dadd97902c45df8d9','2025-12-06 18:29:34.464','20251205222654_add_doctor_to_venta',NULL,NULL,'2025-12-06 18:29:34.332',1),('ffdacfcd-0e7a-437f-8eec-16f0719bbbdf','4431091809bd850d33c70ad48a47a10f987b6f37b814f1880349adf029f4f9db','2025-12-06 18:29:34.525','20251205230137_add_moneda_to_venta',NULL,NULL,'2025-12-06 18:29:34.469',1);
/*!40000 ALTER TABLE `_prisma_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `abonos_tratamiento`
--

DROP TABLE IF EXISTS `abonos_tratamiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abonos_tratamiento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tratamientoPlazoId` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `saldoAnterior` decimal(10,2) NOT NULL,
  `saldoNuevo` decimal(10,2) NOT NULL,
  `ventaId` int(11) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `abonos_tratamiento_tratamientoPlazoId_idx` (`tratamientoPlazoId`),
  KEY `abonos_tratamiento_ventaId_idx` (`ventaId`),
  KEY `abonos_tratamiento_usuarioId_idx` (`usuarioId`),
  CONSTRAINT `abonos_tratamiento_tratamientoPlazoId_fkey` FOREIGN KEY (`tratamientoPlazoId`) REFERENCES `tratamientos_plazo` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `abonos_tratamiento_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `abonos_tratamiento_ventaId_fkey` FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abonos_tratamiento`
--

LOCK TABLES `abonos_tratamiento` WRITE;
/*!40000 ALTER TABLE `abonos_tratamiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `abonos_tratamiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `antecedentes_medicos`
--

DROP TABLE IF EXISTS `antecedentes_medicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `antecedentes_medicos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pacienteId` int(11) NOT NULL,
  `alergias` text DEFAULT NULL,
  `enfermedades` text DEFAULT NULL,
  `medicamentos` text DEFAULT NULL,
  `cirugiasPrevias` text DEFAULT NULL,
  `antecedentesFam` text DEFAULT NULL,
  `notasMedicas` text DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `antecedentes_medicos_pacienteId_key` (`pacienteId`),
  CONSTRAINT `antecedentes_medicos_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `antecedentes_medicos`
--

LOCK TABLES `antecedentes_medicos` WRITE;
/*!40000 ALTER TABLE `antecedentes_medicos` DISABLE KEYS */;
INSERT INTO `antecedentes_medicos` VALUES (21,48,'Penicilina','Ninguna','Ninguno',NULL,NULL,NULL,'2025-12-16 22:24:43.208','2025-12-16 22:24:43.208'),(22,47,'Ninguna conocida','Diabetes tipo 2','Metformina',NULL,NULL,NULL,'2025-12-16 22:24:43.207','2025-12-16 22:24:43.207'),(23,50,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-17 22:10:05.172','2025-12-17 22:10:05.172'),(24,51,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-17 22:29:18.145','2025-12-17 22:29:18.145'),(25,52,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-17 23:48:13.724','2025-12-17 23:48:13.724'),(26,53,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-17 23:54:27.444','2025-12-17 23:54:27.444'),(27,54,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 00:38:34.702','2025-12-18 00:38:34.702'),(28,55,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 01:00:54.104','2025-12-18 01:00:54.104'),(29,56,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 15:52:43.497','2025-12-18 15:52:43.497'),(30,57,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 18:11:16.659','2025-12-18 18:11:16.659'),(31,58,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 18:12:55.598','2025-12-18 18:12:55.598'),(32,59,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 22:06:21.041','2025-12-18 22:06:21.041'),(33,60,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-18 23:20:00.463','2025-12-18 23:20:07.474'),(34,61,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 01:02:32.778','2025-12-19 01:02:32.778'),(35,62,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 17:20:07.704','2025-12-19 17:20:07.704'),(36,63,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 18:39:37.706','2025-12-19 18:39:37.706'),(37,64,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 18:48:55.621','2025-12-19 18:48:55.621'),(38,65,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 22:10:06.572','2025-12-19 22:10:06.572'),(39,66,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 22:11:09.675','2025-12-19 22:11:09.675'),(40,67,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-19 23:30:16.998','2025-12-19 23:30:16.998'),(41,68,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-20 00:00:31.676','2025-12-20 00:00:31.676'),(42,69,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-20 17:04:50.759','2025-12-20 17:04:50.759'),(43,70,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-20 17:05:07.881','2025-12-20 17:05:07.881'),(44,71,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-20 17:26:22.309','2025-12-20 17:26:22.309'),(45,72,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-20 18:27:27.520','2025-12-20 18:27:27.520'),(46,73,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-22 18:38:05.754','2025-12-22 18:38:05.754'),(47,74,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-22 22:52:43.318','2025-12-22 22:52:43.318'),(48,75,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-22 23:28:45.974','2025-12-22 23:28:45.974'),(49,76,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 00:12:39.544','2025-12-23 00:12:39.544'),(50,77,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 00:32:50.743','2025-12-23 00:32:50.743'),(51,78,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 22:02:49.008','2025-12-23 22:02:49.008'),(52,79,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 22:53:35.006','2025-12-23 22:53:35.006'),(53,80,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 22:55:42.238','2025-12-23 22:55:42.238'),(54,81,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-23 23:36:14.192','2025-12-23 23:36:14.192'),(55,82,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-24 00:07:33.644','2025-12-24 00:07:33.644'),(56,83,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-24 18:04:38.802','2025-12-24 18:04:38.802'),(57,84,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-26 17:36:39.858','2025-12-26 17:36:39.858'),(58,85,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-26 18:06:28.032','2025-12-26 18:06:28.032'),(59,86,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-26 18:21:07.896','2025-12-26 18:21:07.896'),(60,87,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-26 22:36:37.398','2025-12-26 22:36:37.398'),(61,88,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-27 16:05:55.458','2025-12-27 16:05:55.458'),(62,89,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-29 22:56:18.085','2025-12-29 22:56:18.085'),(63,90,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-29 22:57:37.715','2025-12-29 22:57:37.715'),(64,91,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-29 23:05:11.253','2025-12-29 23:05:11.253'),(65,92,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-30 16:20:24.764','2025-12-30 16:20:24.764'),(66,93,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 16:51:34.096','2026-01-14 16:51:34.096'),(67,94,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 16:52:17.087','2026-01-14 16:52:17.087'),(68,95,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 17:55:45.539','2026-01-14 17:55:45.539'),(69,96,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 17:56:53.089','2026-01-14 17:56:53.089'),(70,97,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 18:19:31.252','2026-01-14 18:19:31.252'),(71,98,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-15 00:10:34.991','2026-01-15 00:10:34.991'),(72,99,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-15 00:15:07.387','2026-01-15 00:15:07.387'),(73,100,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-15 00:53:52.299','2026-01-15 00:53:52.299'),(74,101,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-15 22:12:43.082','2026-01-15 22:12:43.082'),(75,102,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-15 22:13:19.520','2026-01-15 22:13:19.520'),(76,103,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 00:01:38.040','2026-01-16 00:01:38.040'),(77,104,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 00:15:26.052','2026-01-16 00:15:26.052'),(78,105,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 00:15:49.725','2026-01-16 00:15:49.725'),(79,106,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 00:37:25.657','2026-01-16 00:37:25.657'),(80,107,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 00:38:47.321','2026-01-16 00:38:47.321'),(81,108,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-16 17:54:10.560','2026-01-16 17:54:10.560'),(82,109,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-17 00:43:00.820','2026-01-17 00:43:00.820'),(83,110,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-17 00:43:41.425','2026-01-17 00:43:41.425'),(84,111,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-17 00:44:04.578','2026-01-17 00:44:04.578'),(85,112,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-19 17:20:46.478','2026-01-19 17:20:46.478'),(86,113,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-19 18:12:17.782','2026-01-19 18:12:17.782'),(87,114,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-20 00:22:22.440','2026-01-20 00:22:22.440'),(88,115,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-20 00:25:31.146','2026-01-20 00:25:31.146'),(89,116,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-20 00:26:26.451','2026-01-20 00:26:26.451'),(90,117,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-20 00:34:18.391','2026-01-20 00:34:18.391'),(91,118,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-20 17:12:18.771','2026-01-20 17:12:18.771'),(92,119,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-21 18:30:45.137','2026-01-21 18:30:45.137'),(93,120,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-21 18:31:00.401','2026-01-21 18:31:00.401'),(94,121,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-22 00:38:54.604','2026-01-22 00:38:54.604'),(95,122,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-22 18:14:31.395','2026-01-22 18:14:31.395'),(96,123,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-22 21:55:56.462','2026-01-22 21:55:56.462'),(97,124,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-24 15:45:37.779','2026-01-24 15:45:37.779');
/*!40000 ALTER TABLE `antecedentes_medicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archivos_pacientes`
--

DROP TABLE IF EXISTS `archivos_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archivos_pacientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pacienteId` int(11) NOT NULL,
  `nombre` varchar(191) NOT NULL,
  `tipo` varchar(191) NOT NULL,
  `ruta` varchar(191) NOT NULL,
  `descripcion` varchar(191) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `archivos_pacientes_pacienteId_fkey` (`pacienteId`),
  CONSTRAINT `archivos_pacientes_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archivos_pacientes`
--

LOCK TABLES `archivos_pacientes` WRITE;
/*!40000 ALTER TABLE `archivos_pacientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `archivos_pacientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `color` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categorias_nombre_key` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (45,'Cirug??a','Procedimientos quir??rgicos','#ef4444',1,'2025-12-16 22:24:43.225','2025-12-16 22:24:43.225'),(46,'Est??tico','Servicios de est??tica dental','#ec4899',1,'2025-12-16 22:24:43.225','2025-12-16 22:24:43.225'),(47,'Preventivo','Servicios preventivos y limpieza','#10b981',1,'2025-12-16 22:24:43.225','2025-12-16 22:24:43.225'),(48,'Restaurativo','Restauraciones y empastes','#f59e0b',1,'2025-12-16 22:24:43.225','2025-12-16 22:24:43.225'),(49,'General','Servicios generales de odontolog??a','#3b82f6',1,'2025-12-16 22:24:43.225','2025-12-16 22:24:43.225'),(50,'Endodoncia','Tratamientos de endodoncia','#6366f1',1,'2025-12-16 22:24:43.226','2025-12-16 22:24:43.226'),(51,'Ortodoncia','Tratamientos de ortodoncia','#8b5cf6',1,'2025-12-16 22:24:43.226','2025-12-16 22:24:43.226'),(52,'Odontopediatra',NULL,'#d5a6d8',1,'2026-01-24 15:47:01.976','2026-01-24 15:47:01.976');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `citas`
--

DROP TABLE IF EXISTS `citas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `citas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pacienteId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `consultorioId` int(11) DEFAULT NULL,
  `fecha` datetime(3) NOT NULL,
  `horaInicio` varchar(191) NOT NULL,
  `horaFin` varchar(191) NOT NULL,
  `motivo` text DEFAULT NULL,
  `estado` varchar(191) NOT NULL DEFAULT 'programada',
  `notas` text DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citas_pacienteId_fkey` (`pacienteId`),
  KEY `citas_doctorId_fkey` (`doctorId`),
  KEY `citas_consultorioId_fkey` (`consultorioId`),
  CONSTRAINT `citas_consultorioId_fkey` FOREIGN KEY (`consultorioId`) REFERENCES `consultorios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `citas_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `citas_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `citas`
--

LOCK TABLES `citas` WRITE;
/*!40000 ALTER TABLE `citas` DISABLE KEYS */;
INSERT INTO `citas` VALUES (7,47,28,27,'2025-12-16 22:24:43.254','11:00','12:30','Endodoncia molar inferior','programada',NULL,'2025-12-16 22:24:43.255','2025-12-16 22:24:43.255'),(8,48,30,26,'2025-12-16 22:24:43.254','10:00','10:45','Revisi??n de brackets','programada',NULL,'2025-12-16 22:24:43.255','2025-12-16 22:24:43.255'),(9,46,29,25,'2025-12-17 22:24:43.254','09:00','09:45','Revisi??n peri??dica','programada',NULL,'2025-12-16 22:24:43.256','2025-12-16 22:24:43.256');
/*!40000 ALTER TABLE `citas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conceptos_prestamos`
--

DROP TABLE IF EXISTS `conceptos_prestamos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conceptos_prestamos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `createdAt` datetime(3) DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) DEFAULT current_timestamp(3) ON UPDATE current_timestamp(3),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conceptos_prestamos`
--

LOCK TABLES `conceptos_prestamos` WRITE;
/*!40000 ALTER TABLE `conceptos_prestamos` DISABLE KEYS */;
INSERT INTO `conceptos_prestamos` VALUES (1,'COMIDA',NULL,1,'2026-01-25 17:40:39.596','2026-01-25 17:40:39.596');
/*!40000 ALTER TABLE `conceptos_prestamos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion_cortes`
--

DROP TABLE IF EXISTS `configuracion_cortes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuracion_cortes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `horaCorte1` varchar(191) NOT NULL DEFAULT '14:00',
  `horaCorte2` varchar(191) NOT NULL DEFAULT '18:00',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion_cortes`
--

LOCK TABLES `configuracion_cortes` WRITE;
/*!40000 ALTER TABLE `configuracion_cortes` DISABLE KEYS */;
INSERT INTO `configuracion_cortes` VALUES (1,'14:00','18:00',1,'2025-12-07 04:59:07.707','2025-12-07 04:59:07.707');
/*!40000 ALTER TABLE `configuracion_cortes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion_retiros`
--

DROP TABLE IF EXISTS `configuracion_retiros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuracion_retiros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `montoMaximoEfectivo` decimal(10,2) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion_retiros`
--

LOCK TABLES `configuracion_retiros` WRITE;
/*!40000 ALTER TABLE `configuracion_retiros` DISABLE KEYS */;
INSERT INTO `configuracion_retiros` VALUES (1,0.00,1,'2025-12-30 21:33:00.668','2025-12-30 21:33:00.668');
/*!40000 ALTER TABLE `configuracion_retiros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion_tipo_cambio`
--

DROP TABLE IF EXISTS `configuracion_tipo_cambio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuracion_tipo_cambio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipoCambio` decimal(10,4) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion_tipo_cambio`
--

LOCK TABLES `configuracion_tipo_cambio` WRITE;
/*!40000 ALTER TABLE `configuracion_tipo_cambio` DISABLE KEYS */;
INSERT INTO `configuracion_tipo_cambio` VALUES (1,20.0000,1,'2025-12-07 16:26:07.295','2025-12-07 16:26:07.295');
/*!40000 ALTER TABLE `configuracion_tipo_cambio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consultas`
--

DROP TABLE IF EXISTS `consultas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consultas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pacienteId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `fecha` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `motivoConsulta` text DEFAULT NULL,
  `diagnostico` text DEFAULT NULL,
  `tratamiento` text DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `proximaCita` datetime(3) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `consultas_pacienteId_fkey` (`pacienteId`),
  KEY `consultas_doctorId_fkey` (`doctorId`),
  CONSTRAINT `consultas_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `consultas_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultas`
--

LOCK TABLES `consultas` WRITE;
/*!40000 ALTER TABLE `consultas` DISABLE KEYS */;
/*!40000 ALTER TABLE `consultas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consultorios`
--

DROP TABLE IF EXISTS `consultorios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consultorios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `ubicacion` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultorios`
--

LOCK TABLES `consultorios` WRITE;
/*!40000 ALTER TABLE `consultorios` DISABLE KEYS */;
INSERT INTO `consultorios` VALUES (25,'Consultorio 3','Primer piso',1,'2025-12-16 22:24:42.827','2025-12-16 22:24:42.827'),(26,'Consultorio 1','Planta baja',1,'2025-12-16 22:24:42.827','2025-12-16 22:24:42.827'),(27,'Consultorio 2','Planta baja',1,'2025-12-16 22:24:42.827','2025-12-16 22:24:42.827');
/*!40000 ALTER TABLE `consultorios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cortes_caja`
--

DROP TABLE IF EXISTS `cortes_caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cortes_caja` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `hora` varchar(191) DEFAULT NULL,
  `saldoInicialEfectivo` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoInicialTransferencia` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoInicial` decimal(10,2) NOT NULL,
  `ventasEfectivo` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTarjeta` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTransferencia` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTarjetaAzteca` decimal(10,2) NOT NULL DEFAULT 0.00,
  `totalVentas` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalEfectivo` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTransferencia` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTransferenciaAzteca` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTransferenciaBbva` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTransferenciaMp` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinal` decimal(10,2) NOT NULL,
  `diferencia` decimal(10,2) NOT NULL DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  `saldoInicialTarjetaAzteca` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoInicialTarjetaBbva` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoInicialTarjetaMp` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTransferenciaAzteca` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTransferenciaBbva` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTransferenciaMp` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTarjetaAzteca` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTarjetaBbva` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoFinalTarjetaMp` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTarjetaBbva` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ventasTarjetaMp` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `cortes_caja_usuarioId_fkey` (`usuarioId`),
  CONSTRAINT `cortes_caja_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cortes_caja`
--

LOCK TABLES `cortes_caja` WRITE;
/*!40000 ALTER TABLE `cortes_caja` DISABLE KEYS */;
INSERT INTO `cortes_caja` VALUES (1,'2025-12-07 04:53:22.946',NULL,10000.00,0.00,10000.00,0.00,0.00,0.00,0.00,0.00,10000.00,0.00,0.00,0.00,0.00,10000.00,0.00,NULL,NULL,'2025-12-07 04:53:22.947','2025-12-07 04:53:22.947',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(2,'2025-12-07 04:59:00.395','22:58',10000.00,0.00,10000.00,10405.00,8020.00,5275.00,3155.00,23700.00,20405.00,5275.00,0.00,0.00,0.00,20405.00,0.00,NULL,NULL,'2025-12-07 04:59:00.396','2025-12-07 04:59:00.396',0.00,0.00,0.00,0.00,0.00,0.00,3155.00,4255.00,610.00,0.00,0.00),(3,'2025-12-07 04:59:05.462',NULL,1000.00,0.00,1000.00,0.00,0.00,0.00,0.00,0.00,1000.00,0.00,0.00,0.00,0.00,1000.00,0.00,NULL,NULL,'2025-12-07 04:59:05.463','2025-12-07 04:59:05.463',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(4,'2025-12-07 16:25:33.202',NULL,1000.00,0.00,1000.00,0.00,0.00,0.00,0.00,0.00,1000.00,0.00,0.00,0.00,0.00,1000.00,0.00,NULL,NULL,'2025-12-07 16:25:33.203','2025-12-07 16:25:33.203',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(5,'2025-12-07 16:29:38.716','10:28',1000.00,0.00,1000.00,0.00,0.00,2500.00,0.00,2500.00,1000.00,2500.00,0.00,0.00,0.00,1000.00,0.00,NULL,NULL,'2025-12-07 16:29:38.717','2025-12-07 16:29:38.717',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(6,'2025-12-07 16:30:35.953',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,NULL,'2025-12-07 16:30:35.954','2025-12-07 16:30:35.954',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(7,'2025-12-08 01:55:26.349',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,NULL,'2025-12-08 01:55:26.401','2025-12-08 01:55:26.401',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(8,'2025-12-09 00:14:43.579',NULL,7355.00,0.00,7355.00,0.00,0.00,0.00,0.00,0.00,7355.00,0.00,0.00,0.00,0.00,7355.00,0.00,NULL,NULL,'2025-12-09 00:14:43.580','2025-12-09 00:14:43.580',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(9,'2025-12-12 16:59:04.674',NULL,3633.00,0.00,3633.00,0.00,0.00,0.00,0.00,0.00,3633.00,0.00,0.00,0.00,0.00,3633.00,0.00,NULL,NULL,'2025-12-12 16:59:04.675','2025-12-12 16:59:04.675',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(10,'2025-12-15 17:13:40.817',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,NULL,'2025-12-15 17:13:40.819','2025-12-15 17:13:40.819',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(11,'2025-12-15 18:34:48.769','12:34',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,16398.00,0.00,0.00,0.00,0.00,16398.00,16398.00,NULL,NULL,'2025-12-15 18:34:48.770','2025-12-15 18:34:48.770',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(12,'2025-12-15 18:35:09.456',NULL,16398.00,0.00,16398.00,0.00,0.00,0.00,0.00,0.00,16398.00,0.00,0.00,0.00,0.00,16398.00,0.00,NULL,NULL,'2025-12-15 18:35:09.457','2025-12-15 18:35:09.457',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(13,'2025-12-16 00:43:58.308','18:43',16398.00,0.00,16398.00,4375.00,1575.00,0.00,0.00,5950.00,4222.00,0.00,0.00,0.00,0.00,4222.00,-16551.00,NULL,NULL,'2025-12-16 00:43:58.309','2025-12-16 00:43:58.309',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1575.00,0.00,0.00),(14,'2025-12-16 01:01:43.326',NULL,1000.00,0.00,1000.00,0.00,0.00,0.00,0.00,0.00,1000.00,0.00,0.00,0.00,0.00,1000.00,0.00,NULL,NULL,'2025-12-16 01:01:43.327','2025-12-16 01:01:43.327',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(15,'2025-12-16 23:17:31.556',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,25,'2025-12-16 23:17:31.557','2025-12-16 23:17:31.557',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(16,'2025-12-17 22:05:01.818',NULL,26922.00,0.00,26922.00,0.00,0.00,0.00,0.00,0.00,26922.00,0.00,0.00,0.00,0.00,26922.00,0.00,NULL,25,'2025-12-17 22:05:01.820','2025-12-17 22:05:01.820',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(17,'2025-12-18 01:03:57.223','19:03',26922.00,0.00,26922.00,5100.00,16000.00,2000.00,0.00,23100.00,31685.00,2000.00,2000.00,0.00,0.00,31685.00,-337.00,NULL,25,'2025-12-18 01:03:57.223','2025-12-18 01:03:57.223',0.00,0.00,0.00,2000.00,0.00,0.00,0.00,16000.00,0.00,0.00,0.00),(18,'2025-12-18 15:15:56.098',NULL,31685.00,0.00,31685.00,0.00,0.00,0.00,0.00,0.00,31685.00,0.00,0.00,0.00,0.00,31685.00,0.00,NULL,25,'2025-12-18 15:15:56.099','2025-12-18 15:15:56.099',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(19,'2025-12-19 01:07:20.382','19:07',31685.00,0.00,31685.00,3600.00,4750.00,0.00,0.00,8350.00,34975.00,0.00,0.00,0.00,0.00,34975.00,-310.00,NULL,25,'2025-12-19 01:07:20.382','2025-12-19 01:07:20.382',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,4750.00,0.00,0.00),(20,'2025-12-19 15:27:09.651',NULL,34975.00,0.00,34975.00,0.00,0.00,0.00,0.00,0.00,34975.00,0.00,0.00,0.00,0.00,34975.00,0.00,NULL,25,'2025-12-19 15:27:09.653','2025-12-19 15:27:09.653',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(21,'2025-12-20 00:11:20.719','18:10',34975.00,0.00,34975.00,0.00,17900.00,0.00,0.00,17900.00,32815.00,0.00,0.00,0.00,0.00,32815.00,-2160.00,NULL,25,'2025-12-20 00:11:20.720','2025-12-20 00:11:20.720',0.00,0.00,0.00,0.00,0.00,0.00,0.00,8600.00,9300.00,0.00,0.00),(22,'2025-12-20 16:53:48.468',NULL,32815.00,0.00,32815.00,0.00,0.00,0.00,0.00,0.00,32815.00,0.00,0.00,0.00,0.00,32815.00,0.00,NULL,25,'2025-12-20 16:53:48.469','2025-12-20 16:53:48.469',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(23,'2025-12-20 19:14:34.167','13:13',32815.00,0.00,32815.00,6875.00,4400.00,0.00,0.00,11275.00,31115.00,0.00,0.00,0.00,0.00,31115.00,-8575.00,NULL,25,'2025-12-20 19:14:34.168','2025-12-20 19:14:34.168',0.00,0.00,0.00,0.00,0.00,0.00,0.00,3700.00,700.00,0.00,0.00),(24,'2025-12-20 19:30:40.444',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,25,'2025-12-20 19:30:40.445','2025-12-20 19:30:40.445',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(25,'2025-12-22 15:12:07.762',NULL,31115.00,0.00,31115.00,0.00,0.00,0.00,0.00,0.00,31115.00,0.00,0.00,0.00,0.00,31115.00,0.00,NULL,25,'2025-12-22 15:12:07.764','2025-12-22 15:12:07.764',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(26,'2025-12-23 01:04:22.589','19:04',31115.00,0.00,31115.00,3350.00,0.00,0.00,0.00,3350.00,12776.00,0.00,0.00,0.00,0.00,12776.00,0.00,NULL,25,'2025-12-23 01:04:22.589','2025-12-23 01:04:22.589',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(27,'2025-12-23 21:58:53.088',NULL,12776.00,0.00,12776.00,0.00,0.00,0.00,0.00,0.00,12776.00,0.00,0.00,0.00,0.00,12776.00,0.00,NULL,25,'2025-12-23 21:58:53.089','2025-12-23 21:58:53.089',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(28,'2025-12-24 00:10:51.002','18:10',12776.00,0.00,12776.00,1300.00,0.00,0.00,0.00,1300.00,13657.00,0.00,0.00,0.00,0.00,13657.00,0.00,NULL,25,'2025-12-24 00:10:51.003','2025-12-24 00:10:51.003',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(29,'2025-12-24 16:04:38.533',NULL,13657.00,0.00,13657.00,0.00,0.00,0.00,0.00,0.00,13657.00,0.00,0.00,0.00,0.00,13657.00,0.00,NULL,25,'2025-12-24 16:04:38.534','2025-12-24 16:04:38.534',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(30,'2025-12-24 18:52:39.526','12:52',13657.00,0.00,13657.00,4200.00,0.00,0.00,0.00,4200.00,17470.00,0.00,0.00,0.00,0.00,17470.00,0.00,NULL,25,'2025-12-24 18:52:39.527','2025-12-24 18:52:39.527',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(31,'2025-12-26 15:31:16.225',NULL,16970.00,0.00,16970.00,0.00,0.00,0.00,0.00,0.00,16970.00,0.00,0.00,0.00,0.00,16970.00,0.00,NULL,25,'2025-12-26 15:31:16.226','2025-12-26 15:31:16.226',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(32,'2025-12-27 00:53:27.499','18:53',16970.00,0.00,16970.00,1200.00,0.00,0.00,0.00,1200.00,16838.00,0.00,0.00,0.00,0.00,16838.00,0.00,NULL,25,'2025-12-27 00:53:27.500','2025-12-27 00:53:27.500',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(33,'2025-12-27 15:06:25.495',NULL,16838.00,0.00,16838.00,0.00,0.00,0.00,0.00,0.00,16838.00,0.00,0.00,0.00,0.00,16838.00,0.00,NULL,25,'2025-12-27 15:06:25.497','2025-12-27 15:06:25.497',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(34,'2025-12-27 19:01:32.483','13:01',16838.00,0.00,16838.00,800.00,0.00,0.00,0.00,800.00,12969.00,0.00,0.00,0.00,0.00,12969.00,0.00,NULL,25,'2025-12-27 19:01:32.484','2025-12-27 19:01:32.484',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(35,'2025-12-29 06:22:51.639',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,-700.00,0.00,-700.00,0.00,-700.00,0.00,NULL,25,'2025-12-29 06:22:51.640','2025-12-29 23:13:31.048',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(36,'2025-12-30 00:17:51.454','18:17',0.00,0.00,0.00,15209.00,0.00,0.00,0.00,15209.00,13042.00,0.00,0.00,0.00,0.00,13042.00,0.00,NULL,25,'2025-12-30 00:17:51.455','2025-12-30 00:17:51.455',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(37,'2025-12-30 15:30:31.803',NULL,13042.00,0.00,13042.00,0.00,0.00,0.00,0.00,0.00,13042.00,0.00,0.00,0.00,0.00,13042.00,0.00,NULL,25,'2025-12-30 15:30:31.805','2025-12-30 15:30:31.805',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(38,'2025-12-31 15:53:08.848',NULL,19342.00,0.00,19342.00,0.00,0.00,0.00,0.00,0.00,19342.00,0.00,0.00,0.00,0.00,19342.00,0.00,NULL,25,'2025-12-31 15:53:08.849','2025-12-31 15:53:08.849',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(39,'2026-01-03 18:47:01.747',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,25,'2026-01-03 18:47:01.748','2026-01-03 18:47:01.748',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(40,'2026-01-07 15:35:37.182',NULL,5803.00,0.00,5803.00,0.00,0.00,0.00,0.00,0.00,5803.00,0.00,0.00,0.00,0.00,5803.00,0.00,NULL,25,'2026-01-07 15:35:37.184','2026-01-07 15:35:37.184',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(41,'2026-01-08 17:40:16.231',NULL,5208.00,0.00,5208.00,0.00,0.00,0.00,0.00,0.00,5208.00,0.00,0.00,0.00,0.00,5208.00,0.00,NULL,25,'2026-01-08 17:40:16.232','2026-01-08 17:40:16.232',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(42,'2026-01-13 21:18:02.461',NULL,1440.00,0.00,1440.00,0.00,0.00,0.00,0.00,0.00,1440.00,0.00,0.00,0.00,0.00,1440.00,0.00,NULL,25,'2026-01-13 21:18:02.462','2026-01-13 21:18:02.462',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(43,'2026-01-14 00:59:32.685','18:59',1440.00,0.00,1440.00,0.00,0.00,0.00,0.00,0.00,1275.00,0.00,0.00,0.00,0.00,1275.00,0.00,NULL,25,'2026-01-14 00:59:32.687','2026-01-14 00:59:32.687',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(44,'2026-01-14 16:18:25.882',NULL,1275.00,0.00,1275.00,0.00,0.00,0.00,0.00,0.00,1275.00,0.00,0.00,0.00,0.00,595.00,0.00,NULL,25,'2026-01-14 16:18:25.883','2026-01-15 00:19:05.467',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,-680.00,0.00,0.00),(45,'2026-01-15 01:02:02.364','19:00',1275.00,0.00,1275.00,10300.00,0.00,0.00,0.00,10300.00,10875.00,0.00,0.00,0.00,0.00,10875.00,0.00,NULL,25,'2026-01-15 01:02:02.364','2026-01-15 01:02:02.364',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(46,'2026-01-15 17:33:09.921',NULL,10875.00,0.00,10875.00,0.00,0.00,0.00,0.00,0.00,10875.00,0.00,0.00,0.00,0.00,10875.00,0.00,NULL,25,'2026-01-15 17:33:09.922','2026-01-15 17:33:09.922',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(47,'2026-01-16 00:58:27.918','18:57',10875.00,0.00,10875.00,7965.00,0.00,0.00,0.00,7965.00,2476.00,0.00,0.00,0.00,0.00,2476.00,0.00,NULL,25,'2026-01-16 00:58:27.919','2026-01-16 00:58:27.919',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(48,'2026-01-16 17:44:02.052',NULL,2476.00,0.00,2476.00,0.00,0.00,0.00,0.00,0.00,2476.00,0.00,0.00,0.00,0.00,2476.00,0.00,NULL,25,'2026-01-16 17:44:02.054','2026-01-16 17:44:02.054',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(49,'2026-01-17 01:04:09.138','19:01',2476.00,0.00,2476.00,3200.00,0.00,0.00,0.00,3200.00,2577.00,0.00,0.00,0.00,0.00,2577.00,0.00,NULL,25,'2026-01-17 01:04:09.139','2026-01-17 01:04:09.139',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(50,'2026-01-17 17:43:30.169',NULL,2577.00,0.00,2577.00,0.00,0.00,0.00,0.00,0.00,2577.00,0.00,0.00,0.00,0.00,2577.00,0.00,NULL,25,'2026-01-17 17:43:30.172','2026-01-17 17:43:30.172',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(51,'2026-01-17 18:41:31.977','12:40',2577.00,0.00,2577.00,3673.00,0.00,0.00,0.00,3673.00,945.00,0.00,0.00,0.00,0.00,945.00,0.00,NULL,25,'2026-01-17 18:41:31.978','2026-01-17 18:41:31.978',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(52,'2026-01-19 17:19:58.651',NULL,945.00,0.00,945.00,0.00,0.00,0.00,0.00,0.00,945.00,0.00,0.00,0.00,0.00,945.00,0.00,NULL,25,'2026-01-19 17:19:58.652','2026-01-19 17:19:58.652',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(53,'2026-01-20 01:11:04.253','19:10',945.00,0.00,945.00,5000.00,0.00,0.00,0.00,5000.00,5567.00,0.00,0.00,0.00,0.00,5567.00,0.00,NULL,25,'2026-01-20 01:11:04.254','2026-01-20 01:11:04.254',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(54,'2026-01-20 17:11:49.248',NULL,5567.00,0.00,5567.00,0.00,0.00,0.00,0.00,0.00,5567.00,0.00,0.00,0.00,0.00,5567.00,0.00,NULL,25,'2026-01-20 17:11:49.250','2026-01-20 17:11:49.250',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(55,'2026-01-21 01:12:10.177','19:11',5567.00,0.00,5567.00,650.00,0.00,0.00,0.00,650.00,5637.00,0.00,0.00,0.00,0.00,5637.00,0.00,NULL,25,'2026-01-21 01:12:10.179','2026-01-21 01:12:10.179',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(56,'2026-01-21 16:54:05.343',NULL,5637.00,0.00,5637.00,0.00,0.00,0.00,0.00,0.00,5637.00,0.00,0.00,0.00,0.00,5637.00,0.00,NULL,25,'2026-01-21 16:54:05.345','2026-01-21 16:54:05.345',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(57,'2026-01-22 00:46:44.420','18:46',5637.00,0.00,5637.00,4020.00,0.00,0.00,0.00,4020.00,8932.00,0.00,0.00,0.00,0.00,8932.00,0.00,NULL,25,'2026-01-22 00:46:44.420','2026-01-22 00:46:44.420',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(58,'2026-01-22 18:12:59.819',NULL,8932.00,0.00,8932.00,0.00,0.00,0.00,0.00,0.00,8932.00,0.00,0.00,0.00,0.00,8932.00,0.00,NULL,25,'2026-01-22 18:12:59.821','2026-01-22 18:12:59.821',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(59,'2026-01-23 15:40:09.086',NULL,13738.00,0.00,13738.00,0.00,0.00,0.00,0.00,0.00,13738.00,0.00,0.00,0.00,0.00,13738.00,0.00,NULL,25,'2026-01-23 15:40:09.088','2026-01-23 15:40:09.088',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(60,'2026-01-24 14:35:34.438',NULL,13458.00,0.00,13458.00,0.00,0.00,0.00,0.00,0.00,13458.00,0.00,0.00,0.00,0.00,13458.00,0.00,NULL,25,'2026-01-24 14:35:34.440','2026-01-24 14:35:34.440',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(61,'2026-01-24 21:25:36.535','15:24',13458.00,0.00,13458.00,6600.00,0.00,0.00,0.00,6600.00,10745.00,0.00,0.00,0.00,0.00,10745.00,0.00,NULL,25,'2026-01-24 21:25:36.536','2026-01-24 21:25:36.536',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),(62,'2026-01-25 13:51:56.996',NULL,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,25,'2026-01-25 13:51:57.001','2026-01-25 13:51:57.001',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00);
/*!40000 ALTER TABLE `cortes_caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctores`
--

DROP TABLE IF EXISTS `doctores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doctores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `apellido` varchar(191) NOT NULL,
  `especialidad` varchar(191) NOT NULL,
  `telefono` varchar(191) DEFAULT NULL,
  `email` varchar(191) DEFAULT NULL,
  `color` varchar(191) NOT NULL DEFAULT '#3b82f6',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `doctores_email_key` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctores`
--

LOCK TABLES `doctores` WRITE;
/*!40000 ALTER TABLE `doctores` DISABLE KEYS */;
INSERT INTO `doctores` VALUES (28,'Ana','L??pez Hern??ndez','Endodoncia','555-0102','dra.lopez@clinica.com','#10b981',1,'2025-12-16 22:24:42.842','2025-12-16 22:24:42.842'),(29,'Carlos','Rodr??guez P??rez','Odontopediatr??a','555-0103','dr.rodriguez@clinica.com','#f59e0b',1,'2025-12-16 22:24:42.842','2025-12-16 22:24:42.842'),(30,'Juan','Mart??nez Garc??a','Ortodoncia','555-0101','dr.martinez@clinica.com','#3b82f6',1,'2025-12-16 22:24:42.842','2025-12-16 22:24:42.842'),(31,'Jorge','Cuauhtli','Cirug??a','9871410773',NULL,'#3b82f6',1,'2025-12-17 22:10:45.310','2025-12-17 22:10:45.310'),(32,'Sandy ','Osorio ','General ',' 9871383457',NULL,'#f4ee4e',1,'2025-12-17 22:11:20.822','2025-12-17 22:11:34.507'),(33,'Yahir','Najera Chan','Endodoncia','9851228013','yahirnc11@gmail.com','#030303',1,'2025-12-17 22:12:13.744','2025-12-17 22:12:13.744'),(34,'Luz','Ayamaind','Odontopediatra','9841760687',NULL,'#d997dd',1,'2025-12-17 22:12:40.481','2025-12-17 22:12:40.481'),(35,'Alejandro ','Canales','Ortodoncia','9841163795',NULL,'#3cd3b9',1,'2025-12-17 22:15:37.442','2025-12-17 22:15:37.442'),(36,'Jhonatan','Baas Canche','Odontolog??a digital','9871043349','jhonbaascan@gmail.com','#f7483b',1,'2025-12-17 23:49:14.503','2025-12-17 23:49:14.503');
/*!40000 ALTER TABLE `doctores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gastos`
--

DROP TABLE IF EXISTS `gastos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gastos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `motivo` varchar(191) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `metodoPago` varchar(191) NOT NULL DEFAULT 'efectivo',
  `banco` varchar(191) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  `tipo` varchar(191) NOT NULL DEFAULT 'general',
  `laboratorioId` int(11) DEFAULT NULL,
  `pacienteId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gastos_usuarioId_idx` (`usuarioId`),
  KEY `gastos_laboratorioId_fkey` (`laboratorioId`),
  KEY `gastos_pacienteId_fkey` (`pacienteId`),
  CONSTRAINT `gastos_laboratorioId_fkey` FOREIGN KEY (`laboratorioId`) REFERENCES `laboratorios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gastos_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gastos_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gastos`
--

LOCK TABLES `gastos` WRITE;
/*!40000 ALTER TABLE `gastos` DISABLE KEYS */;
INSERT INTO `gastos` VALUES (1,'posada',15000.00,'efectivo',NULL,NULL,NULL,'2025-12-07 04:58:09.374','2025-12-07 04:58:09.374','general',NULL,NULL),(2,'insumos',3000.00,'tarjeta',NULL,NULL,NULL,'2025-12-09 00:28:12.763','2025-12-09 00:28:12.763','general',NULL,NULL),(3,'Desayuno',155.00,'efectivo',NULL,'Desayuno Alicia Sandy',NULL,'2025-12-15 21:33:52.768','2025-12-15 21:33:52.768','general',NULL,NULL),(4,'Publicidad ',1750.00,'efectivo',NULL,NULL,NULL,'2025-12-15 22:43:58.334','2025-12-15 22:43:58.334','general',NULL,NULL),(5,'Cobro Maricarmen error',1575.00,'efectivo',NULL,'Me equivoque en m??todo de pago',NULL,'2025-12-15 23:45:21.542','2025-12-15 23:45:21.542','general',NULL,NULL),(6,'Alicia Nomina',4200.00,'efectivo',NULL,NULL,NULL,'2025-12-16 00:14:10.291','2025-12-16 00:14:10.291','general',NULL,NULL),(7,'Julissa Nomina',1180.00,'efectivo',NULL,NULL,NULL,'2025-12-16 00:14:30.998','2025-12-16 00:14:30.998','general',NULL,NULL),(8,'Sandy Nomina',4448.00,'efectivo',NULL,NULL,NULL,'2025-12-16 00:14:48.373','2025-12-16 00:14:48.373','general',NULL,NULL),(9,'Jhonatan Nomina',3243.00,'efectivo',NULL,NULL,NULL,'2025-12-16 00:15:16.335','2025-12-16 00:15:16.335','general',NULL,NULL),(10,'Desayuno',230.00,'efectivo',NULL,'Desayuno Alicia Sandy',25,'2025-12-17 22:17:00.208','2025-12-17 22:17:00.208','general',NULL,NULL),(11,'Farmacia',107.00,'efectivo',NULL,'Suero ',25,'2025-12-17 23:49:50.818','2025-12-17 23:49:50.818','general',NULL,NULL),(12,'Farmacia Cuau',56.00,'efectivo',NULL,NULL,25,'2025-12-18 15:53:25.151','2025-12-18 15:53:25.151','general',NULL,NULL),(13,'Azamar laboratorio',35.00,'efectivo',NULL,'Delivery trabajo Xiomara Acu??a',25,'2025-12-18 18:13:41.375','2025-12-18 18:13:41.375','general',NULL,NULL),(14,'Agua',84.00,'efectivo',NULL,'2 botellones',25,'2025-12-18 18:23:26.338','2025-12-18 18:23:26.338','general',NULL,NULL),(15,'Delivery Azamar',35.00,'efectivo',NULL,'Trabajo Px Ana Orozco',25,'2025-12-18 21:54:28.354','2025-12-18 21:54:28.354','general',NULL,NULL),(16,'Bolsa de basura',100.00,'efectivo',NULL,NULL,25,'2025-12-18 21:54:42.036','2025-12-18 21:54:42.036','general',NULL,NULL),(17,'Benito',1400.00,'efectivo',NULL,'Paciente Oscar Gutierrez',25,'2025-12-19 18:48:09.087','2025-12-19 18:48:09.087','general',NULL,NULL),(18,'Pizza almuerzo',260.00,'efectivo',NULL,NULL,25,'2025-12-19 22:16:03.788','2025-12-19 22:16:03.788','general',NULL,NULL),(19,'Juli cuau y Desayuno ',500.00,'efectivo',NULL,'Desayuno Ali Yahir Sandy Jhonatan Cuau',25,'2025-12-20 00:08:18.005','2025-12-20 00:08:18.005','general',NULL,NULL),(20,'Arepas',245.00,'efectivo',NULL,'Alicia Sandy Jhonatan',25,'2025-12-20 17:07:21.367','2025-12-20 17:07:21.367','general',NULL,NULL),(21,'Dr. Yahir Semana',3686.00,'efectivo',NULL,'Semana 15/12 al 20/12',25,'2025-12-20 18:34:43.942','2025-12-20 18:34:43.942','general',NULL,NULL),(22,'Dra Sandy Osorio semana',2346.00,'efectivo',NULL,'Semana 15/12 al 20/12',25,'2025-12-20 18:57:49.778','2025-12-20 18:57:49.778','general',NULL,NULL),(23,'Dr Jorge Cuauhtli Semana',2288.00,'efectivo',NULL,'Semana 15/12 a 20/12',25,'2025-12-20 19:02:58.092','2025-12-20 19:02:58.092','general',NULL,NULL),(24,'Dr Jhonatan Semana',10.00,'efectivo',NULL,'Semana 15/12 a 20/12',25,'2025-12-20 19:06:58.650','2025-12-20 19:06:58.650','general',NULL,NULL),(25,'CAJA FUERTE',21000.00,'efectivo',NULL,NULL,25,'2025-12-22 15:12:48.125','2025-12-22 15:12:48.125','general',NULL,NULL),(26,'Papel traza',44.00,'efectivo',NULL,'Para esterilizar',25,'2025-12-22 17:22:53.449','2025-12-22 17:22:53.449','general',NULL,NULL),(27,'Desayuno',155.00,'efectivo',NULL,'Desayuno Alicia Yahir',25,'2025-12-22 17:23:39.600','2025-12-22 17:23:39.600','general',NULL,NULL),(28,'Prestamo Daniela',350.00,'efectivo',NULL,'Brownie',25,'2025-12-22 22:53:56.245','2025-12-22 22:53:56.245','general',NULL,NULL),(29,'Hugo Cuau',100.00,'efectivo',NULL,NULL,25,'2025-12-22 22:54:09.374','2025-12-22 22:54:09.374','general',NULL,NULL),(30,'Galletas servicio',40.00,'efectivo',NULL,NULL,25,'2025-12-23 00:13:35.055','2025-12-23 00:13:35.055','general',NULL,NULL),(31,'Cafe',384.00,'efectivo',NULL,'Caf?? Ali Yahir Sandy Jhonatan',25,'2025-12-23 22:00:05.502','2025-12-23 22:00:05.502','general',NULL,NULL),(32,'Delivery Azamar',35.00,'efectivo',NULL,'Trabajo Miguel Dzul/Luis Chavez',25,'2025-12-23 23:37:10.052','2025-12-23 23:37:10.052','general',NULL,NULL),(33,'Farmacia ',117.00,'efectivo',NULL,'Alin (dexametasona)',25,'2025-12-24 16:05:09.156','2025-12-24 16:05:09.156','general',NULL,NULL),(34,'Desayuno',270.00,'efectivo',NULL,'Desayuno Ali Juli Yahir',25,'2025-12-24 17:51:06.319','2025-12-24 17:51:06.319','general',NULL,NULL),(35,'Galleta Cuau',25.00,'efectivo',NULL,NULL,25,'2025-12-26 18:07:55.504','2025-12-26 18:07:55.504','general',NULL,NULL),(36,'Agua',42.00,'efectivo',NULL,NULL,25,'2025-12-26 18:27:17.244','2025-12-26 18:27:17.244','general',NULL,NULL),(37,'Carlos ',400.00,'efectivo',NULL,'Lavado/aguinaldo',25,'2025-12-26 18:41:05.966','2025-12-26 18:41:05.966','general',NULL,NULL),(38,'Cepillos Curaprox',400.00,'efectivo',NULL,'Pagado en BBVA',25,'2025-12-26 22:38:36.610','2025-12-26 22:38:36.610','general',NULL,NULL),(39,'Desayuno/Juli ',465.00,'efectivo',NULL,'Desayuno Alicia Yahir Cuau Jhonatan\nLimpieza Juli ',25,'2025-12-27 00:16:14.791','2025-12-27 00:16:14.791','general',NULL,NULL),(40,'Benito Px Guillermo',500.00,'efectivo',NULL,'Px Guillermo Reta',25,'2025-12-27 15:09:17.796','2025-12-27 15:09:17.796','general',NULL,NULL),(41,'Tecnico Angel',1200.00,'efectivo',NULL,'Mantenimiento aire recepcion',25,'2025-12-27 16:04:19.887','2025-12-27 16:04:19.887','general',NULL,NULL),(42,'Desayuno',330.00,'efectivo',NULL,'Arepas Ali Cuau Sandy Jhonatan',25,'2025-12-27 16:12:59.235','2025-12-27 16:12:59.235','general',NULL,NULL),(43,'Tacos Yahir',120.00,'efectivo',NULL,NULL,25,'2025-12-27 16:39:27.513','2025-12-27 16:39:27.513','general',NULL,NULL),(44,'Sandy semana',315.00,'efectivo',NULL,'Pago semana 22/12 al 27/12',25,'2025-12-27 18:12:22.514','2025-12-27 18:12:22.514','general',NULL,NULL),(45,'Yahir Semana',939.00,'efectivo',NULL,'Semana 22/12 al 27/12',25,'2025-12-27 18:36:26.822','2025-12-27 18:36:26.822','general',NULL,NULL),(46,'Cuau Semana',1265.00,'efectivo',NULL,'Semana 22/12 al 27/12',25,'2025-12-27 19:01:09.819','2025-12-27 19:01:09.819','general',NULL,NULL),(47,'Pago benito ',200.00,'efectivo',NULL,'Paciente Guillermo Reta',25,'2025-12-29 17:15:44.233','2025-12-29 17:15:44.233','general',NULL,NULL),(48,'Jardinero',200.00,'efectivo',NULL,NULL,25,'2025-12-29 18:38:41.127','2025-12-29 18:38:41.127','general',NULL,NULL),(49,'Envio Reytek',422.00,'efectivo',NULL,'Paciente Natalia Lomas',25,'2025-12-29 18:39:03.460','2025-12-29 18:39:03.460','general',NULL,NULL),(50,'Envio DHL',1236.00,'efectivo',NULL,'Envio de guarda paciente Arlene Laurich',25,'2025-12-29 18:39:39.356','2025-12-29 18:39:39.356','general',NULL,NULL),(51,'Cloro, pa??o de entrada',109.00,'efectivo',NULL,NULL,25,'2025-12-29 21:33:26.435','2025-12-29 21:33:26.435','general',NULL,NULL),(52,'Pago a laboratorio - Benito - Paciente: Guillermo Reta',700.00,'transferencia','BBVA',NULL,25,'2025-12-29 23:13:31.042','2025-12-29 23:13:31.042','laboratorio',2,54),(53,'Alicia Nomina',4118.00,'efectivo',NULL,NULL,25,'2025-12-31 15:53:37.131','2025-12-31 15:53:37.131','general',NULL,NULL),(54,'Sandy Nomina',3800.00,'efectivo',NULL,NULL,25,'2025-12-31 16:06:21.710','2025-12-31 16:06:21.710','general',NULL,NULL),(55,'Jhonatan Nomina',3614.00,'efectivo',NULL,NULL,25,'2025-12-31 16:06:38.051','2025-12-31 16:06:38.051','general',NULL,NULL),(56,'Juli Nomina',2085.00,'efectivo',NULL,NULL,25,'2025-12-31 16:06:49.149','2025-12-31 16:06:49.149','general',NULL,NULL),(57,'CAPA',287.00,'efectivo',NULL,NULL,25,'2025-12-31 17:59:47.054','2025-12-31 17:59:47.054','general',NULL,NULL),(58,'Bateria 9V',160.00,'efectivo',NULL,NULL,25,'2025-12-31 17:59:59.273','2025-12-31 17:59:59.273','general',NULL,NULL),(59,'Gusanos Cuau',165.00,'efectivo',NULL,NULL,25,'2026-01-13 22:35:12.229','2026-01-13 22:35:12.229','general',NULL,NULL),(60,'Jardinero Cuau',700.00,'efectivo',NULL,NULL,25,'2026-01-14 16:18:43.157','2026-01-14 16:18:43.157','general',NULL,NULL),(61,'Duplicado',680.00,'tarjeta','Mercado Pago','Registre duplicado el pago',25,'2026-01-15 00:19:05.446','2026-01-15 00:19:05.446','general',NULL,NULL),(62,'Desayuno 14/1/26',260.00,'efectivo',NULL,'Desayuno Ali Yahir Cuau Sandy',25,'2026-01-15 22:20:33.488','2026-01-15 22:20:33.488','general',NULL,NULL),(63,'Desayuno',255.00,'efectivo',NULL,'Desayuno Sandy Alicia Zafiro de mar Yahir',25,'2026-01-15 22:21:09.171','2026-01-15 22:21:09.171','general',NULL,NULL),(64,'Almuerzo d Juli',110.00,'efectivo',NULL,NULL,25,'2026-01-15 22:28:42.580','2026-01-15 22:28:42.580','general',NULL,NULL),(65,'Zafiro Nomina',2850.00,'efectivo',NULL,'Quincena enero',25,'2026-01-15 23:43:31.144','2026-01-15 23:43:31.144','general',NULL,NULL),(66,'Julissa Nomina',1536.00,'efectivo',NULL,'Quincena Enero',25,'2026-01-15 23:52:49.278','2026-01-15 23:52:49.278','general',NULL,NULL),(67,'Sandy Nomina',2244.00,'efectivo',NULL,'Quincena Enero',25,'2026-01-16 00:19:43.732','2026-01-16 00:19:43.732','general',NULL,NULL),(68,'Jhonatan Nomina',2322.00,'efectivo',NULL,'Quincena Enero',25,'2026-01-16 00:22:56.458','2026-01-16 00:22:56.458','general',NULL,NULL),(69,'Alicia Nomina',5037.00,'efectivo',NULL,'Quincena enero ',25,'2026-01-16 00:28:13.097','2026-01-16 00:28:13.097','general',NULL,NULL),(70,'Publicidad Nomina',1750.00,'efectivo',NULL,'1 pago enero',25,'2026-01-16 00:30:24.675','2026-01-16 00:30:24.675','general',NULL,NULL),(71,'Envios DHL',1000.00,'efectivo',NULL,'Envio ivoclar e reytek',25,'2026-01-16 17:54:51.191','2026-01-16 17:54:51.191','general',NULL,NULL),(72,'Carlos ',250.00,'efectivo',NULL,'Lavado coche',25,'2026-01-16 23:23:13.236','2026-01-16 23:23:13.236','general',NULL,NULL),(73,'Juli Cuau',345.00,'efectivo',NULL,'Limpieza casa y desayuno',25,'2026-01-17 00:45:27.914','2026-01-17 00:45:27.914','general',NULL,NULL),(74,'Desayuno Juli',75.00,'efectivo',NULL,'Desayuno Jhonatan y sandy',25,'2026-01-17 00:45:52.109','2026-01-17 00:45:52.109','general',NULL,NULL),(75,'Jhonatan Nomina ',715.00,'efectivo',NULL,'Pago de ayer pague con nuevo sueldo y los 1ros 6 dias de la quincena trabajaron turno completo',25,'2026-01-17 00:51:35.338','2026-01-17 00:51:35.338','general',NULL,NULL),(76,'Sandy Nomina',714.00,'efectivo',NULL,'Pago de ayer pague con nuevo sueldo y los 1ros 6 dias de la quincena trabajaron turno completo',25,'2026-01-17 00:51:57.410','2026-01-17 00:51:57.410','general',NULL,NULL),(77,'Yahir semana',2550.00,'efectivo',NULL,'Semana 12/1 17/1',25,'2026-01-17 17:45:04.063','2026-01-17 17:45:04.063','general',NULL,NULL),(78,'Cuau Semana ',1600.00,'efectivo',NULL,'Semana 12/1 17/01',25,'2026-01-17 17:50:46.436','2026-01-17 17:50:46.436','general',NULL,NULL),(79,'Jhonatan Semana',1155.00,'efectivo',NULL,'Semana 12/1 17/1',25,'2026-01-17 18:38:34.844','2026-01-17 18:38:34.844','general',NULL,NULL),(80,'Desayuno ',290.00,'efectivo',NULL,'Desayuno Alicia Yahir Sandy',25,'2026-01-19 18:11:47.442','2026-01-19 18:11:47.442','general',NULL,NULL),(81,'Agua',88.00,'efectivo',NULL,NULL,25,'2026-01-20 01:09:54.695','2026-01-20 01:09:54.695','general',NULL,NULL),(82,'Desayuno',285.00,'efectivo',NULL,'Desayuno Yahir Jhonatan Sandy',25,'2026-01-20 17:13:47.209','2026-01-20 17:13:47.209','general',NULL,NULL),(83,'Comida Do??a Juli',115.00,'efectivo',NULL,NULL,25,'2026-01-20 22:09:38.867','2026-01-20 22:09:38.867','general',NULL,NULL),(84,'Pan masa madre',180.00,'efectivo',NULL,'Pan Cuau',25,'2026-01-20 23:51:45.805','2026-01-20 23:51:45.805','general',NULL,NULL),(85,'Leche',35.00,'efectivo',NULL,'Sandy leche',25,'2026-01-21 18:02:53.988','2026-01-21 18:02:53.988','general',NULL,NULL),(86,'Dep Uniforme',140.00,'efectivo',NULL,'Bordado uniforme Zafiro',25,'2026-01-21 18:30:12.357','2026-01-21 18:30:12.357','general',NULL,NULL),(87,'Tienda',50.00,'efectivo',NULL,'Cuau',25,'2026-01-22 00:42:50.812','2026-01-22 00:42:50.812','general',NULL,NULL),(88,'Sra Planchar',350.00,'efectivo',NULL,'Cuau',25,'2026-01-22 00:43:07.451','2026-01-22 00:43:07.451','general',NULL,NULL),(89,'Huevos',150.00,'efectivo',NULL,'Huevos cuau',25,'2026-01-22 00:43:22.031','2026-01-22 00:43:22.031','general',NULL,NULL),(90,'Agua',44.00,'efectivo',NULL,NULL,25,'2026-01-22 18:13:31.248','2026-01-22 18:13:31.248','general',NULL,NULL),(91,'Bolsa negra basura',30.00,'efectivo',NULL,NULL,25,'2026-01-22 18:13:52.282','2026-01-22 18:13:52.282','general',NULL,NULL),(92,'Bolsas grandes/Tienda',230.00,'efectivo',NULL,'Tienda Alicia/basura',25,'2026-01-22 23:27:48.557','2026-01-22 23:27:48.557','general',NULL,NULL),(93,'Curaprox',650.00,'efectivo',NULL,'Cepillo y pasta dental (Maria Osorio)',25,'2026-01-23 00:30:37.707','2026-01-23 00:30:37.707','general',NULL,NULL),(94,'Desayuno',525.00,'efectivo',NULL,'Desayuno Cuau Alicia Sandy Jhonatan Luz Yahir',25,'2026-01-24 18:17:50.049','2026-01-24 18:17:50.049','general',NULL,NULL),(95,'Juli',300.00,'efectivo',NULL,'Limpieza casa cuau',25,'2026-01-24 18:18:08.000','2026-01-24 18:18:08.000','general',NULL,NULL),(96,'Sandy Semana',331.00,'efectivo',NULL,'Semana 19/1 al 24/1',25,'2026-01-24 18:29:20.299','2026-01-24 18:29:20.299','general',NULL,NULL),(97,'Yahir Semana',4177.00,'efectivo',NULL,'Semana 19/1 al 24/1',25,'2026-01-24 18:50:47.110','2026-01-24 18:50:47.110','general',NULL,NULL),(98,'Cambio Dolar',340.00,'efectivo',NULL,NULL,25,'2026-01-24 19:25:47.239','2026-01-24 19:25:47.239','general',NULL,NULL),(99,'Dra. Luz',2800.00,'efectivo',NULL,NULL,25,'2026-01-24 21:19:41.076','2026-01-24 21:19:41.076','general',NULL,NULL),(100,'Hugo',500.00,'efectivo',NULL,'Pago 400 pero no tenia cambio 100 parte de pago',25,'2026-01-24 21:20:11.179','2026-01-24 21:20:11.179','general',NULL,NULL),(101,'Gusanos Cuau',240.00,'efectivo',NULL,NULL,25,'2026-01-24 21:20:22.174','2026-01-24 21:20:22.174','general',NULL,NULL),(102,'Taxis Dra',100.00,'efectivo',NULL,NULL,25,'2026-01-24 21:23:22.411','2026-01-24 21:23:22.411','general',NULL,NULL);
/*!40000 ALTER TABLE `gastos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `horarios_doctores`
--

DROP TABLE IF EXISTS `horarios_doctores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `horarios_doctores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doctorId` int(11) NOT NULL,
  `diaSemana` int(11) NOT NULL,
  `horaInicio` varchar(191) NOT NULL,
  `horaFin` varchar(191) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `horarios_doctores_doctorId_fkey` (`doctorId`),
  CONSTRAINT `horarios_doctores_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `horarios_doctores`
--

LOCK TABLES `horarios_doctores` WRITE;
/*!40000 ALTER TABLE `horarios_doctores` DISABLE KEYS */;
INSERT INTO `horarios_doctores` VALUES (136,30,1,'09:00','18:00',1),(137,30,2,'09:00','18:00',1),(138,30,3,'09:00','18:00',1),(139,30,4,'09:00','18:00',1),(140,30,5,'09:00','18:00',1),(141,28,1,'09:00','18:00',1),(142,28,2,'09:00','18:00',1),(143,28,3,'09:00','18:00',1),(144,28,4,'09:00','18:00',1),(145,28,5,'09:00','18:00',1),(146,29,1,'09:00','18:00',1),(147,29,2,'09:00','18:00',1),(148,29,3,'09:00','18:00',1),(149,29,4,'09:00','18:00',1),(150,29,5,'09:00','18:00',1),(151,31,1,'09:00','18:00',1),(152,31,2,'09:00','18:00',1),(153,31,3,'09:00','18:00',1),(154,31,4,'09:00','18:00',1),(155,31,5,'09:00','18:00',1),(156,32,1,'09:00','18:00',1),(157,32,2,'09:00','18:00',1),(158,32,3,'09:00','18:00',1),(159,32,4,'09:00','18:00',1),(160,32,5,'09:00','18:00',1),(161,33,1,'09:00','18:00',1),(162,33,2,'09:00','18:00',1),(163,33,3,'09:00','18:00',1),(164,33,4,'09:00','18:00',1),(165,33,5,'09:00','18:00',1),(166,34,1,'09:00','18:00',1),(167,34,2,'09:00','18:00',1),(168,34,3,'09:00','18:00',1),(169,34,4,'09:00','18:00',1),(170,34,5,'09:00','18:00',1),(171,35,1,'09:00','18:00',1),(172,35,2,'09:00','18:00',1),(173,35,3,'09:00','18:00',1),(174,35,4,'09:00','18:00',1),(175,35,5,'09:00','18:00',1),(176,36,1,'09:00','18:00',1),(177,36,2,'09:00','18:00',1),(178,36,3,'09:00','18:00',1),(179,36,4,'09:00','18:00',1),(180,36,5,'09:00','18:00',1);
/*!40000 ALTER TABLE `horarios_doctores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `laboratorios`
--

DROP TABLE IF EXISTS `laboratorios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `laboratorios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `contacto` varchar(191) DEFAULT NULL,
  `telefono` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratorios`
--

LOCK TABLES `laboratorios` WRITE;
/*!40000 ALTER TABLE `laboratorios` DISABLE KEYS */;
INSERT INTO `laboratorios` VALUES (1,'Guillermo Reta','Guillermo Reta','9871187411',0,'2025-12-29 17:14:45.839','2025-12-29 17:15:03.248'),(2,'Benito','Benito','9871161846',1,'2025-12-29 23:09:23.868','2025-12-29 23:09:23.868');
/*!40000 ALTER TABLE `laboratorios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materiales`
--

DROP TABLE IF EXISTS `materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `materiales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `costo` decimal(10,2) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stockMinimo` int(11) NOT NULL DEFAULT 5,
  `fechaCaducidad` datetime(3) DEFAULT NULL,
  `categoria` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materiales`
--

LOCK TABLES `materiales` WRITE;
/*!40000 ALTER TABLE `materiales` DISABLE KEYS */;
INSERT INTO `materiales` VALUES (1,'Campos desechables','',NULL,0,10,NULL,'Desechables',1,'2026-01-07 15:53:09.663','2026-01-07 15:53:09.663');
/*!40000 ALTER TABLE `materiales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modulos`
--

DROP TABLE IF EXISTS `modulos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modulos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `descripcion` varchar(191) DEFAULT NULL,
  `ruta` varchar(191) DEFAULT NULL,
  `icono` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `modulos_nombre_key` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modulos`
--

LOCK TABLES `modulos` WRITE;
/*!40000 ALTER TABLE `modulos` DISABLE KEYS */;
INSERT INTO `modulos` VALUES (1,'Punto de Venta','M??dulo para realizar ventas y cobros','/pos','fas fa-cash-register',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(2,'Pacientes','Gesti??n de pacientes','/pacientes','fas fa-user-injured',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(3,'Doctores','Gesti??n de doctores','/doctores','fas fa-user-md',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(4,'Historial Ventas','Ver historial de ventas realizadas','/pos/ventas','fas fa-history',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(5,'Cortes de Caja','Realizar y ver cortes de caja','/cortes','fas fa-cut',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(6,'Gastos','Registrar y gestionar gastos','/gastos','fas fa-money-bill-wave',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000'),(7,'Configuraci??n','Configuraci??n del sistema','/configuracion','fas fa-cog',1,'2025-12-20 19:18:34.000','2025-12-20 19:18:34.000');
/*!40000 ALTER TABLE `modulos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pacientes`
--

DROP TABLE IF EXISTS `pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pacientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `apellido` varchar(191) NOT NULL,
  `fechaNacimiento` datetime(3) DEFAULT NULL,
  `genero` varchar(191) DEFAULT NULL,
  `telefono` varchar(191) DEFAULT NULL,
  `email` varchar(191) DEFAULT NULL,
  `direccion` varchar(191) DEFAULT NULL,
  `ocupacion` varchar(191) DEFAULT NULL,
  `contactoEmergencia` varchar(191) DEFAULT NULL,
  `telefonoEmergencia` varchar(191) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pacientes`
--

LOCK TABLES `pacientes` WRITE;
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
INSERT INTO `pacientes` VALUES (45,'Carmen','Flores Morales','1995-05-30 00:00:00.000','femenino','555-1004','carmen.flores@email.com',NULL,NULL,NULL,NULL,NULL,1,'2025-12-16 22:24:43.207','2025-12-16 22:24:43.207'),(46,'Pedro','Ram??rez Cruz','2010-09-12 00:00:00.000','masculino','555-1005',NULL,NULL,NULL,'Ana Cruz (Madre)','555-1006',NULL,1,'2025-12-16 22:24:43.207','2025-12-16 22:24:43.207'),(47,'Laura','Mendoza R??os','1990-07-22 00:00:00.000','femenino','555-1002','laura.mendoza@email.com','Calle Roble 456, Col. Jardines',NULL,NULL,NULL,NULL,1,'2025-12-16 22:24:43.207','2025-12-16 22:24:43.207'),(48,'Roberto','S??nchez Luna','1985-03-15 00:00:00.000','masculino','555-1001','roberto.sanchez@email.com','Av. Principal 123, Col. Centro',NULL,NULL,NULL,NULL,1,'2025-12-16 22:24:43.208','2025-12-16 22:24:43.208'),(49,'Miguel','Torres Vega','1978-11-08 00:00:00.000','masculino','555-1003','miguel.torres@email.com','Blvd. Las Palmas 789',NULL,NULL,NULL,NULL,1,'2025-12-16 22:24:43.207','2025-12-16 22:24:43.207'),(50,'Maria ','Coral',NULL,'femenino','9878727773',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-17 22:10:05.172','2025-12-17 22:10:05.172'),(51,'Yvan','Henaine','1986-02-08 00:00:00.000','masculino','9875640275',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-17 22:29:18.145','2025-12-17 22:29:18.145'),(52,'Bania ','Salomon','1977-11-09 00:00:00.000','femenino','9625109122',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-17 23:48:13.724','2025-12-17 23:48:13.724'),(53,'Elia ','Martin',NULL,'femenino','9871017247',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-17 23:54:27.444','2025-12-17 23:54:27.444'),(54,'Guillermo','Reta','1980-12-08 00:00:00.000','masculino','9871187411',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 00:38:34.702','2025-12-18 00:38:34.702'),(55,'Iliana ','Garcia',NULL,'femenino',' 9878711644',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 01:00:54.104','2025-12-18 01:00:54.104'),(56,'Sathya','Caraco','1994-04-12 00:00:00.000','femenino','9843131730',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 15:52:43.497','2025-12-18 15:52:43.497'),(57,'Tomas ','Rivero','1954-12-21 00:00:00.000','masculino','9871059922',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 18:11:16.659','2025-12-18 18:11:16.659'),(58,'Jocelyn','Chan','2000-01-02 00:00:00.000','femenino','9875645024',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 18:12:55.598','2025-12-18 18:12:55.598'),(59,'Mauricio ','torres','1900-07-16 00:00:00.000','masculino','9871123106',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 22:06:21.041','2025-12-18 22:06:21.041'),(60,'Marloes ','Slagboom','1982-02-11 00:00:00.000','femenino','9878762021',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-18 23:20:00.463','2025-12-18 23:20:07.454'),(61,'Ana ','Orozco',NULL,'femenino','6461851888',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 01:02:32.778','2025-12-19 01:02:32.778'),(62,'Dair','Pinto','1992-03-14 00:00:00.000','masculino','9871121656',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 17:20:07.704','2025-12-19 17:20:07.704'),(63,'Carolina','Vargas','1982-12-14 00:00:00.000','femenino','8326335914',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 18:39:37.706','2025-12-19 18:39:37.706'),(64,'Erick','Segura','1982-08-25 00:00:00.000','masculino','9982425353',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 18:48:55.621','2025-12-19 18:48:55.621'),(65,'Rosendo ','Garc??a',NULL,'masculino','9871031184',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 22:10:06.572','2025-12-19 22:10:06.572'),(66,'Jenna','Thomson','1982-08-10 00:00:00.000','femenino','18456161090',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 22:11:09.675','2025-12-19 22:11:09.675'),(67,'Zajhia ','Achach','2005-10-06 00:00:00.000','femenino','9871184292',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-19 23:30:16.998','2025-12-19 23:30:16.998'),(68,'Jade ','Maas','2017-10-14 00:00:00.000','femenino','9871137123',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-20 00:00:31.676','2025-12-20 00:00:31.676'),(69,'Joanie ','Maltais',NULL,'femenino','9871165380',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-20 17:04:50.759','2025-12-20 17:04:50.759'),(70,'Evan ','Niculescu',NULL,'masculino','9871165380',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-20 17:05:07.881','2025-12-20 17:05:07.881'),(71,'Xiomara ','Acu??a','1995-08-12 00:00:00.000','femenino','9987659885',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-20 17:26:22.309','2025-12-20 17:26:22.309'),(72,'Regina','Mena',NULL,'femenino','9871161326',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-20 18:27:27.520','2025-12-20 18:27:27.520'),(73,'Claudia ','Barrera','1974-11-12 00:00:00.000','femenino','9875641347',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-22 18:38:05.754','2025-12-22 18:38:05.754'),(74,'Ricardo','Monforte',NULL,'masculino','555236652',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-22 22:52:43.318','2025-12-22 22:52:43.318'),(75,'Luigy','Simantor','1962-03-02 00:00:00.000','masculino','9871638669',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-22 23:28:45.974','2025-12-22 23:28:45.974'),(76,'Jose','Garcia',NULL,'masculino','9871631824',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 00:12:39.544','2025-12-23 00:12:39.544'),(77,'Adrien','Gaillard','1982-07-29 00:00:00.000','masculino','9878716908',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 00:32:50.743','2025-12-23 00:32:50.743'),(78,'Jenna ','Turner','1979-02-08 00:00:00.000','femenino','+12088609629',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 22:02:49.008','2025-12-23 22:02:49.008'),(79,'Laura ','De la fuente',NULL,'femenino','21455563',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 22:53:35.006','2025-12-23 22:53:35.006'),(80,'Maricela ','Be ',NULL,'femenino','9878721189',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 22:55:42.238','2025-12-23 22:55:42.238'),(81,'Lucero','Manrique','2002-02-08 00:00:00.000','femenino','9871031326',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-23 23:36:14.192','2025-12-23 23:36:14.192'),(82,'Jose ','Cervantes',NULL,'masculino','9878721187',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-24 00:07:33.644','2025-12-24 00:07:33.644'),(83,'Johan','Gonzalez','1900-01-01 00:00:00.000','masculino','98787254',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-24 18:04:38.802','2025-12-24 18:04:38.802'),(84,'Raymond ','Alaouze',NULL,'masculino','51632555',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-26 17:36:39.858','2025-12-26 17:36:39.858'),(85,'Marilidia','Angulo',NULL,'femenino','9871135285',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-26 18:06:28.032','2025-12-26 18:06:28.032'),(86,'Miguel','Dzul',NULL,'masculino','56529629',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-26 18:21:07.896','2025-12-26 18:21:07.896'),(87,'Fernando ','Changoy',NULL,'masculino','9878721159',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-26 22:36:37.398','2025-12-26 22:36:37.398'),(88,'Gabriel ','Remes',NULL,'masculino','9981098484',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-27 16:05:55.458','2025-12-27 16:05:55.458'),(89,'Leo','Lev',NULL,'masculino','+14043166299',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-29 22:56:18.085','2025-12-29 22:56:18.085'),(90,'Hilda ','Estrella',NULL,'femenino','+14048249039',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-29 22:57:37.715','2025-12-29 22:57:37.715'),(91,'Carlos','Armendariz',NULL,'masculino','6278896912',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-29 23:05:11.253','2025-12-29 23:05:11.253'),(92,'Cliff','Shaw','1979-10-15 00:00:00.000','masculino','9878004067',NULL,NULL,NULL,NULL,NULL,NULL,1,'2025-12-30 16:20:24.764','2025-12-30 16:20:24.764'),(93,'Kenya','Zavala','1992-07-13 00:00:00.000','femenino','9991900061',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-14 16:51:34.096','2026-01-14 16:51:34.096'),(94,'Zaner','Oder','1994-01-30 00:00:00.000','masculino','9991900061',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-14 16:52:17.087','2026-01-14 16:52:17.087'),(95,'Mariana','Gomez',NULL,'femenino','889522216',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-14 17:55:45.539','2026-01-14 17:55:45.539'),(96,'Jaqueline','Jimenez',NULL,'femenino','9871071724',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-14 17:56:53.089','2026-01-14 17:56:53.089'),(97,'Luz','Garcia',NULL,'femenino','9875649834',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-14 18:19:31.252','2026-01-14 18:19:31.252'),(98,'Humberto ','Chim',NULL,'masculino','9875874856',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-15 00:10:34.991','2026-01-15 00:10:34.991'),(99,'Damian','Guillermo',NULL,'masculino','9875874856',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-15 00:15:07.387','2026-01-15 00:15:07.387'),(100,'Faridy','Kuyoc',NULL,'femenino','494646684',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-15 00:53:52.299','2026-01-15 00:53:52.299'),(101,'Irma','Cantarell',NULL,'femenino','9878713177',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-15 22:12:43.082','2026-01-15 22:12:43.082'),(102,'Leslie ','De la cruz',NULL,'femenino','9871154810',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-15 22:13:19.520','2026-01-15 22:13:19.520'),(103,'Cecilia ','Canul',NULL,'femenino','9871411928',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 00:01:38.040','2026-01-16 00:01:38.040'),(104,'Selene','Solis',NULL,'femenino','9875512',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 00:15:26.052','2026-01-16 00:15:26.052'),(105,'Ricardo ','Cetina',NULL,'masculino','987526',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 00:15:49.725','2026-01-16 00:15:49.725'),(106,'Maxime','G',NULL,'masculino','15643526',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 00:37:25.657','2026-01-16 00:37:25.657'),(107,'Maricarmen','Novelo',NULL,'femenino','987546874',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 00:38:47.321','2026-01-16 00:38:47.321'),(108,'Brenda ','Noche',NULL,'femenino','987456874',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-16 17:54:10.560','2026-01-16 17:54:10.560'),(109,'Elder','Vivas',NULL,'masculino','9875423',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-17 00:43:00.820','2026-01-17 00:43:00.820'),(110,'Luis','Garcia',NULL,'masculino','98754862',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-17 00:43:41.425','2026-01-17 00:43:41.425'),(111,'Mario','Balam',NULL,'masculino','985236',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-17 00:44:04.578','2026-01-17 00:44:04.578'),(112,'Estefany ','Gamboa',NULL,'femenino','987 107 5210',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-19 17:20:46.478','2026-01-19 17:20:46.478'),(113,'Eli','Amuyal',NULL,'masculino','98754682',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-19 18:12:17.782','2026-01-19 18:12:17.782'),(114,'Zaidy','Torres',NULL,'femenino','9871008448',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-20 00:22:22.440','2026-01-20 00:22:22.440'),(115,'Anibal ','Miranda',NULL,'femenino','9871030245',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-20 00:25:31.146','2026-01-20 00:25:31.146'),(116,'Jade','Zafiro',NULL,'femenino','9878766580',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-20 00:26:26.451','2026-01-20 00:26:26.451'),(117,'Maria ','Gonzalez',NULL,'femenino','8898522',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-20 00:34:18.391','2026-01-20 00:34:18.391'),(118,'Boyd','Chin',NULL,'masculino','728623',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-20 17:12:18.771','2026-01-20 17:12:18.771'),(119,'Amado','Avila',NULL,'masculino','98754876',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-21 18:30:45.137','2026-01-21 18:30:45.137'),(120,'Sandra','Gala',NULL,'femenino','9875632145',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-21 18:31:00.401','2026-01-21 18:31:00.401'),(121,'Betnel','Kc',NULL,'femenino','988752',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-22 00:38:54.604','2026-01-22 00:38:54.604'),(122,'Ruben','Mendez',NULL,'masculino','987553',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-22 18:14:31.395','2026-01-22 18:14:31.395'),(123,'Magdalena','Rojas',NULL,'femenino','2221755738',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-22 21:55:56.462','2026-01-22 21:55:56.462'),(124,'Sofia ','Robles',NULL,'femenino','9875263',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-01-24 15:45:37.779','2026-01-24 15:45:37.779');
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagos_laboratorio`
--

DROP TABLE IF EXISTS `pagos_laboratorio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pagos_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `servicioLaboratorioId` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `metodoPago` varchar(191) NOT NULL DEFAULT 'efectivo',
  `banco` varchar(191) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pagos_laboratorio_servicioLaboratorioId_fkey` (`servicioLaboratorioId`),
  KEY `pagos_laboratorio_usuarioId_fkey` (`usuarioId`),
  CONSTRAINT `pagos_laboratorio_servicioLaboratorioId_fkey` FOREIGN KEY (`servicioLaboratorioId`) REFERENCES `servicios_laboratorio` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pagos_laboratorio_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagos_laboratorio`
--

LOCK TABLES `pagos_laboratorio` WRITE;
/*!40000 ALTER TABLE `pagos_laboratorio` DISABLE KEYS */;
/*!40000 ALTER TABLE `pagos_laboratorio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permisos_usuarios`
--

DROP TABLE IF EXISTS `permisos_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permisos_usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuarioId` int(11) NOT NULL,
  `moduloId` int(11) NOT NULL,
  `acceso` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permisos_usuarios_usuarioId_moduloId_key` (`usuarioId`,`moduloId`),
  KEY `permisos_usuarios_moduloId_fkey` (`moduloId`),
  CONSTRAINT `permisos_usuarios_moduloId_fkey` FOREIGN KEY (`moduloId`) REFERENCES `modulos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `permisos_usuarios_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos_usuarios`
--

LOCK TABLES `permisos_usuarios` WRITE;
/*!40000 ALTER TABLE `permisos_usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `permisos_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prestamos`
--

DROP TABLE IF EXISTS `prestamos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prestamos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doctorId` int(11) NOT NULL,
  `conceptoId` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `estatus` varchar(50) DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) DEFAULT current_timestamp(3) ON UPDATE current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `doctorId` (`doctorId`),
  KEY `conceptoId` (`conceptoId`),
  KEY `usuarioId` (`usuarioId`),
  CONSTRAINT `prestamos_ibfk_1` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`),
  CONSTRAINT `prestamos_ibfk_2` FOREIGN KEY (`conceptoId`) REFERENCES `conceptos_prestamos` (`id`),
  CONSTRAINT `prestamos_ibfk_3` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prestamos`
--

LOCK TABLES `prestamos` WRITE;
/*!40000 ALTER TABLE `prestamos` DISABLE KEYS */;
INSERT INTO `prestamos` VALUES (1,34,1,1000.00,'pagado',NULL,25,'2026-01-25 17:40:54.670','2026-01-25 17:41:06.665');
/*!40000 ALTER TABLE `prestamos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `costo` decimal(10,2) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stockMinimo` int(11) NOT NULL DEFAULT 5,
  `categoria` varchar(191) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  `fechaCaducidad` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (12,'Kit Limpieza Infantil','Kit con cepillo y pasta para ni??os',150.00,65.00,20,5,'Infantil',1,'2025-12-16 22:24:43.250','2025-12-16 22:24:43.250',NULL),(13,'Pasta Dental 100ml','Pasta dental con fl??or',65.00,28.00,40,10,'Higiene',1,'2025-12-16 22:24:43.250','2025-12-16 22:24:43.250',NULL),(14,'Hilo Dental 50m','Hilo dental encerado',55.00,22.00,30,8,'Higiene',1,'2025-12-16 22:24:43.250','2025-12-16 22:24:43.250',NULL),(15,'Cepillo Dental Adulto','Cepillo dental de cerdas suaves',200.00,200.00,45,10,'Higiene',1,'2025-12-16 22:24:43.250','2026-01-07 16:08:22.631',NULL),(16,'Enjuague Bucal 500ml','Enjuague bucal antibacterial',120.00,55.00,25,5,'Higiene',1,'2025-12-16 22:24:43.250','2025-12-16 22:24:43.250',NULL),(17,'Guantes CH negros',NULL,1.00,1.00,0,6,'Desechables',1,'2026-01-07 15:57:45.565','2026-01-07 15:57:45.565',NULL),(18,'Guantes CH rosa',NULL,1.00,1.00,0,4,'Desechables',1,'2026-01-07 15:58:34.351','2026-01-07 15:58:34.351',NULL),(19,'Guantes M negro',NULL,1.00,1.00,0,5,'Desechables',1,'2026-01-07 15:58:59.827','2026-01-07 15:58:59.827',NULL),(20,'Campos ',NULL,218.00,218.00,16,10,'Desechables ',1,'2026-01-07 15:59:30.378','2026-01-07 23:34:05.480',NULL),(21,'Eyectores',NULL,77.00,77.00,4,10,'Desechables',1,'2026-01-07 15:59:57.630','2026-01-19 17:52:23.017',NULL),(22,'Eyectores Quir??rgicos',NULL,1.00,1.00,5,4,'Desechables',1,'2026-01-07 16:00:32.369','2026-01-19 17:52:30.177',NULL),(23,'Red de Cabello Rosa',NULL,1.00,1.00,0,2,'Desechables',1,'2026-01-07 16:01:04.051','2026-01-07 16:01:04.051',NULL),(24,'Red de Cabello Negro ',NULL,1.00,1.00,0,3,'Desechables',1,'2026-01-07 16:01:50.142','2026-01-07 16:01:50.142',NULL),(25,'Red de Cabello Azul ',NULL,1.00,1.00,0,2,'Desechables',1,'2026-01-07 16:02:17.643','2026-01-07 16:02:17.643',NULL),(26,'Cubrebocas',NULL,1.00,1.00,0,4,'Desechables',1,'2026-01-07 16:02:48.230','2026-01-07 16:02:48.230',NULL),(27,'Gasas',NULL,1.00,1.00,1,20,'Desechables',1,'2026-01-07 16:03:12.557','2026-01-19 17:53:45.080',NULL),(28,'Torundas de Algod??n ',NULL,1.00,1.00,33,10,'Desechables',1,'2026-01-07 16:04:08.092','2026-01-19 18:03:43.379',NULL),(29,'Bolsas p/ Esterilizar MED 89x229 mm',NULL,108.19,1.00,5,10,'Desechables',1,'2026-01-07 16:05:35.286','2026-01-08 17:43:29.257',NULL),(30,'Bolsas p/ Esterilizar CH 57x100 mm',NULL,1.00,1.00,2,5,'Desechables',1,'2026-01-07 16:07:03.481','2026-01-07 23:33:37.029',NULL),(31,'Bolsas p/ Esterilizar GD 13.5x28.5 cm',NULL,1.00,1.00,1,3,'Desechables',1,'2026-01-07 16:07:45.969','2026-01-07 23:33:57.831',NULL),(32,'Cinta testigo',NULL,1.00,1.00,1,2,'Desechables',1,'2026-01-07 16:08:06.820','2026-01-19 17:51:40.219',NULL),(33,'Agujas Cortas',NULL,1.00,1.00,3,2,'Desechables',1,'2026-01-07 16:09:01.011','2026-01-19 17:48:44.443',NULL),(34,'Agujas Extracortas',NULL,1.00,1.00,4,2,'Desechables',1,'2026-01-07 16:09:26.122','2026-01-19 17:48:52.854',NULL),(35,'Agujas Largas',NULL,1.00,1.00,4,5,'Desechables',1,'2026-01-07 16:09:56.280','2026-01-19 17:49:06.707',NULL),(36,'Hoja Bistur?? 15C',NULL,1.00,1.00,1,1,'Desechables',1,'2026-01-07 16:10:27.624','2026-01-08 17:41:37.544',NULL),(37,'Hojas Bistur?? 15',NULL,1.00,1.00,1,1,'Desechables',1,'2026-01-07 16:10:55.217','2026-01-19 17:54:44.318',NULL),(38,'Hojas Bistur?? 12',NULL,1.00,1.00,1,1,'Desechables',1,'2026-01-07 16:11:34.648','2026-01-08 17:41:41.601',NULL),(39,'Suturas Nylon 4-0',NULL,1.00,1.00,8,5,'Desechables',1,'2026-01-07 16:12:00.958','2026-01-19 18:01:37.070',NULL),(40,'Sutura Nylon 6-0',NULL,1.00,1.00,0,1,'Desechables',1,'2026-01-07 16:12:24.487','2026-01-07 16:12:24.487',NULL),(41,'Sutura Vicryl 3-0',NULL,1.00,1.00,0,1,'Desechables',1,'2026-01-07 16:12:50.531','2026-01-07 16:12:50.531',NULL),(42,'Turboca??na 4%',NULL,779.71,1.00,9,6,'Anestesia',1,'2026-01-07 16:14:14.860','2026-01-19 18:03:55.484',NULL),(43,'Mepivaca??na c/epi 3%',NULL,1.00,1.00,0,6,'Anestesia',1,'2026-01-07 16:15:01.385','2026-01-19 17:56:18.721',NULL),(44,'Mepivaca??na s/epi 2%',NULL,1.00,1.00,0,4,'Anestesia',1,'2026-01-07 16:15:48.800','2026-01-19 17:56:25.733',NULL),(45,'Pasta Profil??ctica',NULL,1.00,1.00,0,2,'Limpieza',1,'2026-01-07 16:17:34.856','2026-01-19 17:58:32.458',NULL),(46,'Fl??or',NULL,1.00,1.00,2,2,'Limpieza',1,'2026-01-07 16:17:51.755','2026-01-19 17:52:53.927',NULL),(47,'Cepillos Profil??cticos',NULL,1.00,1.00,120,100,'Limpieza',1,'2026-01-07 16:18:29.247','2026-01-19 17:51:20.382',NULL),(48,'Bicarbonato',NULL,1.00,1.00,2,2,'Limpieza',1,'2026-01-07 16:18:48.391','2026-01-19 17:49:53.994',NULL),(49,'??cido Grabador Bisco Select HV ETCH JUMBO',NULL,1.00,1.00,1,1,'Resinas',1,'2026-01-07 16:20:40.386','2026-01-19 17:46:52.315',NULL),(50,'Adhesivo All Bond Universal',NULL,1.00,1.00,3,3,'Resinas',1,'2026-01-07 16:21:05.443','2026-01-19 17:47:41.896',NULL),(51,'Base Protectora Pulpar Theracal Lc',NULL,1.00,1.00,2,3,'Resinas',1,'2026-01-07 16:21:39.509','2026-01-19 17:49:42.967',NULL),(52,'Ion??mero de Vidrio T2 Equia Forte',NULL,1.00,1.00,3,20,'Resinas',1,'2026-01-07 16:22:12.938','2026-01-19 17:55:22.539',NULL),(53,'Resina Fluida (liner) Grandioso Heavy Flow',NULL,1.00,1.00,4,3,'Resinas',1,'2026-01-07 16:23:00.865','2026-01-19 18:00:19.644',NULL),(54,'Beautiful Flow Shofu',NULL,1.00,1.00,2,3,'Resinas',1,'2026-01-07 16:23:28.100','2026-01-19 18:01:01.133',NULL),(55,'Resina con Fibra de Vidrio EverX post',NULL,1.00,1.00,0,2,'Resinas',1,'2026-01-07 16:24:03.254','2026-01-07 16:24:03.254',NULL),(56,'Resina Coltene A1-B1',NULL,1.00,1.00,1,3,'Resinas',1,'2026-01-07 16:24:45.705','2026-01-19 17:59:46.815',NULL),(57,'Resina Coltene A2-B2',NULL,1.00,1.00,2,3,'Resinas',1,'2026-01-07 16:25:04.766','2026-01-19 17:59:53.112',NULL),(58,'Resina Coltene A3-B3',NULL,1.00,1.00,1,3,'Resinas',1,'2026-01-07 16:25:20.277','2026-01-19 18:00:03.736',NULL),(59,'Pulidores de Composite JIFFY',NULL,1.00,1.00,1,3,'Resinas',1,'2026-01-07 16:25:47.807','2026-01-19 17:59:28.821',NULL),(60,'Fresa p/ Brillo de Composite Astrobrush',NULL,1.00,1.00,0,3,'Resinas',0,'2026-01-07 16:26:37.139','2026-01-19 17:53:07.542',NULL),(61,'Papel Articular',NULL,1.00,1.00,1,2,'Resinas',1,'2026-01-07 16:27:15.551','2026-01-19 17:58:05.608',NULL),(62,'Tiras de Lija Amarillo AliExpress',NULL,1.00,1.00,1,2,'Resinas',1,'2026-01-07 16:27:38.342','2026-01-19 18:02:15.455',NULL),(63,'Banda Matriz',NULL,1.00,1.00,5,2,'Resinas',1,'2026-01-07 16:27:57.529','2026-01-19 17:49:28.526',NULL),(64,'Microbrush Delgado',NULL,79.70,1.00,5,3,'Resinas',1,'2026-01-07 16:28:14.085','2026-01-19 17:57:11.582',NULL),(65,'Papaina PCaries',NULL,1.00,1.00,0,3,'Resinas',1,'2026-01-07 16:29:48.344','2026-01-19 17:57:48.077',NULL),(66,'Cu??as',NULL,1.00,1.00,5,3,'Resinas',1,'2026-01-07 16:31:18.250','2026-01-19 17:51:51.122',NULL),(67,'Tefl??n ',NULL,1.00,1.00,0,3,'Resinas',0,'2026-01-07 16:31:36.033','2026-01-19 18:01:44.081',NULL),(68,'??cido Porcelana 4% Bisco Porcelain Etchant 4',NULL,1.00,1.00,1,1,'Cementaci??n Porcelana',1,'2026-01-07 16:32:50.913','2026-01-19 17:47:24.438',NULL),(69,'Silano Bisco ',NULL,1.00,1.00,0,1,'Cementaci??n Porcelana',1,'2026-01-07 16:33:17.756','2026-01-07 16:33:17.756',NULL),(70,'Cemento Resinoso Trasl??cido LC E cement Traslucido',NULL,1.00,1.00,0,2,'Cementaci??n Porcelana',1,'2026-01-07 16:34:13.766','2026-01-07 16:34:13.766',NULL),(71,'Cemento Resinoso Opaco Lc E cement Milky ',NULL,1.00,1.00,0,2,'Cementaci??n Porcelana',1,'2026-01-07 16:34:51.419','2026-01-07 16:34:51.419',NULL),(72,'Limpiador de Superficies Zir Clean',NULL,1.00,1.00,1,2,'Cementaci??n Zirconia',1,'2026-01-07 16:35:20.375','2026-01-19 17:55:48.969',NULL),(73,'Adhesivo Zirconia Z Prime',NULL,1.00,1.00,1,2,'Cementaci??n Zirconia ',1,'2026-01-07 16:35:48.344','2026-01-19 17:48:21.149',NULL),(74,'Cemento Dual Autoadhesivo Maxcem Elite Chroma',NULL,1.00,1.00,0,2,'Cementaci??n Zirconia',1,'2026-01-07 16:36:24.501','2026-01-19 17:50:45.145',NULL),(75,'Cemento Dual Autoadhesivo Maxcem Elite',NULL,1.00,1.00,0,2,'Cementaci??n Zirconia',1,'2026-01-07 16:36:57.105','2026-01-07 16:36:57.105',NULL),(76,'Cemento Dual Duolink',NULL,1.00,1.00,1,2,'Cementaci??n Zirconia ',1,'2026-01-07 16:37:26.189','2026-01-19 17:50:27.486',NULL),(77,'Gate Gliden #2',NULL,1.00,1.00,1,6,'Postes',1,'2026-01-07 16:37:54.357','2026-01-19 17:54:02.575',NULL),(78,'Kit Fresas Coltene ',NULL,1.00,1.00,1,1,'Postes',1,'2026-01-07 16:38:12.076','2026-01-19 17:55:32.801',NULL),(79,'Postes Amarillos ParaPost',NULL,1.00,1.00,6,3,'Postes',1,'2026-01-07 16:38:37.648','2026-01-19 17:58:41.135',NULL),(80,'Postes Rojos ParaPost',NULL,1.00,1.00,7,3,'Postes',1,'2026-01-07 16:39:07.962','2026-01-19 17:59:05.541',NULL),(81,'Postes Azules ParaPost',NULL,1.00,1.00,2,3,'Postes',1,'2026-01-07 16:39:24.779','2026-01-19 17:58:50.373',NULL),(82,'Postes Negros ParaPost',NULL,1.00,1.00,4,3,'Postes',1,'2026-01-07 16:39:39.868','2026-01-19 17:58:56.942',NULL),(83,'Paracore Coltene',NULL,3286.00,1.00,0,1,'Postes',1,'2026-01-07 16:40:20.510','2026-01-07 16:40:42.984',NULL),(84,'Silicona Heavy Body President/ Edge',NULL,630.39,1.00,2,2,'Impresi??n',1,'2026-01-07 16:41:33.939','2026-01-19 18:01:27.099',NULL),(85,'Silicona Regular Body President/ Edge',NULL,1.00,1.00,0,2,'Impresi??n',1,'2026-01-07 16:41:56.083','2026-01-07 16:41:56.083',NULL),(86,'Silicona Light Body President/ Edge',NULL,655.60,1.00,2,2,'Impresi??n',1,'2026-01-07 16:42:07.316','2026-01-08 17:44:38.653',NULL),(87,'Masilla Edge Labor Pesado ',NULL,1.00,1.00,0,1,'Impresi??n',1,'2026-01-07 16:43:40.294','2026-01-07 16:43:40.294',NULL),(88,'Masilla Edge Labor Ligero',NULL,1.00,1.00,0,1,'Impresi??n',1,'2026-01-07 16:44:01.596','2026-01-07 16:44:01.596',NULL),(89,'Alginato Neocolloid Zhermack',NULL,1.00,1.00,2,2,'Impresi??n',1,'2026-01-07 16:44:32.620','2026-01-07 23:29:21.450',NULL),(90,'Alginato Hydrogum 5 ',NULL,217.44,1.00,2,3,'Impresi??n',1,'2026-01-07 16:44:52.232','2026-01-08 17:42:36.619',NULL),(91,'Silicona Pesado President',NULL,1.00,1.00,0,1,'Impresi??n',1,'2026-01-07 16:45:28.688','2026-01-07 16:45:28.688',NULL),(92,'Hilo Retractor #000',NULL,1.00,1.00,0,2,'Impresi??n',1,'2026-01-07 16:45:56.815','2026-01-07 16:45:56.815',NULL),(93,'Hilo Retractor #00',NULL,1.00,1.00,0,2,'Impresi??n',1,'2026-01-07 16:46:27.578','2026-01-07 16:46:27.578',NULL),(94,'Hilo Retractor #0',NULL,1.00,1.00,0,2,'Impresi??n',1,'2026-01-07 16:46:43.786','2026-01-07 16:46:43.786',NULL),(95,'Limas #10 Dentsply',NULL,1.00,1.00,0,3,'Endodoncia ',1,'2026-01-07 16:48:23.899','2026-01-07 16:48:23.899',NULL),(96,'Limas #20 Dentsply',NULL,1.00,1.00,0,3,'Endodoncia',1,'2026-01-07 16:48:50.081','2026-01-07 16:48:50.081',NULL),(97,'Limas #15 Dentsply',NULL,1.00,1.00,0,3,'Endodoncia',1,'2026-01-07 16:49:05.026','2026-01-07 16:49:05.026',NULL),(98,'Manuales tipo Protaper Gris Azdent',NULL,1.00,1.00,0,10,'Endodoncia',1,'2026-01-07 16:50:55.858','2026-01-07 16:51:33.494',NULL),(99,'Headstrong Dentsply',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:51:22.582','2026-01-07 18:15:22.658',NULL),(100,'Retratamiento Rotatorios Azdent',NULL,1.00,1.00,0,5,'Endodoncia',1,'2026-01-07 16:52:09.798','2026-01-07 16:52:09.798',NULL),(101,'M3 Vitesa',NULL,1.00,1.00,4,7,'Endodoncia ',1,'2026-01-07 16:53:06.339','2026-01-07 23:37:08.799',NULL),(102,'Eflex Vitesa',NULL,1.00,1.00,3,3,'Endodoncia',1,'2026-01-07 16:53:27.309','2026-01-07 23:35:56.317',NULL),(103,'Cemento Resina Obturaci??n Alt Plus Dentsply',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:53:59.504','2026-01-07 16:53:59.504',NULL),(104,'Cemento Biocer??mico Dia-Root Lothus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:54:22.082','2026-01-07 16:54:22.082',NULL),(105,'Eucaliptine Farmacia del Ahorro',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:54:46.835','2026-01-07 16:54:46.835',NULL),(106,'Gutaperchas 25/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:55:31.437','2026-01-07 16:55:31.437',NULL),(107,'Gutaperchas 30/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:55:44.416','2026-01-07 16:55:44.416',NULL),(108,'Gutaperchas 40/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:55:57.551','2026-01-07 16:56:33.946',NULL),(109,'Gutaperchas 35/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:56:13.908','2026-01-07 16:56:13.908',NULL),(110,'Gutaperchas 25/0.6 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:56:58.047','2026-01-07 16:56:58.047',NULL),(111,'Puntas de Papel 25/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:57:35.451','2026-01-07 16:57:35.451',NULL),(112,'Puntas de Papel 30/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:57:47.871','2026-01-07 16:57:47.871',NULL),(113,'Puntas de Papel 35/0.4 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:58:06.980','2026-01-07 16:58:06.980',NULL),(114,'Puntas de Papel 25/0.6 Lotus',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:58:39.175','2026-01-07 16:58:39.175',NULL),(115,'EDTA 17% Zeyco',NULL,1.00,1.00,0,2,'Endodoncia',1,'2026-01-07 16:58:57.559','2026-01-07 16:58:57.559',NULL),(116,'MTA Angelous',NULL,1.00,1.00,0,1,'Endodoncia',1,'2026-01-07 16:59:12.833','2026-01-07 16:59:12.833',NULL),(117,'Pasta Dental Curaprox',NULL,450.00,450.00,0,7,'Curaprox',1,'2026-01-07 17:32:43.682','2026-01-07 17:32:43.682',NULL),(118,'Pasta Dental Curaprox Kids',NULL,350.00,350.00,0,7,'Curaprox',1,'2026-01-07 17:33:12.682','2026-01-07 17:33:12.682',NULL),(119,'Cepillo Dental 5460 UltraSoft',NULL,200.00,200.00,0,100,'Curaprox',1,'2026-01-07 17:34:02.379','2026-01-07 17:34:02.379',NULL),(120,'Cepillo Dental 1560 Soft',NULL,200.00,200.00,0,100,'Curaprox',1,'2026-01-07 17:34:43.263','2026-01-07 17:34:43.263',NULL),(121,'Cepillo Dental Kids ',NULL,200.00,200.00,0,50,'Curaprox',1,'2026-01-07 17:35:37.817','2026-01-07 17:35:37.817',NULL),(122,'Enjuague',NULL,400.00,400.00,0,10,'Curaprox',1,'2026-01-07 17:35:54.889','2026-01-07 17:35:54.889',NULL),(123,'Enjuague Orto',NULL,400.00,400.00,0,10,'Curaprox',1,'2026-01-07 17:36:15.035','2026-01-07 17:36:15.035',NULL),(124,'Cepillo Dental p/ Implantes',NULL,200.00,200.00,0,10,'Curaprox',1,'2026-01-07 17:36:55.213','2026-01-07 17:36:55.213',NULL),(125,'Diques',NULL,1.00,1.00,4,4,'Resinas',1,'2026-01-07 17:38:01.284','2026-01-07 23:35:38.971',NULL),(126,'Cepillo Dental Orto ',NULL,200.00,200.00,0,10,'Curaprox',1,'2026-01-07 17:38:57.713','2026-01-07 17:38:57.713',NULL),(127,'Cera Orto',NULL,50.00,50.00,0,20,'Curaprox',1,'2026-01-07 17:39:12.761','2026-01-07 17:39:12.761',NULL),(128,'Kit Viajero',NULL,450.00,450.00,0,5,'Curaprox',1,'2026-01-07 17:39:29.503','2026-01-07 17:39:29.503',NULL),(129,'Caja Madera Ni??o/Ni??a ',NULL,350.00,350.00,0,2,'Curaprox',1,'2026-01-07 17:40:56.396','2026-01-07 17:40:56.396',NULL),(130,'Cinta Tefl??n',NULL,1.00,1.00,9,6,'Resinas',1,'2026-01-07 18:06:31.569','2026-01-19 17:51:34.678',NULL),(131,'Satin Hemostatico Absorbible',NULL,1.00,1.00,11,5,'Cx',1,'2026-01-07 23:38:50.794','2026-01-07 23:38:50.794',NULL),(132,'Microbrush Grueso',NULL,1.00,1.00,5,3,'Resinas',1,'2026-01-19 17:57:34.998','2026-01-19 17:57:34.998',NULL),(133,'Tiras de Lija Azul AliExpress',NULL,1.00,1.00,1,2,'Resinas',1,'2026-01-19 18:02:41.801','2026-01-19 18:03:26.416',NULL),(134,'Tiras de Lija Morado/Rosa AliExpress',NULL,1.00,1.00,2,2,'Resinas',1,'2026-01-19 18:03:05.619','2026-01-19 18:03:05.619',NULL);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicios`
--

DROP TABLE IF EXISTS `servicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servicios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(191) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `duracion` int(11) NOT NULL DEFAULT 30,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  `categoriaId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `servicios_categoriaId_fkey` (`categoriaId`),
  CONSTRAINT `servicios_categoriaId_fkey` FOREIGN KEY (`categoriaId`) REFERENCES `categorias` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicios`
--

LOCK TABLES `servicios` WRITE;
/*!40000 ALTER TABLE `servicios` DISABLE KEYS */;
INSERT INTO `servicios` VALUES (68,'Limpieza Dental','Limpieza dental profesional con ultrasonido',800.00,45,1,'2025-12-16 22:24:43.239','2025-12-19 16:08:09.966',47),(69,'Consulta de Ortodoncia','Evaluaci??n y plan de tratamiento de ortodoncia',800.00,45,1,'2025-12-16 22:24:43.240','2025-12-17 22:06:09.965',51),(70,'Resina Dental','Restauraci??n con resina fotocurable',900.00,60,1,'2025-12-16 22:24:43.239','2025-12-17 22:06:30.205',48),(71,'Blanqueamiento Dental 3 sesiones y limpieza dental','Blanqueamiento dental con luz LED',5500.00,60,1,'2025-12-16 22:24:43.240','2025-12-19 16:06:35.943',46),(72,'Extracci??n Simple','Extracci??n de pieza dental sin complicaciones',1000.00,30,1,'2025-12-16 22:24:43.239','2025-12-17 22:06:18.793',45),(73,'Endodoncia','Tratamiento de conductos',3000.00,90,1,'2025-12-16 22:24:43.239','2025-12-17 22:06:00.158',50),(74,'Endodoncia molar superior','',4000.00,30,1,'2025-12-17 22:07:00.268','2025-12-17 22:07:00.268',50),(75,'Endodoncia molar inferior','',3800.00,60,1,'2025-12-17 22:07:48.777','2025-12-19 16:01:40.950',50),(76,'Profilaxis con aeropulidor','',1500.00,30,1,'2025-12-17 22:08:49.231','2025-12-17 22:08:49.231',49),(77,'Consulta dental','',300.00,30,1,'2025-12-17 22:09:13.252','2025-12-17 22:09:13.252',49),(78,'Implante Dental','',15000.00,90,1,'2025-12-18 00:37:48.028','2025-12-19 16:11:04.846',45),(79,'Corona Zirconia','',9000.00,30,1,'2025-12-19 01:03:49.362','2025-12-19 01:03:49.362',46),(80,'Carilla de cer??mica ','',9000.00,60,1,'2025-12-19 16:04:59.190','2025-12-19 16:04:59.190',46),(81,'Carilla de composite','',1800.00,60,1,'2025-12-19 16:05:49.894','2025-12-19 16:05:49.894',46),(82,'Equia Forte ','',1000.00,60,1,'2025-12-19 16:10:40.720','2025-12-19 16:10:40.720',49),(83,'Tratamiento pulpar indirecto','',100.00,30,1,'2025-12-19 16:39:41.999','2025-12-19 16:39:41.999',49),(84,'Selladores de fosetas y fisuras','',500.00,30,1,'2025-12-19 16:40:03.175','2025-12-19 16:40:03.175',47),(85,'Cirug??a tercer molar','',3000.00,60,1,'2025-12-19 18:49:50.556','2025-12-19 18:49:50.556',45),(86,'Abono tx','Varios tratamientos',10000.00,60,1,'2025-12-19 22:12:56.993','2025-12-19 22:12:56.993',48),(87,'Profilaxis con fluor','',1000.00,60,1,'2025-12-20 17:06:36.524','2025-12-20 17:06:36.524',47),(88,'Cementacion','',600.00,45,1,'2025-12-23 22:03:35.279','2025-12-23 22:03:35.279',46),(89,'Curetaje ','',1500.00,45,1,'2025-12-23 22:54:31.725','2025-12-23 22:54:31.725',47),(90,'Protesis Dental','',10000.00,60,1,'2025-12-23 22:56:29.540','2025-12-24 18:05:08.957',46),(91,'Poste Fibra de vidrio','',2500.00,30,1,'2025-12-26 17:37:52.569','2025-12-26 17:37:52.569',48),(92,'Rebase Pr??tesis ','',1000.00,45,1,'2025-12-26 18:07:17.693','2025-12-26 18:07:17.693',46),(93,'Resina Fibra de Vidrio','',1500.00,45,1,'2025-12-26 23:28:21.937','2025-12-26 23:28:21.937',48),(94,'Resina Estetica','',1700.00,60,1,'2025-12-31 16:55:30.663','2025-12-31 16:55:30.663',46),(95,'CURETAJE CERRADO POR CUADRANTE ','',1500.00,60,1,'2026-01-19 18:13:54.006','2026-01-19 18:13:54.006',49),(96,'Limpieza dental con fl??or Kids','',950.00,30,1,'2026-01-24 15:48:16.395','2026-01-24 15:48:16.395',52),(97,'Extracci??n Kids','',1000.00,30,1,'2026-01-24 15:49:02.558','2026-01-24 15:49:02.558',52),(98,'Pulpectom??a ','',1500.00,90,1,'2026-01-24 15:49:39.539','2026-01-24 15:49:39.539',52),(99,'Extracci??n con mantenedor de espacio','',3000.00,30,1,'2026-01-24 15:50:23.614','2026-01-24 15:50:23.614',52),(100,'Corona celuloide Anterior','',1600.00,60,1,'2026-01-24 15:51:46.404','2026-01-24 15:51:46.404',51);
/*!40000 ALTER TABLE `servicios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicios_laboratorio`
--

DROP TABLE IF EXISTS `servicios_laboratorio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servicios_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `laboratorioId` int(11) NOT NULL,
  `servicioId` int(11) NOT NULL,
  `pacienteId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `costo` decimal(10,2) NOT NULL,
  `montoPagado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `saldoPendiente` decimal(10,2) NOT NULL,
  `estado` varchar(191) NOT NULL DEFAULT 'pendiente',
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `servicios_laboratorio_laboratorioId_fkey` (`laboratorioId`),
  KEY `servicios_laboratorio_servicioId_fkey` (`servicioId`),
  KEY `servicios_laboratorio_pacienteId_fkey` (`pacienteId`),
  KEY `servicios_laboratorio_doctorId_fkey` (`doctorId`),
  CONSTRAINT `servicios_laboratorio_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `servicios_laboratorio_laboratorioId_fkey` FOREIGN KEY (`laboratorioId`) REFERENCES `laboratorios` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `servicios_laboratorio_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `servicios_laboratorio_servicioId_fkey` FOREIGN KEY (`servicioId`) REFERENCES `servicios` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicios_laboratorio`
--

LOCK TABLES `servicios_laboratorio` WRITE;
/*!40000 ALTER TABLE `servicios_laboratorio` DISABLE KEYS */;
/*!40000 ALTER TABLE `servicios_laboratorio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tratamientos_plazo`
--

DROP TABLE IF EXISTS `tratamientos_plazo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tratamientos_plazo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pacienteId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `servicioId` int(11) NOT NULL,
  `montoTotal` decimal(10,2) NOT NULL,
  `montoPagado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `montoAdeudado` decimal(10,2) NOT NULL,
  `estado` varchar(191) NOT NULL DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tratamientos_plazo_pacienteId_idx` (`pacienteId`),
  KEY `tratamientos_plazo_doctorId_idx` (`doctorId`),
  KEY `tratamientos_plazo_servicioId_idx` (`servicioId`),
  CONSTRAINT `tratamientos_plazo_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `tratamientos_plazo_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `tratamientos_plazo_servicioId_fkey` FOREIGN KEY (`servicioId`) REFERENCES `servicios` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tratamientos_plazo`
--

LOCK TABLES `tratamientos_plazo` WRITE;
/*!40000 ALTER TABLE `tratamientos_plazo` DISABLE KEYS */;
/*!40000 ALTER TABLE `tratamientos_plazo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usos_materiales`
--

DROP TABLE IF EXISTS `usos_materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usos_materiales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `materialId` int(11) NOT NULL,
  `pacienteId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `tratamientoId` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `observaciones` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `usos_materiales_materialId_fkey` (`materialId`),
  KEY `usos_materiales_pacienteId_fkey` (`pacienteId`),
  KEY `usos_materiales_doctorId_fkey` (`doctorId`),
  KEY `usos_materiales_usuarioId_fkey` (`usuarioId`),
  CONSTRAINT `usos_materiales_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `usos_materiales_materialId_fkey` FOREIGN KEY (`materialId`) REFERENCES `materiales` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `usos_materiales_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `usos_materiales_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usos_materiales`
--

LOCK TABLES `usos_materiales` WRITE;
/*!40000 ALTER TABLE `usos_materiales` DISABLE KEYS */;
/*!40000 ALTER TABLE `usos_materiales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(191) NOT NULL,
  `password` varchar(191) NOT NULL,
  `nombre` varchar(191) NOT NULL,
  `rol` varchar(191) NOT NULL DEFAULT 'recepcionista',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `doctorId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuarios_email_key` (`email`),
  UNIQUE KEY `usuarios_doctorId_key` (`doctorId`),
  CONSTRAINT `usuarios_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (25,'admin@clinica.com','$2a$10$qeDfBAz.wb4nC89RYYsCmOyPE4NagMJXBKfuXBLlwKz.UkdD13402','Administrador','admin',1,NULL,'2025-12-16 22:24:43.184','2025-12-16 22:24:43.184'),(26,'doctor@clinica.com','$2a$10$0Hrggo6WIyy.1Lv3y/rjJubh6eGJeGo/n1IfpeYQ3lFYhb0SYre/2','Dr. Juan Mart??nez','doctor',1,30,'2025-12-16 22:24:43.194','2025-12-16 22:24:43.194'),(27,'recepcion@clinica.com','$2a$10$fMKzBrTPwkyMtMc5EOl3sesY0a5cCHqQHj6WyAn6O04gVCDhlxt4a','Mar??a Garc??a','recepcionista',1,NULL,'2025-12-16 22:24:43.201','2025-12-16 22:24:43.201');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vault_movimientos`
--

DROP TABLE IF EXISTS `vault_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vault_movimientos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(191) NOT NULL,
  `metodo` varchar(191) NOT NULL,
  `banco` varchar(191) DEFAULT NULL,
  `monto` decimal(12,2) NOT NULL,
  `nota` text DEFAULT NULL,
  `usuarioId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL ON UPDATE current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `vault_movimientos_usuarioId_idx` (`usuarioId`),
  CONSTRAINT `vault_movimientos_usuarioId_fkey` FOREIGN KEY (`usuarioId`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vault_movimientos`
--

LOCK TABLES `vault_movimientos` WRITE;
/*!40000 ALTER TABLE `vault_movimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `vault_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta_items`
--

DROP TABLE IF EXISTS `venta_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `venta_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ventaId` int(11) NOT NULL,
  `tipo` varchar(191) NOT NULL,
  `servicioId` int(11) DEFAULT NULL,
  `productoId` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precioUnit` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `venta_items_ventaId_fkey` (`ventaId`),
  KEY `venta_items_servicioId_fkey` (`servicioId`),
  KEY `venta_items_productoId_fkey` (`productoId`),
  CONSTRAINT `venta_items_productoId_fkey` FOREIGN KEY (`productoId`) REFERENCES `productos` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `venta_items_servicioId_fkey` FOREIGN KEY (`servicioId`) REFERENCES `servicios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `venta_items_ventaId_fkey` FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_items`
--

LOCK TABLES `venta_items` WRITE;
/*!40000 ALTER TABLE `venta_items` DISABLE KEYS */;
INSERT INTO `venta_items` VALUES (38,26,'servicio',76,NULL,1,1500.00,1500.00),(39,27,'servicio',68,NULL,1,800.00,800.00),(40,28,'servicio',77,NULL,1,300.00,300.00),(41,29,'servicio',76,NULL,1,1500.00,1500.00),(42,30,'servicio',69,NULL,3,800.00,2400.00),(43,31,'servicio',78,NULL,1,18000.00,18000.00),(44,32,'servicio',78,NULL,1,18000.00,18000.00),(45,33,'servicio',76,NULL,1,1500.00,1500.00),(46,34,'servicio',77,NULL,1,300.00,300.00),(47,35,'servicio',74,NULL,1,4000.00,4000.00),(48,36,'servicio',77,NULL,1,300.00,300.00),(49,37,'servicio',76,NULL,1,1500.00,1500.00),(50,38,'servicio',73,NULL,1,3000.00,3000.00),(51,39,'servicio',79,NULL,1,9000.00,9000.00),(52,40,'servicio',71,NULL,1,5500.00,5500.00),(53,41,'servicio',73,NULL,1,3000.00,3000.00),(54,42,'servicio',85,NULL,1,3000.00,3000.00),(55,43,'servicio',77,NULL,1,300.00,300.00),(56,44,'servicio',86,NULL,1,10000.00,10000.00),(57,45,'servicio',86,NULL,1,10000.00,10000.00),(58,46,'servicio',85,NULL,1,3000.00,3000.00),(59,47,'servicio',68,NULL,1,800.00,800.00),(60,48,'servicio',76,NULL,1,1500.00,1500.00),(61,49,'servicio',87,NULL,1,1000.00,1000.00),(62,50,'servicio',79,NULL,1,9000.00,9000.00),(63,51,'servicio',68,NULL,1,800.00,800.00),(64,52,'servicio',86,NULL,1,10000.00,10000.00),(65,53,'servicio',85,NULL,1,3000.00,3000.00),(66,54,'servicio',85,NULL,1,3000.00,3000.00),(67,55,'servicio',73,NULL,1,3000.00,3000.00),(68,56,'servicio',76,NULL,1,1500.00,1500.00),(69,57,'servicio',74,NULL,1,4000.00,4000.00),(70,58,'servicio',82,NULL,1,1000.00,1000.00),(71,59,'servicio',76,NULL,1,1500.00,1500.00),(72,60,'servicio',86,NULL,1,10000.00,10000.00),(73,61,'servicio',79,NULL,1,9000.00,9000.00),(74,62,'servicio',70,NULL,1,900.00,900.00),(75,63,'servicio',88,NULL,1,600.00,600.00),(76,64,'servicio',89,NULL,1,1500.00,1500.00),(77,65,'servicio',90,NULL,1,5000.00,5000.00),(78,66,'servicio',77,NULL,1,300.00,300.00),(79,67,'servicio',73,NULL,1,3000.00,3000.00),(80,68,'servicio',70,NULL,1,900.00,900.00),(81,69,'servicio',85,NULL,1,3000.00,3000.00),(82,70,'servicio',90,NULL,1,10000.00,10000.00),(83,71,'servicio',74,NULL,1,4000.00,4000.00),(84,72,'servicio',91,NULL,1,2500.00,2500.00),(85,72,'servicio',79,NULL,1,9000.00,9000.00),(86,73,'servicio',92,NULL,1,1000.00,1000.00),(87,74,'servicio',79,NULL,1,9000.00,9000.00),(88,75,'servicio',70,NULL,1,900.00,900.00),(89,76,'servicio',76,NULL,1,1500.00,1500.00),(90,77,'producto',NULL,15,5,85.00,425.00),(91,78,'servicio',93,NULL,1,1500.00,1500.00),(92,79,'servicio',70,NULL,1,900.00,900.00),(93,80,'servicio',68,NULL,1,800.00,800.00),(94,81,'servicio',70,NULL,1,900.00,900.00),(95,82,'servicio',86,NULL,2,10000.00,20000.00),(96,83,'servicio',70,NULL,2,900.00,1800.00),(97,84,'servicio',76,NULL,1,1500.00,1500.00),(98,85,'servicio',76,NULL,1,1500.00,1500.00),(99,86,'servicio',76,NULL,1,1500.00,1500.00),(100,87,'servicio',85,NULL,1,3000.00,3000.00),(101,88,'servicio',76,NULL,1,1500.00,1500.00),(102,89,'servicio',94,NULL,1,1700.00,1700.00),(103,90,'servicio',70,NULL,1,900.00,900.00),(104,91,'servicio',68,NULL,1,800.00,800.00),(105,92,'servicio',77,NULL,1,300.00,300.00),(106,93,'servicio',71,NULL,1,5500.00,5500.00),(107,94,'servicio',68,NULL,1,800.00,800.00),(108,95,'servicio',86,NULL,1,10000.00,10000.00),(109,96,'servicio',68,NULL,1,800.00,800.00),(110,97,'servicio',68,NULL,1,800.00,800.00),(111,98,'servicio',93,NULL,1,1500.00,1500.00),(112,99,'servicio',70,NULL,1,900.00,900.00),(113,100,'servicio',85,NULL,1,3000.00,3000.00),(114,101,'servicio',86,NULL,1,10000.00,10000.00),(115,102,'servicio',69,NULL,1,800.00,800.00),(116,103,'servicio',69,NULL,1,800.00,800.00),(117,104,'servicio',69,NULL,1,800.00,800.00),(118,104,'servicio',77,NULL,1,300.00,300.00),(119,105,'servicio',68,NULL,1,800.00,800.00),(120,106,'servicio',68,NULL,1,800.00,800.00),(121,107,'servicio',69,NULL,1,800.00,800.00),(122,108,'servicio',69,NULL,1,800.00,800.00),(123,109,'servicio',86,NULL,1,10000.00,10000.00),(124,110,'servicio',70,NULL,2,900.00,1800.00),(125,111,'servicio',86,NULL,1,10000.00,10000.00),(126,112,'servicio',70,NULL,1,900.00,900.00),(127,113,'servicio',85,NULL,1,3000.00,3000.00),(128,114,'servicio',70,NULL,1,900.00,900.00),(129,115,'servicio',68,NULL,1,800.00,800.00),(130,116,'servicio',85,NULL,1,3000.00,3000.00),(131,117,'servicio',68,NULL,1,800.00,800.00),(132,118,'servicio',68,NULL,1,800.00,800.00),(133,119,'servicio',70,NULL,6,900.00,5400.00),(134,120,'servicio',70,NULL,1,900.00,900.00),(135,121,'servicio',76,NULL,1,1500.00,1500.00),(136,122,'servicio',76,NULL,1,1500.00,1500.00),(137,123,'servicio',68,NULL,1,800.00,800.00),(138,124,'servicio',77,NULL,1,300.00,300.00),(139,125,'servicio',86,NULL,1,10000.00,10000.00),(140,126,'servicio',77,NULL,1,300.00,300.00),(141,127,'servicio',76,NULL,1,1500.00,1500.00),(142,128,'servicio',95,NULL,2,1500.00,3000.00),(143,129,'servicio',85,NULL,2,3000.00,6000.00),(144,130,'servicio',72,NULL,1,1000.00,1000.00),(145,131,'servicio',70,NULL,1,900.00,900.00),(146,132,'servicio',86,NULL,1,10000.00,10000.00),(147,133,'servicio',82,NULL,3,1000.00,3000.00),(148,134,'servicio',68,NULL,1,800.00,800.00),(149,135,'servicio',94,NULL,2,1700.00,3400.00),(150,136,'servicio',79,NULL,1,9000.00,9000.00),(151,137,'servicio',73,NULL,1,3000.00,3000.00),(152,138,'servicio',94,NULL,2,1700.00,3400.00),(153,139,'servicio',72,NULL,1,1000.00,1000.00),(154,140,'servicio',77,NULL,1,300.00,300.00),(155,141,'servicio',73,NULL,1,3000.00,3000.00),(156,142,'servicio',79,NULL,1,9000.00,9000.00),(157,143,'servicio',76,NULL,1,1500.00,1500.00),(158,144,'servicio',85,NULL,1,3000.00,3000.00),(159,145,'servicio',73,NULL,1,3000.00,3000.00),(160,146,'servicio',70,NULL,1,900.00,900.00),(161,147,'servicio',68,NULL,1,800.00,800.00),(162,147,'servicio',72,NULL,2,1000.00,2000.00),(163,148,'servicio',69,NULL,1,800.00,800.00),(164,149,'servicio',96,NULL,1,950.00,950.00),(165,150,'servicio',96,NULL,1,950.00,950.00),(166,151,'servicio',85,NULL,1,3000.00,3000.00),(167,152,'servicio',100,NULL,2,1600.00,3200.00),(168,153,'servicio',70,NULL,1,900.00,900.00),(169,154,'servicio',70,NULL,1,900.00,900.00),(170,155,'servicio',96,NULL,1,950.00,950.00),(171,156,'servicio',82,NULL,2,1000.00,2000.00),(172,157,'servicio',70,NULL,1,900.00,900.00);
/*!40000 ALTER TABLE `venta_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ventas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folio` varchar(191) NOT NULL,
  `pacienteId` int(11) DEFAULT NULL,
  `doctorId` int(11) DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `descuento` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total` decimal(10,2) NOT NULL,
  `metodoPago` varchar(191) NOT NULL DEFAULT 'efectivo',
  `banco` varchar(191) DEFAULT NULL,
  `moneda` varchar(191) NOT NULL DEFAULT 'MXN',
  `estado` varchar(191) NOT NULL DEFAULT 'completada',
  `notas` text DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ventas_folio_key` (`folio`),
  KEY `ventas_pacienteId_fkey` (`pacienteId`),
  KEY `ventas_doctorId_idx` (`doctorId`),
  CONSTRAINT `ventas_doctorId_fkey` FOREIGN KEY (`doctorId`) REFERENCES `doctores` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ventas_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
INSERT INTO `ventas` VALUES (26,'V20251217-RWFNRS',50,31,1500.00,900.00,600.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-17 22:16:16.437','2025-12-17 22:16:16.437'),(27,'V20251217-XPXRRD',51,31,800.00,300.00,500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-17 22:29:48.937','2025-12-17 22:29:48.937'),(28,'V20251217-VXEW26',52,36,300.00,0.00,300.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-17 23:49:27.715','2025-12-17 23:49:27.715'),(29,'V20251217-7MEO9D',51,35,1500.00,0.00,1500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-17 23:51:25.042','2025-12-17 23:51:25.042'),(30,'V20251217-NYHV8N',53,35,2400.00,400.00,2000.00,'transferencia','Azteca','MXN','completada',NULL,'2025-12-17 23:55:26.238','2025-12-17 23:55:26.238'),(31,'V20251217-TL1Z4I',54,31,18000.00,15000.00,3000.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 00:39:41.279','2025-12-18 00:39:41.279'),(32,'V20251217-IBASZG',54,31,18000.00,4000.00,14000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-18 00:40:07.767','2025-12-18 00:40:07.767'),(33,'V20251217-6IOG5D',55,32,1500.00,300.00,1200.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 01:01:13.615','2025-12-18 01:01:13.615'),(34,'V20251218-STAVEK',56,31,300.00,0.00,300.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 15:52:58.119','2025-12-18 15:52:58.119'),(35,'V20251218-D4Z709',NULL,33,4000.00,2000.00,2000.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 18:11:33.702','2025-12-18 18:11:33.702'),(36,'V20251218-KF9HNU',58,31,300.00,0.00,300.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 18:13:08.604','2025-12-18 18:13:08.604'),(37,'V20251218-UVP2MF',59,32,1500.00,500.00,1000.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-18 22:06:41.870','2025-12-18 22:06:41.870'),(38,'V20251218-PPBX9V',60,33,3000.00,1500.00,1500.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-18 23:20:38.074','2025-12-18 23:20:38.074'),(39,'V20251218-4OTAI3',61,33,9000.00,5750.00,3250.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-19 01:04:27.130','2025-12-19 01:04:27.130'),(40,'V20251219-Y1RT8I',62,31,5500.00,2000.00,3500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-19 17:20:45.212','2025-12-19 17:20:45.212'),(41,'V20251219-8PW79B',63,33,3000.00,900.00,2100.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-19 18:40:16.068','2025-12-19 18:40:16.068'),(42,'V20251219-1OKLZR',64,31,3000.00,300.00,2700.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-19 18:50:14.736','2025-12-19 18:50:14.736'),(43,'V20251219-SD48W0',66,31,300.00,0.00,300.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-19 22:11:29.856','2025-12-19 22:11:29.856'),(44,'V20251219-ATNLY1',65,32,10000.00,7000.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-19 22:13:23.019','2025-12-19 22:13:23.019'),(45,'V20251219-ZUFYOK',60,33,10000.00,7000.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-19 22:13:49.752','2025-12-19 22:13:49.752'),(46,'V20251219-K1GCX4',67,33,3000.00,500.00,2500.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-19 23:30:43.591','2025-12-19 23:30:43.591'),(47,'V20251219-NGUN5R',68,32,800.00,0.00,800.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-20 00:09:57.132','2025-12-20 00:09:57.132'),(48,'V20251220-3YGBH8',69,31,1500.00,300.00,1200.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-20 17:05:28.112','2025-12-20 17:05:28.112'),(49,'V20251220-S9U08R',70,32,1000.00,0.00,1000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-20 17:06:55.721','2025-12-20 17:06:55.721'),(50,'V20251220-PJ0ZDV',71,33,9000.00,3325.00,5675.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-20 17:27:17.416','2025-12-20 17:27:17.416'),(51,'V20251220-9EOZTG',72,32,800.00,300.00,500.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-20 18:27:56.896','2025-12-20 18:27:56.896'),(52,'V20251220-U5FC6F',NULL,NULL,10000.00,9800.00,200.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-20 18:30:23.002','2025-12-20 18:30:23.002'),(53,'V20251220-H8LUM5',58,31,3000.00,1500.00,1500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-20 18:46:56.210','2025-12-20 18:46:56.210'),(54,'V20251220-3TPFDO',58,31,3000.00,1800.00,1200.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-20 18:47:29.897','2025-12-20 18:47:29.897'),(55,'V20251222-L22JI9',57,33,3000.00,1724.99,1275.01,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-22 18:38:38.284','2025-12-22 18:38:38.284'),(56,'V20251222-LU9VT9',73,31,1500.00,540.00,960.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-22 18:39:11.100','2025-12-22 18:39:11.100'),(57,'V20251222-R8T66U',74,33,4000.00,1000.00,3000.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-22 22:53:14.041','2025-12-22 22:53:14.041'),(58,'V20251222-3LAYDX',75,31,1000.00,0.00,1000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-22 23:29:02.981','2025-12-22 23:29:02.981'),(59,'V20251222-7YLY4A',76,32,1500.00,300.00,1200.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-23 00:13:01.594','2025-12-23 00:13:01.594'),(60,'V20251222-VQAMLF',NULL,31,10000.00,9650.00,350.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-23 00:15:49.578','2025-12-23 00:15:49.578'),(61,'V20251222-P2TY7V',77,31,9000.00,5800.00,3200.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-23 00:33:25.582','2025-12-23 00:33:25.582'),(62,'V20251222-AT9X5D',67,33,900.00,480.00,420.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-23 00:59:56.935','2025-12-23 00:59:56.935'),(63,'V20251223-TWSS1X',78,31,600.00,0.00,600.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-23 22:04:45.961','2025-12-23 22:04:45.961'),(64,'V20251223-BO7LJ8',79,31,1500.00,700.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-23 22:55:08.601','2025-12-23 22:55:08.601'),(65,'V20251223-1H02XS',80,36,5000.00,2000.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-23 22:56:49.782','2025-12-23 22:56:49.782'),(66,'V20251223-OBVZUE',81,31,300.00,0.00,300.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-23 23:36:28.780','2025-12-23 23:36:28.780'),(67,'V20251223-11KOY9',74,33,3000.00,2500.00,500.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-24 00:07:08.787','2025-12-24 00:07:08.787'),(68,'V20251223-LCGOKU',82,36,900.00,100.00,800.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-24 00:07:57.067','2025-12-24 00:07:57.067'),(69,'V20251224-UU7UHJ',66,31,3000.00,0.00,3000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-24 17:51:24.162','2025-12-24 17:51:24.162'),(70,'V20251224-0LX4YN',83,31,10000.00,5800.00,4200.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-24 18:05:37.646','2025-12-24 18:05:37.646'),(71,'V20251226-N2XX6O',84,33,4000.00,500.00,3500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 17:37:12.829','2025-12-26 17:37:12.829'),(72,'V20251226-CSOQLV',84,31,11500.00,5000.00,6500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 17:38:35.618','2025-12-26 17:38:35.618'),(73,'V20251226-YL91A4',85,31,1000.00,100.00,900.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 18:07:38.081','2025-12-26 18:07:38.081'),(74,'V20251226-AMBCQT',86,33,9000.00,2500.00,6500.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2025-12-26 18:21:36.781','2025-12-26 18:21:36.781'),(75,'V20251226-VZS3AJ',77,31,900.00,90.00,810.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 22:37:22.659','2025-12-26 22:37:22.659'),(76,'V20251226-P0VEEE',87,32,1500.00,500.00,1000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 22:37:45.565','2025-12-26 22:37:45.565'),(77,'V20251226-OXO5VW',NULL,NULL,425.00,25.00,400.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-26 22:38:03.467','2025-12-26 22:38:03.467'),(78,'V20251226-JUE6MD',74,32,1500.00,300.00,1200.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-26 23:28:36.235','2025-12-26 23:28:36.235'),(79,'V20251226-82FG7D',73,31,900.00,180.00,720.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-27 00:07:46.139','2025-12-27 00:07:46.139'),(80,'V20251227-NWUIHB',88,31,800.00,400.00,400.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-27 16:06:13.308','2025-12-27 16:06:13.308'),(81,'V20251227-XUTCTY',79,31,900.00,100.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-27 18:54:58.202','2025-12-27 18:54:58.202'),(82,'V20251229-E8GP2H',NULL,NULL,20000.00,7031.00,12969.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-29 16:13:46.754','2025-12-29 16:13:46.754'),(83,'V20251229-FA272P',67,33,1800.00,960.00,840.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-29 18:38:22.034','2025-12-29 18:38:22.034'),(84,'V20251229-PHWFWN',NULL,31,1500.00,100.00,1400.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-29 18:57:55.553','2025-12-29 18:57:55.553'),(85,'V20251229-GCJ9JS',89,31,1500.00,100.00,1400.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-29 22:58:01.375','2025-12-29 22:58:01.375'),(86,'V20251229-3FQVV0',90,31,1500.00,100.00,1400.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-29 22:58:16.432','2025-12-29 22:58:16.432'),(87,'V20251229-QZYGA8',91,31,3000.00,0.00,3000.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-29 23:05:27.831','2025-12-29 23:05:27.831'),(88,'V20251230-OMS5SJ',NULL,NULL,1500.00,100.00,1400.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-30 16:20:47.516','2025-12-30 16:20:47.516'),(89,'V20251231-WU0EAM',NULL,NULL,1700.00,620.00,1080.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-31 16:55:49.797','2025-12-31 16:55:49.797'),(90,'V20251231-DRPW2U',NULL,NULL,900.00,100.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-31 18:00:34.157','2025-12-31 18:00:34.157'),(91,'V20251231-7ERFQP',NULL,NULL,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-31 18:00:44.053','2025-12-31 18:00:44.053'),(92,'V20251231-6SK15Y',NULL,NULL,300.00,0.00,300.00,'efectivo',NULL,'MXN','completada',NULL,'2025-12-31 18:00:50.962','2025-12-31 18:00:50.962'),(93,'V20251231-VC1Z45',NULL,NULL,5500.00,1000.00,4500.00,'tarjeta','BBVA','MXN','completada',NULL,'2025-12-31 18:19:44.204','2025-12-31 18:19:44.204'),(94,'V20260114-3430GV',93,31,800.00,200.00,600.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-14 17:08:11.021','2026-01-14 17:08:11.021'),(95,'V20260114-VGO3L2',93,35,10000.00,9000.00,1000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-14 17:08:54.698','2026-01-14 17:08:54.698'),(96,'V20260114-EFGAF0',94,36,800.00,200.00,600.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-14 17:09:19.837','2026-01-14 17:09:19.837'),(97,'V20260114-V4W2Y8',95,33,800.00,80.00,720.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-14 17:56:23.432','2026-01-14 17:56:23.432'),(98,'V20260114-FJAGQC',96,33,1500.00,1100.00,400.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-14 18:18:44.252','2026-01-14 18:18:44.252'),(99,'V20260114-PDS075',97,31,900.00,0.00,900.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-14 18:19:48.241','2026-01-14 18:19:48.241'),(100,'V20260114-59A8H7',98,33,3000.00,700.00,2300.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 00:10:53.894','2026-01-15 00:10:53.894'),(101,'V20260114-LKO3P3',NULL,35,10000.00,4000.00,6000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 00:11:19.946','2026-01-15 00:11:19.946'),(102,'V20260114-0GEOWO',NULL,35,800.00,0.00,800.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:13:41.445','2026-01-15 00:13:41.445'),(103,'V20260114-YAP1EK',NULL,NULL,800.00,100.00,700.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:14:00.394','2026-01-15 00:14:00.394'),(104,'V20260114-XWZV7Z',NULL,35,1100.00,100.00,1000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:14:33.164','2026-01-15 00:14:33.164'),(105,'V20260114-Y51DVX',99,32,800.00,120.00,680.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:15:45.013','2026-01-15 00:15:45.013'),(106,'V20260114-4RX7VX',99,32,800.00,120.00,680.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:15:45.064','2026-01-15 00:15:45.064'),(107,'V20260114-UKVGVM',NULL,35,800.00,100.00,700.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:16:13.010','2026-01-15 00:16:13.010'),(108,'V20260114-X4P55X',NULL,35,800.00,100.00,700.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 00:16:37.867','2026-01-15 00:16:37.867'),(109,'V20260114-NKSQ88',NULL,31,10000.00,4400.00,5600.00,'transferencia','Azteca','MXN','completada',NULL,'2026-01-15 00:20:11.609','2026-01-15 00:20:11.609'),(110,'V20260114-V87QH2',100,31,1800.00,200.00,1600.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 00:54:17.562','2026-01-15 00:54:17.562'),(111,'V20260114-FHOMNR',NULL,32,10000.00,7000.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 01:00:43.985','2026-01-15 01:00:43.985'),(112,'V20260115-P8W4K1',95,33,900.00,135.00,765.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-15 22:18:40.042','2026-01-15 22:18:40.042'),(113,'V20260115-1CDA7B',102,31,3000.00,0.00,3000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 22:18:57.124','2026-01-15 22:18:57.124'),(114,'V20260115-NWFQGQ',101,31,900.00,135.00,765.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 22:19:22.507','2026-01-15 22:19:22.507'),(115,'V20260115-M7L8P3',NULL,31,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-15 22:19:41.226','2026-01-15 22:19:41.226'),(116,'V20260115-XM8KR3',103,36,3000.00,1200.00,1800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-16 00:03:00.966','2026-01-16 00:03:00.966'),(117,'V20260115-B9Q7T2',105,31,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-16 00:16:05.017','2026-01-16 00:16:05.017'),(118,'V20260115-95KICS',104,33,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-16 00:16:23.469','2026-01-16 00:16:23.469'),(119,'V20260115-080CYS',106,32,5400.00,2880.00,2520.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-16 00:38:06.450','2026-01-16 00:38:06.450'),(120,'V20260115-GH8IB2',107,33,900.00,90.00,810.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-16 00:39:20.722','2026-01-16 00:39:20.722'),(121,'V20260116-U4KJVW',108,31,1500.00,300.00,1200.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-16 17:54:24.995','2026-01-16 17:54:24.995'),(122,'V20260116-B33G1H',109,36,1500.00,500.00,1000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-17 00:43:16.512','2026-01-17 00:43:16.512'),(123,'V20260116-ZSD9RN',110,32,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-17 00:44:39.315','2026-01-17 00:44:39.315'),(124,'V20260116-AV9FBP',111,36,300.00,100.00,200.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-17 00:44:58.511','2026-01-17 00:44:58.511'),(125,'V20260117-HWTO2D',98,33,10000.00,6500.00,3500.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-17 17:43:58.500','2026-01-17 17:43:58.500'),(126,'V20260117-RZJNTH',NULL,36,300.00,127.00,173.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-17 17:48:04.993','2026-01-17 17:48:04.993'),(127,'V20260119-PFY6K8',112,31,1500.00,300.00,1200.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-19 17:21:12.273','2026-01-19 17:21:12.273'),(128,'V20260119-1LM3PN',113,31,3000.00,450.00,2550.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-19 18:14:17.263','2026-01-19 18:14:17.263'),(129,'V20260119-VKB9UG',114,33,6000.00,1000.00,5000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-20 00:22:48.260','2026-01-20 00:22:48.260'),(130,'V20260119-HTGX3S',115,33,1000.00,400.00,600.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-20 00:25:51.978','2026-01-20 00:25:51.978'),(131,'V20260119-CV35PD',116,33,900.00,0.00,900.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-20 00:33:47.445','2026-01-20 00:33:47.445'),(132,'V20260119-H6OZXA',117,31,10000.00,6070.00,3930.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-20 00:34:50.226','2026-01-20 00:34:50.226'),(133,'V20260120-BTF7P6',118,31,3000.00,300.00,2700.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-20 17:13:17.795','2026-01-20 17:13:17.795'),(134,'V20260120-T65L9Q',NULL,31,800.00,150.00,650.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-20 22:13:25.416','2026-01-20 22:13:25.416'),(135,'V20260120-D1J7E4',54,31,3400.00,1400.00,2000.00,'tarjeta','Azteca','MXN','completada',NULL,'2026-01-20 23:53:17.215','2026-01-20 23:53:17.215'),(136,'V20260121-Q4OBDW',119,31,9000.00,4300.00,4700.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-21 18:31:29.228','2026-01-21 18:31:29.228'),(137,'V20260121-PL0ZQ1',120,33,3000.00,0.00,3000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-21 18:31:42.293','2026-01-21 18:31:42.293'),(138,'V20260121-4E14BV',64,31,3400.00,1000.00,2400.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-21 18:40:18.398','2026-01-21 18:40:18.398'),(139,'V20260121-7YGHWL',121,31,1000.00,0.00,1000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-22 00:39:12.985','2026-01-22 00:39:12.985'),(140,'V20260121-AKPFCN',NULL,NULL,300.00,280.00,20.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-22 00:43:46.077','2026-01-22 00:43:46.077'),(141,'V20260122-CPYMI0',122,33,3000.00,0.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-22 18:14:59.370','2026-01-22 18:14:59.370'),(142,'V20260122-5ZJ4BM',86,33,9000.00,6000.00,3000.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-22 18:41:20.503','2026-01-22 18:41:20.503'),(143,'V20260122-8Q20GD',123,31,1500.00,300.00,1200.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-22 21:56:18.390','2026-01-22 21:56:18.390'),(144,'V20260122-I2X778',76,32,3000.00,500.00,2500.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-22 22:05:13.007','2026-01-22 22:05:13.007'),(145,'V20260122-4FS2UP',109,33,3000.00,750.00,2250.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-22 23:10:15.671','2026-01-22 23:10:15.671'),(146,'V20260122-9QNI36',104,33,900.00,90.00,810.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-23 00:31:12.589','2026-01-23 00:31:12.589'),(147,'V20260122-54MARI',NULL,31,2800.00,1145.00,1655.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-23 00:32:30.082','2026-01-23 00:32:30.082'),(148,'V20260122-1ITUV7',NULL,31,800.00,0.00,800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-23 00:35:36.197','2026-01-23 00:35:36.197'),(149,'V20260124-9XB772',124,34,950.00,0.00,950.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-24 15:52:07.985','2026-01-24 15:52:07.985'),(150,'V20260124-H6YO99',NULL,34,950.00,0.00,950.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-24 17:09:48.283','2026-01-24 17:09:48.283'),(151,'V20260124-VYSE9K',NULL,31,3000.00,1200.00,1800.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-24 17:26:43.852','2026-01-24 17:26:43.852'),(152,'V20260124-Z1HGV0',NULL,34,3200.00,0.00,3200.00,'tarjeta','Mercado Pago','MXN','completada',NULL,'2026-01-24 19:16:55.511','2026-01-24 19:16:55.511'),(153,'V20260124-4XNBPO',77,31,900.00,0.00,900.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-24 19:21:23.487','2026-01-24 19:21:23.487'),(154,'V20260124-JRAS6Z',123,31,900.00,0.00,900.00,'tarjeta','BBVA','MXN','completada',NULL,'2026-01-24 19:21:57.857','2026-01-24 19:21:57.857'),(155,'V20260124-1L6BN6',NULL,34,950.00,0.00,950.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-24 19:24:58.221','2026-01-24 19:24:58.221'),(156,'V20260124-V30MAE',NULL,34,2000.00,0.00,2000.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-24 21:17:26.586','2026-01-24 21:17:26.586'),(157,'V20260124-338RQ3',NULL,34,900.00,0.00,900.00,'efectivo',NULL,'MXN','completada',NULL,'2026-01-24 21:18:49.178','2026-01-24 21:18:49.178');
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'clinica_dental'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-25 21:38:35
