<?php
/**
 * Provider Data Model
 * Repository Pattern with MySQLi Prepared Statements
 * Prevents SQL Injection & Follows SOP Standards
 */

declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';

class Provider {
    private mysqli $db;

    public function __construct() {
        $this->db = Database::getConnection();
    }

    public function findByPhone(string $phone): ?array {
        $stmt = $this->db->prepare("SELECT * FROM providers WHERE phone = ? LIMIT 1");
        $stmt->bind_param("s", $phone);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        return $row ?: null;
    }

    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("SELECT * FROM providers WHERE email = ? LIMIT 1");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        return $row ?: null;
    }

    public function findById(int $id): ?array {
        $stmt = $this->db->prepare("SELECT * FROM providers WHERE id = ? LIMIT 1");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        return $row ?: null;
    }

    public function findByToken(string $token): ?array {
        $stmt = $this->db->prepare("SELECT * FROM providers WHERE auth_token = ? LIMIT 1");
        $stmt->bind_param("s", $token);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        return $row ?: null;
    }

    public function create(array $data): int {
        $sql = "INSERT INTO providers (
            name, phone, email, password, category, experience_years, 
            city, id_type, id_number, id_document, verification_status, 
            auth_token, token_expires_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $stmt = $this->db->prepare($sql);
        
        $name        = $data['name'];
        $phone       = $data['phone'];
        $email       = $data['email'];
        $password    = $data['password'];
        $category    = $data['category'];
        $expYears    = (int)($data['experience_years'] ?? 0);
        $city        = $data['city'];
        $idType      = $data['id_type'] ?? null;
        $idNumber    = $data['id_number'] ?? null;
        $idDocument  = $data['id_document'] ?? null;
        $status      = $data['verification_status'] ?? 'pending_verification';
        $authToken   = $data['auth_token'];
        $expiresAt   = $data['token_expires_at'] ?? null;

        $stmt->bind_param(
            "sssssisssssss",
            $name, $phone, $email, $password, $category, $expYears,
            $city, $idType, $idNumber, $idDocument, $status,
            $authToken, $expiresAt
        );

        $stmt->execute();
        $newId = (int)$this->db->insert_id;
        $stmt->close();

        return $newId;
    }

    public function updateToken(int $id, string $token, ?string $expiresAt = null): bool {
        $stmt = $this->db->prepare("UPDATE providers SET auth_token = ?, token_expires_at = ? WHERE id = ?");
        $stmt->bind_param("ssi", $token, $expiresAt, $id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function updateStatus(int $id, string $status, ?string $reason = null): bool {
        $stmt = $this->db->prepare("UPDATE providers SET verification_status = ?, rejection_reason = ? WHERE id = ?");
        $stmt->bind_param("ssi", $status, $reason, $id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function getAll(?string $status = null): array {
        if ($status && in_array($status, ['pending_verification', 'under_review', 'verified', 'rejected'])) {
            $stmt = $this->db->prepare("SELECT id, name, phone, email, category, city, verification_status, rejection_reason, created_at FROM providers WHERE verification_status = ? ORDER BY id DESC");
            $stmt->bind_param("s", $status);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
            return $rows;
        }
        $result = $this->db->query("SELECT id, name, phone, email, category, city, verification_status, rejection_reason, created_at FROM providers ORDER BY id DESC");
        return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    }
}
