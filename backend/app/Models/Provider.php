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
            city, id_type, id_number, id_document, id_documents_json, profile_photo, verification_status, 
            auth_token, token_expires_at,
            district_id, district_name, tehseel_id, tehseel_name, block_id, block_name, pacs_id, pacs_name,
            bank_name, account_holder_name, account_number, ifsc_code, bank_branch
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $stmt = $this->db->prepare($sql);
        
        $name             = $data['name'];
        $phone            = $data['phone'];
        $email            = $data['email'];
        $password         = $data['password'];
        $category         = $data['category'];
        $expYears         = (int)($data['experience_years'] ?? 0);
        $city             = $data['city'];
        $idType           = $data['id_type'] ?? null;
        $idNumber         = $data['id_number'] ?? null;
        $idDocument       = $data['id_document'] ?? null;
        $idDocumentsJson  = $data['id_documents_json'] ?? null;
        $profilePhoto     = $data['profile_photo'] ?? null;
        $status           = $data['verification_status'] ?? 'pending_verification';
        $authToken        = $data['auth_token'];
        $expiresAt        = $data['token_expires_at'] ?? null;
        $districtId       = isset($data['district_id']) && $data['district_id'] !== '' ? (int)$data['district_id'] : null;
        $districtName     = $data['district_name'] ?? null;
        $tehseelId        = isset($data['tehseel_id']) && $data['tehseel_id'] !== '' ? (int)$data['tehseel_id'] : null;
        $tehseelName      = $data['tehseel_name'] ?? null;
        $blockId          = isset($data['block_id']) && $data['block_id'] !== '' ? (int)$data['block_id'] : null;
        $blockName        = $data['block_name'] ?? null;
        $pacsId           = isset($data['pacs_id']) && $data['pacs_id'] !== '' ? (int)$data['pacs_id'] : null;
        $pacsName         = $data['pacs_name'] ?? null;
        $bankName         = $data['bank_name'] ?? null;
        $accHolderName    = $data['account_holder_name'] ?? null;
        $accNumber        = $data['account_number'] ?? null;
        $ifscCode         = $data['ifsc_code'] ?? null;
        $bankBranch       = $data['bank_branch'] ?? null;

        $stmt->bind_param(
            "sssssisssssssssisisisissssss",
            $name, $phone, $email, $password, $category, $expYears,
            $city, $idType, $idNumber, $idDocument, $idDocumentsJson, $profilePhoto, $status,
            $authToken, $expiresAt,
            $districtId, $districtName, $tehseelId, $tehseelName, $blockId, $blockName, $pacsId, $pacsName,
            $bankName, $accHolderName, $accNumber, $ifscCode, $bankBranch
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
        $fields = "id, name, phone, email, category, city, profile_photo, district_name, tehseel_name, block_name, pacs_name, bank_name, account_holder_name, account_number, ifsc_code, bank_branch, verification_status, rejection_reason, created_at";
        if ($status && in_array($status, ['pending_verification', 'under_review', 'verified', 'rejected'])) {
            $stmt = $this->db->prepare("SELECT {$fields} FROM providers WHERE verification_status = ? ORDER BY id DESC");
            $stmt->bind_param("s", $status);
            $stmt->execute();
            $result = $stmt->get_result();
            $rows = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();
        } else {
            $result = $this->db->query("SELECT {$fields} FROM providers ORDER BY id DESC");
            $rows = $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
        }

        if (!empty($rows)) {
            $ids = array_column($rows, 'id');
            $idList = implode(',', array_map('intval', $ids));
            $docRes = $this->db->query("SELECT * FROM provider_documents WHERE provider_id IN ({$idList}) ORDER BY id ASC");
            $docsByProvider = [];
            if ($docRes) {
                while ($doc = $docRes->fetch_assoc()) {
                    $docsByProvider[$doc['provider_id']][] = $doc;
                }
            }
            foreach ($rows as &$r) {
                $r['documents'] = $docsByProvider[$r['id']] ?? [];
            }
        }

        return $rows;
    }
}
