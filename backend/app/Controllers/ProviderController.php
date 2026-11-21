<?php
/**
 * Provider & Dashboard Controller
 * Enforces Verification Approval & Serves Dashboard Data
 * Follows SOP Standards: Section 8, 9, 12
 */

declare(strict_types=1);

require_once __DIR__ . '/../Models/Provider.php';
require_once __DIR__ . '/../Helpers/Response.php';

class ProviderController {
    private Provider $providerModel;

    public function __construct() {
        $this->providerModel = new Provider();
    }

    /**
     * Resolve Provider from Bearer Token or Header/Param
     */
    private function authenticate(): ?array {
        $token = null;

        // 1. From Authorization Header
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        if (preg_match('/Bearer\s+(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
        }

        // 2. Fallback to GET or POST param
        if (!$token) {
            $token = $_GET['token'] ?? $_POST['token'] ?? null;
        }

        if (!$token) {
            return null;
        }

        return $this->providerModel->findByToken($token);
    }

    /**
     * Check Live Verification Status
     * GET /api/status
     */
    public function getStatus(): void {
        $provider = $this->authenticate();
        if (!$provider) {
            Response::unauthorized('Invalid or missing authentication session. Please log in.');
            return;
        }

        unset($provider['password']);

        Response::success('Status retrieved successfully', [
            'provider_id'         => (int)$provider['id'],
            'name'                => $provider['name'],
            'category'            => $provider['category'],
            'verification_status' => $provider['verification_status'],
            'rejection_reason'    => $provider['rejection_reason'],
            'is_verified'         => ($provider['verification_status'] === 'verified'),
            'updated_at'          => $provider['updated_at']
        ]);
    }

    /**
     * Provider Dashboard (Only accessible when verified)
     * GET /api/dashboard
     */
    public function getDashboard(): void {
        $provider = $this->authenticate();
        if (!$provider) {
            Response::unauthorized('Authentication required to access dashboard.');
            return;
        }

        // Enforce Verification Rule: Only 'verified' providers can access dashboard
        if ($provider['verification_status'] !== 'verified') {
            Response::forbidden("Access restricted. Your account status is '{$provider['verification_status']}'. Waiting for admin verification.");
            return;
        }

        unset($provider['password']);

        // Dashboard Data
        $dashboardData = [
            'welcome_message' => 'Thank you for joining CP Clap, we will serve soon',
            'provider'        => [
                'id'       => (int)$provider['id'],
                'name'     => $provider['name'],
                'phone'    => $provider['phone'],
                'email'    => $provider['email'],
                'category' => $provider['category'],
                'city'     => $provider['city'],
                'status'   => $provider['verification_status'],
                'is_online'=> (bool)$provider['is_online']
            ],
            'metrics' => [
                'today_earnings'   => '₹0.00',
                'this_month'       => '₹0.00',
                'completed_jobs'   => 0,
                'active_requests'  => 0,
                'rating'           => 5.0
            ],
            'recent_requests' => []
        ];

        Response::success('Dashboard loaded successfully', $dashboardData);
    }

    /**
     * Quick status update helper (for external testing / admin use)
     * POST /api/admin/update-status
     */
    public function updateStatus(array $input): void {
        $providerId = (int)($input['provider_id'] ?? 0);
        $status     = trim($input['status'] ?? '');
        $reason     = $input['reason'] ?? null;

        $validStatuses = ['pending_verification', 'under_review', 'verified', 'rejected'];
        if (!in_array($status, $validStatuses)) {
            Response::error('Invalid status. Allowed: ' . implode(', ', $validStatuses));
            return;
        }

        $provider = $this->providerModel->findById($providerId);
        if (!$provider) {
            Response::error('Provider not found', null, 404);
            return;
        }

        $this->providerModel->updateStatus($providerId, $status, $reason);

        Response::success("Provider status updated to {$status}", [
            'provider_id' => $providerId,
            'status'      => $status
        ]);
    }

    /**
     * Get Master Categories
     * GET /api/categories
     */
    public function getCategories(): void {
        $categories = $this->providerModel->getCategories();
        Response::success('Categories loaded', $categories);
    }
}
