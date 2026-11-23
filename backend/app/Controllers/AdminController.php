<?php
/**
 * Admin Controller
 * Path: backend/app/Controllers/AdminController.php
 * Handles Admin Operations: Partner Verification & Category Management
 */

declare(strict_types=1);

require_once __DIR__ . '/../Models/Provider.php';
require_once __DIR__ . '/../Models/Category.php';
require_once __DIR__ . '/../Helpers/Response.php';

class AdminController {
    private Provider $providerModel;
    private Category $categoryModel;

    public function __construct() {
        $this->providerModel = new Provider();
        $this->categoryModel = new Category();
    }

    /**
     * List all providers for Admin
     * GET /api?action=admin-list-providers
     */
    public function listProviders(): void {
        $status = $_GET['status'] ?? null;
        $providers = $this->providerModel->getAll($status);
        Response::success('Providers retrieved successfully', [
            'total'     => count($providers),
            'providers' => $providers
        ]);
    }

    /**
     * Update Provider Verification Status
     * POST /api?action=admin-update-status
     */
    public function updateProviderStatus(array $input): void {
        $providerId = (int)($input['provider_id'] ?? 0);
        $status     = trim($input['status'] ?? '');
        $reason     = $input['reason'] ?? null;

        $validStatuses = ['pending_verification', 'under_review', 'verified', 'rejected'];
        if (!in_array($status, $validStatuses, true)) {
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
     * List all categories for Admin
     * GET /api?action=admin-list-categories
     */
    public function listCategories(): void {
        $categories = $this->categoryModel->getAll();
        Response::success('Categories loaded successfully', [
            'total'      => count($categories),
            'categories' => $categories
        ]);
    }

    /**
     * Add new category by Admin
     * POST /api?action=admin-add-category
     */
    public function addCategory(array $input): void {
        $name = trim($input['name'] ?? '');
        $icon = trim($input['icon'] ?? '🛠️');
        $description = trim($input['description'] ?? '');

        if (empty($name)) {
            Response::validationError(['name' => ['Category name is required.']]);
            return;
        }

        try {
            $newId = $this->categoryModel->create($name, $icon, $description);
            Response::success('Category created successfully', [
                'id'          => $newId,
                'name'        => $name,
                'icon'        => $icon,
                'description' => $description
            ], 201);
        } catch (Throwable $e) {
            Response::error('Failed to create category: ' . $e->getMessage(), null, 400);
        }
    }

    /**
     * Delete category by Admin
     * POST /api?action=admin-delete-category
     */
    public function deleteCategory(array $input): void {
        $id = (int)($input['id'] ?? 0);
        if ($id <= 0) {
            Response::error('Invalid Category ID', null, 400);
            return;
        }

        $this->categoryModel->delete($id);
        Response::success('Category deleted successfully', ['id' => $id]);
    }
}
