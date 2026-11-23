<?php
/**
 * Category Data Model
 * Technology: MySQLi Prepared Statements
 * Follows SOP Standards
 */

declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';

class Category {
    private mysqli $db;

    public function __construct() {
        $this->db = Database::getConnection();
    }

    /**
     * Get all categories (optionally filter by status: 1 = active)
     */
    public function getAll(?int $status = null): array {
        if ($status !== null) {
            $stmt = $this->db->prepare("SELECT * FROM categories WHERE status = ? ORDER BY id ASC");
            $stmt->bind_param("i", $status);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }

        $result = $this->db->query("SELECT * FROM categories ORDER BY id DESC");
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }

    /**
     * Create new category
     */
    public function create(string $name, string $icon = '🛠️', ?string $description = null): int {
        $stmt = $this->db->prepare("INSERT INTO categories (name, icon, description, status) VALUES (?, ?, ?, 1)");
        $stmt->bind_param("sss", $name, $icon, $description);
        $stmt->execute();
        $newId = (int)$this->db->insert_id;
        $stmt->close();
        return $newId;
    }

    /**
     * Delete category by ID
     */
    public function delete(int $id): bool {
        $stmt = $this->db->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
