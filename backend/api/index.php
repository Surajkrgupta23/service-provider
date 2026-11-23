<?php
/**
 * REST API Central Router
 * Technology: Core PHP
 * Follows SOP Section 8 & Section 9
 */

declare(strict_types=1);

ini_set('display_errors', '0');
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/../app/Helpers/Response.php';
require_once __DIR__ . '/../app/Controllers/AuthController.php';
require_once __DIR__ . '/../app/Controllers/ProviderController.php';
require_once __DIR__ . '/../app/Controllers/AdminController.php';
require_once __DIR__ . '/../app/Models/Location.php';

// Parse JSON payload or multipart form data
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
$inputData = [];
if (stripos($contentType, 'application/json') !== false) {
    $rawInput = file_get_contents('php://input');
    $inputData = json_decode($rawInput, true) ?: [];
} else {
    $inputData = array_merge($_GET, $_POST);
}

// Router by 'action' parameter
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

$authController     = new AuthController();
$providerController = new ProviderController();
$adminController    = new AdminController();
$locationModel      = new Location();

try {
    switch ($action) {
        case 'categories':
            if ($method === 'GET') {
                $providerController->getCategories();
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'districts':
            if ($method === 'GET') {
                Response::success('Districts loaded', $locationModel->getDistricts());
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'tehseels':
            if ($method === 'GET') {
                $districtId = $_GET['district_id'] ?? null;
                Response::success('Tehseels loaded', $locationModel->getTehseels($districtId ? (string)$districtId : null));
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'blocks':
            if ($method === 'GET') {
                $districtId = $_GET['district_id'] ?? null;
                $tehseelId  = $_GET['tehseel_id'] ?? null;
                Response::success('Blocks loaded', $locationModel->getBlocks(
                    $districtId ? (string)$districtId : null, 
                    $tehseelId ? (string)$tehseelId : null
                ));
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'pacs':
            if ($method === 'GET') {
                $districtId = $_GET['district_id'] ?? null;
                $blockId    = $_GET['block_id'] ?? null;
                $tehseelId  = $_GET['tehseel_id'] ?? null;
                Response::success('PACS loaded', $locationModel->getPacs(
                    $districtId ? (string)$districtId : null,
                    $blockId ? (string)$blockId : null,
                    $tehseelId ? (string)$tehseelId : null
                ));
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'send-otp':
            if ($method === 'POST') {
                $authController->sendOtp($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'verify-otp':
            if ($method === 'POST') {
                $authController->verifyOtp($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'register':
            if ($method === 'POST') {
                $authController->register($inputData, $_FILES);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'login':
            if ($method === 'POST') {
                $authController->login($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'status':
            if ($method === 'GET' || $method === 'POST') {
                $providerController->getStatus();
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'dashboard':
            if ($method === 'GET') {
                $providerController->getDashboard();
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        // ================= ADMIN OPERATIONS (AdminController) =================
        case 'admin-update-status':
            if ($method === 'POST') {
                $adminController->updateProviderStatus($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'admin-list-providers':
            if ($method === 'GET' || $method === 'POST') {
                $adminController->listProviders();
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'admin-list-categories':
            if ($method === 'GET' || $method === 'POST') {
                $adminController->listCategories();
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'admin-add-category':
            if ($method === 'POST') {
                $adminController->addCategory($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        case 'admin-delete-category':
            if ($method === 'POST') {
                $adminController->deleteCategory($inputData);
            } else {
                Response::error('Method not allowed', null, 405);
            }
            break;

        default:
            Response::error("Invalid API endpoint: action='{$action}'", null, 404);
            break;
    }
} catch (Throwable $e) {
    Response::error('Internal Server Error: ' . $e->getMessage(), null, 500);
}
