-- ==============================================================
-- DATABASE SCHEMA: CP CLAP SERVICE PROVIDER APP
-- Follows SOP standards: InnoDB, UTF-8, UTC, Indexes, Foreign Keys
-- ==============================================================

CREATE DATABASE IF NOT EXISTS `cp_clap_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cp_clap_db`;

-- Drop tables if needed
DROP TABLE IF EXISTS `providers`;
DROP TABLE IF EXISTS `categories`;

-- --------------------------------------------------------
-- Table: categories (Master Service Categories)
-- --------------------------------------------------------
CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `icon` VARCHAR(60) NOT NULL DEFAULT 'fa-solid fa-wrench',
    `description` VARCHAR(255) NULL,
    `status` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table: providers (Service Providers)
-- --------------------------------------------------------
CREATE TABLE `providers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(25) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `experience_years` INT NOT NULL DEFAULT 0,
    `city` VARCHAR(100) NOT NULL,
    `id_type` VARCHAR(50) NULL COMMENT 'Aadhar, PAN, Driving License, Voter ID',
    `id_number` VARCHAR(50) NULL,
    `id_document` VARCHAR(255) NULL,
    `profile_photo` VARCHAR(255) NULL,
    `verification_status` ENUM('pending_verification', 'under_review', 'verified', 'rejected') NOT NULL DEFAULT 'pending_verification',
    `rejection_reason` TEXT NULL,
    `is_online` TINYINT(1) NOT NULL DEFAULT 0,
    `auth_token` VARCHAR(255) NULL,
    `token_expires_at` DATETIME NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_provider_phone` (`phone`),
    INDEX `idx_provider_email` (`email`),
    INDEX `idx_provider_status` (`verification_status`),
    INDEX `idx_provider_token` (`auth_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed service categories
INSERT INTO `categories` (`name`, `icon`, `description`) VALUES
('Electrician', 'fa-solid fa-bolt', 'Electrical repair, installation & wiring'),
('Plumber', 'fa-solid fa-faucet-drip', 'Piping, leakages, tap & bathroom fittings'),
('AC & Appliance Repair', 'fa-solid fa-snowflake', 'AC servicing, refrigerator, washing machine'),
('Home Cleaning', 'fa-solid fa-broom', 'Deep home cleaning, sofa & kitchen cleaning'),
('Painter', 'fa-solid fa-paint-roller', 'Interior & exterior wall painting, waterproof'),
('Carpenter', 'fa-solid fa-hammer', 'Furniture repair, assembly & wooden work'),
('Salon & Grooming', 'fa-solid fa-scissors', 'Men & women grooming, haircut, massage');
