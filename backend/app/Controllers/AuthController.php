<?php
/**
 * Authentication Controller
 * Handles Service Provider Registration, Password & OTP Login
 * Follows SOP Section 8, 9, 12
 */

declare(strict_types=1);

require_once __DIR__ . '/../Models/Provider.php';
require_once __DIR__ . '/../Helpers/Response.php';

class AuthController {
    private Provider $providerModel;

    public function __construct() {
        $this->providerModel = new Provider();
    }

    /**
     * Send OTP for Mobile Login
     * POST /api/send-otp
     */
    public function sendOtp(array $input): void {
        $phone = trim($input['phone'] ?? '');

        if (empty($phone) || !preg_match('/^[0-9]{10}$/', $phone)) {
            Response::validationError([
                'phone' => ['कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें (Valid 10-digit mobile required).']
            ]);
            return;
        }

        // Check if provider exists
        $provider = $this->providerModel->findByPhone($phone);
        
        // For development/testing: Fixed OTP is 123456 (or 878786 as shown in design)
        $otp = '123456';

        Response::success('OTP सफलतापूर्वक भेजा गया (OTP sent successfully)', [
            'phone'       => $phone,
            'is_existing' => ($provider !== null),
            'otp_hint'    => $otp // visible for instant testing
        ]);
    }

    /**
     * Verify OTP & Authenticate
     * POST /api/verify-otp
     */
    public function verifyOtp(array $input): void {
        $phone = trim($input['phone'] ?? '');
        $otp   = trim($input['otp'] ?? '');

        if (empty($phone) || empty($otp)) {
            Response::validationError([
                'otp' => ['मोबाइल नंबर और OTP आवश्यक हैं (Phone & OTP required).']
            ]);
            return;
        }

        // Accept standard test OTP '123456' or '878786'
        if ($otp !== '123456' && $otp !== '878786') {
            Response::error('अमान्य OTP! कृपया सही OTP दर्ज करें (Invalid OTP. Try 123456).', null, 400);
            return;
        }

        $provider = $this->providerModel->findByPhone($phone);

        if (!$provider) {
            // New user, redirect to complete registration
            Response::success('OTP सत्यापित! कृपया पार्टनर प्रोफाइल रजिस्ट्रेशन पूरा करें।', [
                'needs_registration' => true,
                'phone'              => $phone
            ]);
            return;
        }

        // Existing provider: generate fresh token
        $token     = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
        $this->providerModel->updateToken((int)$provider['id'], $token, $expiresAt);

        unset($provider['password']);
        $provider['auth_token'] = $token;

        Response::success('लॉगिन सफल (Login successful)', [
            'needs_registration' => false,
            'provider'           => $provider,
            'auth_token'         => $token,
            'status'             => $provider['verification_status']
        ]);
    }

    /**
     * Provider Registration
     * POST /api/register
     */
    public function register(array $input, array $files = []): void {
        $errors = [];

        // Validation
        $name     = trim($input['name'] ?? '');
        $phone    = trim($input['phone'] ?? '');
        $email    = trim($input['email'] ?? '');
        $password = $input['password'] ?? '123456';
        $rawCategory = $input['category'] ?? '';
        if (is_array($rawCategory)) {
            $category = implode(', ', array_filter(array_map('trim', $rawCategory)));
        } else {
            $category = trim((string)$rawCategory);
        }
        $city     = trim($input['city'] ?? '');
        $expYears = (int)($input['experience_years'] ?? 0);
        $idType   = trim($input['id_type'] ?? 'Aadhar Card');
        $idNumber = trim($input['id_number'] ?? '');

        if (empty($name) || strlen($name) < 2) {
            $errors['name'] = ['पूरा नाम दर्ज करना आवश्यक है (Full name required).'];
        }

        if (empty($phone) || !preg_match('/^[0-9]{10}$/', $phone)) {
            $errors['phone'] = ['10 अंकों का मान्य मोबाइल नंबर दर्ज करें (10-digit mobile required).'];
        }

        if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = ['मान्य ईमेल पता दर्ज करें (Valid email required).'];
        }

        if (empty($category)) {
            $errors['category'] = ['कृपया अपनी सेवा श्रेणी/स्किल चुनें (Please select service category).'];
        }

        if (empty($city)) {
            $errors['city'] = ['कार्य क्षेत्र / शहर दर्ज करें (City required).'];
        }

        // Check if phone or email already registered
        if ($this->providerModel->findByPhone($phone)) {
            $errors['phone'] = ['यह मोबाइल नंबर पहले से पंजीकृत है (Phone already registered).'];
        }

        if ($this->providerModel->findByEmail($email)) {
            $errors['email'] = ['यह ईमेल पहले से पंजीकृत है (Email already registered).'];
        }

        if (!empty($errors)) {
            Response::validationError($errors, 'कृपया सभी आवश्यक फ़ील्ड सही तरीके से भरें।');
            return;
        }

        // Handle File Upload if provided
        $uploadedDoc = null;
        if (isset($files['id_document']) && $files['id_document']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/../../../uploads/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            $ext = strtolower(pathinfo($files['id_document']['name'], PATHINFO_EXTENSION));
            $allowedExts = ['jpg', 'jpeg', 'png', 'pdf'];
            if (in_array($ext, $allowedExts)) {
                $filename = 'id_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
                if (move_uploaded_file($files['id_document']['tmp_name'], $uploadDir . $filename)) {
                    $uploadedDoc = 'uploads/' . $filename;
                }
            }
        }

        // Password Hashing (SOP Section 12)
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

        // Secure Authentication Token
        $token     = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

        $providerId = $this->providerModel->create([
            'name'                => $name,
            'phone'               => $phone,
            'email'               => $email,
            'password'            => $hashedPassword,
            'category'            => $category,
            'experience_years'    => $expYears,
            'city'                => $city,
            'id_type'             => $idType,
            'id_number'           => $idNumber,
            'id_document'         => $uploadedDoc,
            'verification_status' => 'pending_verification',
            'auth_token'          => $token,
            'token_expires_at'    => $expiresAt,
        ]);

        $provider = $this->providerModel->findById($providerId);
        unset($provider['password']);

        Response::success('रजिस्ट्रेशन सबमिट हो गया! आपका खाता एडमिन सत्यापन के लिए लंबित है।', [
            'provider'   => $provider,
            'auth_token' => $token,
            'status'     => 'pending_verification'
        ], 201);
    }

    /**
     * Provider Password Login
     * POST /api/login
     */
    public function login(array $input): void {
        $loginId  = trim($input['login_id'] ?? '');
        $password = $input['password'] ?? '';

        if (empty($loginId) || empty($password)) {
            Response::validationError([
                'login' => ['मोबाइल नंबर/ईमेल और पासवर्ड आवश्यक हैं।']
            ]);
            return;
        }

        $provider = filter_var($loginId, FILTER_VALIDATE_EMAIL)
            ? $this->providerModel->findByEmail($loginId)
            : $this->providerModel->findByPhone($loginId);

        if (!$provider || !password_verify($password, $provider['password'])) {
            Response::error('अमान्य मोबाइल नंबर/ईमेल या पासवर्ड।', null, 401);
            return;
        }

        $token     = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
        $this->providerModel->updateToken((int)$provider['id'], $token, $expiresAt);

        unset($provider['password']);
        $provider['auth_token'] = $token;

        Response::success('लॉगिन सफल', [
            'provider'   => $provider,
            'auth_token' => $token,
            'status'     => $provider['verification_status']
        ]);
    }
}
