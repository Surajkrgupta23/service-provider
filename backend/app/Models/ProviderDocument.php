<?php
/**
 * ProviderDocument Model
 * Repository Pattern with MySQLi Prepared Statements
 * Stores and manages individual partner KYC documents
 */

declare(strict_types=1);

require_once __DIR__ . '/../../config/database.php';

class ProviderDocument {
    private mysqli $db;

    public function __construct() {
        $this->db = Database::getConnection();
    }

    /**
     * Add a document for a provider
     */
    public function addDocument(int $providerId, string $docType, string $docNumber, ?string $filePath): int {
        $stmt = $this->db->prepare("
            INSERT INTO provider_documents (provider_id, document_type, document_number, file_path, verification_status)
            VALUES (?, ?, ?, ?, 'pending')
        ");
        $stmt->bind_param("isss", $providerId, $docType, $docNumber, $filePath);
        $stmt->execute();
        $insertId = (int)$this->db->insert_id;
        $stmt->close();
        return $insertId;
    }

    /**
     * Get all documents for a provider
     */
    public function getByProviderId(int $providerId): array {
        $stmt = $this->db->prepare("
            SELECT * FROM provider_documents WHERE provider_id = ? ORDER BY id ASC
        ");
        $stmt->bind_param("i", $providerId);
        $stmt->execute();
        $result = $stmt->get_result();
        $rows = $result->fetch_all(MYSQLI_ASSOC);
        $stmt->close();
        return $rows;
    }

    /**
     * Update verification status of a document
     */
    public function updateStatus(int $id, string $status, ?string $reason = null): bool {
        $stmt = $this->db->prepare("
            UPDATE provider_documents SET verification_status = ?, rejection_reason = ? WHERE id = ?
        ");
        $stmt->bind_param("ssi", $status, $reason, $id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
