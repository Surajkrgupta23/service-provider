<?php
/**
 * Location & PACS Data Model
 * Handles Master District, Tehseel, Block, and Registered PACS societies (test2)
 * Technology: MySQLi Prepared Statements
 * Follows SOP Standards
 */

declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';

class Location {
    private mysqli $db;

    public function __construct() {
        $this->db = Database::getConnection();
    }

    /**
     * Get All Districts
     */
    public function getDistricts(): array {
        $sql = "SELECT sno AS id, district_name AS name, dist_short_name 
                FROM master_district 
                WHERE district_name IS NOT NULL AND district_name != '' 
                ORDER BY district_name ASC";
        $result = $this->db->query($sql);
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }

    /**
     * Get Tehseels by District ID
     */
    public function getTehseels(?string $districtId = null): array {
        if ($districtId !== null && $districtId !== '') {
            $stmt = $this->db->prepare(
                "SELECT sno AS id, tehseel_name AS name, district_id 
                 FROM master_tehseel 
                 WHERE district_id = ? AND tehseel_name IS NOT NULL AND tehseel_name != '' 
                 ORDER BY tehseel_name ASC"
            );
            $stmt->bind_param("s", $districtId);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }

        $sql = "SELECT sno AS id, tehseel_name AS name, district_id 
                FROM master_tehseel 
                WHERE tehseel_name IS NOT NULL AND tehseel_name != '' 
                ORDER BY tehseel_name ASC";
        $result = $this->db->query($sql);
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }

    /**
     * Get Blocks by District ID and optional Tehseel ID
     */
    public function getBlocks(?string $districtId = null, ?string $tehseelId = null): array {
        if ($districtId !== null && $districtId !== '' && $tehseelId !== null && $tehseelId !== '') {
            $stmt = $this->db->prepare(
                "SELECT sno AS id, block_name AS name, tehseel_id, district_id 
                 FROM master_block 
                 WHERE district_id = ? AND tehseel_id = ? AND block_name IS NOT NULL AND block_name != '' 
                 ORDER BY block_name ASC"
            );
            $stmt->bind_param("ss", $districtId, $tehseelId);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }

        if ($districtId !== null && $districtId !== '') {
            $stmt = $this->db->prepare(
                "SELECT sno AS id, block_name AS name, tehseel_id, district_id 
                 FROM master_block 
                 WHERE district_id = ? AND block_name IS NOT NULL AND block_name != '' 
                 ORDER BY block_name ASC"
            );
            $stmt->bind_param("s", $districtId);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }

        $sql = "SELECT sno AS id, block_name AS name, tehseel_id, district_id 
                FROM master_block 
                WHERE block_name IS NOT NULL AND block_name != '' 
                ORDER BY block_name ASC";
        $result = $this->db->query($sql);
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }

    /**
     * Get Registered PACS Societies from test2
     * col2 = District ID, col5 = Tehseel ID, col6 = Block ID, col4 = Society Name
     */
    public function getPacs(?string $districtId = null, ?string $blockId = null, ?string $tehseelId = null): array {
        $conditions = ["sno > 1", "col4 IS NOT NULL", "col4 != ''", "(status = '0' OR status IS NULL)"];
        $params = [];
        $types = "";

        if ($districtId !== null && $districtId !== '') {
            $conditions[] = "col2 = ?";
            $params[] = $districtId;
            $types .= "s";
        }

        if ($blockId !== null && $blockId !== '') {
            $conditions[] = "col6 = ?";
            $params[] = $blockId;
            $types .= "s";
        } elseif ($tehseelId !== null && $tehseelId !== '') {
            $conditions[] = "col5 = ?";
            $params[] = $tehseelId;
            $types .= "s";
        }

        $whereSql = implode(" AND ", $conditions);
        $sql = "SELECT sno AS id, col4 AS name, col2 AS district_id, col5 AS tehseel_id, col6 AS block_id, 
                       col7 AS address, col36 AS pincode, col31 AS sachiv_name, col32 AS contact_no 
                FROM test2 
                WHERE $whereSql 
                ORDER BY col4 ASC";

        if (!empty($params)) {
            $stmt = $this->db->prepare($sql);
            $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }

        $sql .= " LIMIT 500";
        $result = $this->db->query($sql);
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }
}
