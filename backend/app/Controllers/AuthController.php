<?php
/**
 * Authentication Controller
 * Handles Service Provider Registration, Password & OTP Login
 * Follows SOP Section 8, 9, 12
 */

declare(strict_types=1);

require_once __DIR__ . '/../Models/Provider.php';
require_once __DIR__ . '/../Models/ProviderDocument.php';
require_once __DIR__ . '/../Helpers/Response.php';

class AuthController {
    private Provider $providerModel;
    private ProviderDocument $documentModel;

    public function __construct() {
        $this->providerModel = new Provider();
        $this->documentModel = new ProviderDocument();
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

        // Bank Details Validation (Required)
        $bankName      = trim($input['bank_name'] ?? '');
        $accHolderName = trim($input['account_holder_name'] ?? '') ?: $name;
        $accNumber     = trim($input['account_number'] ?? '');
        $ifscCode      = strtoupper(trim($input['ifsc_code'] ?? ''));
        $bankBranch    = trim($input['bank_branch'] ?? '');

        if (empty($bankName)) {
            $errors['bank_name'] = ['बैंक का नाम दर्ज करना आवश्यक है (Bank Name required).'];
        }
        if (empty($accNumber) || strlen($accNumber) < 6) {
            $errors['account_number'] = ['मान्य बैंक खाता संख्या दर्ज करें (Valid Account Number required).'];
        }
        if (empty($ifscCode) || strlen($ifscCode) < 8) {
            $errors['ifsc_code'] = ['मान्य IFSC कोड दर्ज करें (Valid IFSC Code required).'];
        }

        // Check if phone or email already registered
        if ($this->providerModel->findByPhone($phone)) {
            $errors['phone'] = ['यह मोबाइल नंबर पहले से पंजीकृत है (Phone already registered).'];
        }

        if ($this->providerModel->findByEmail($email)) {
            $errors['email'] = ['यह ईमेल पहले से पंजीकृत है (Email already registered).'];
        }

        // 1. Handle Profile Photo (Compressed base64 or file upload)
        $profilePhoto = null;
        if (!empty($input['profile_photo_base64'])) {
            $photoData = $input['profile_photo_base64'];
            if (preg_match('/^data:image\/(\w+);base64,/', $photoData)) {
                $photoData = substr($photoData, strpos($photoData, ',') + 1);
            }
            $photoDecoded = base64_decode($photoData);
            if ($photoDecoded !== false) {
                $dir = __DIR__ . '/../../../uploads/photos/';
                if (!is_dir($dir)) mkdir($dir, 0755, true);
                $pFilename = 'photo_' . time() . '_' . bin2hex(random_bytes(4)) . '.jpg';
                file_put_contents($dir . $pFilename, $photoDecoded);
                $profilePhoto = 'uploads/photos/' . $pFilename;
            }
        } elseif (isset($files['profile_photo']) && $files['profile_photo']['error'] === UPLOAD_ERR_OK) {
            $dir = __DIR__ . '/../../../uploads/photos/';
            if (!is_dir($dir)) mkdir($dir, 0755, true);
            $ext = strtolower(pathinfo($files['profile_photo']['name'], PATHINFO_EXTENSION));
            $pFilename = 'photo_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
            if (move_uploaded_file($files['profile_photo']['tmp_name'], $dir . $pFilename)) {
                $profilePhoto = 'uploads/photos/' . $pFilename;
            }
        }

        // 2. Handle Multiple Dynamic KYC Documents (At least 3 required)
        $rawDocs = $input['documents'] ?? [];
        if (is_string($rawDocs)) {
            $rawDocs = json_decode($rawDocs, true) ?: [];
        }

        $processedDocs = [];
        $docsDir = __DIR__ . '/../../../uploads/docs/';
        if (!is_dir($docsDir)) mkdir($docsDir, 0755, true);

        foreach ($rawDocs as $idx => $d) {
            $docType   = trim($d['type'] ?? '');
            $docNumber = trim($d['number'] ?? '');
            $docPath   = null;

            if (!empty($d['file_base64'])) {
                $fileData = $d['file_base64'];
                if (preg_match('/^data:(image\/\w+|application\/pdf);base64,/', $fileData)) {
                    $fileData = substr($fileData, strpos($fileData, ',') + 1);
                }
                $fileDecoded = base64_decode($fileData);
                if ($fileDecoded !== false) {
                    $dFilename = 'doc_' . time() . '_' . $idx . '_' . bin2hex(random_bytes(3)) . '.jpg';
                    file_put_contents($docsDir . $dFilename, $fileDecoded);
                    $docPath = 'uploads/docs/' . $dFilename;
                }
            }

            if (!empty($docType) && !empty($docNumber)) {
                $processedDocs[] = [
                    'type'   => $docType,
                    'number' => $docNumber,
                    'file'   => $docPath
                ];
            }
        }

        if (count($processedDocs) < 2) {
            $errors['documents'] = ['कम से कम 2 वैध दस्तावेज़ (आधार कार्ड व पैन कार्ड) जोड़ना आवश्यक है (Aadhaar & PAN Required).'];
        }

        if (empty($profilePhoto)) {
            $errors['profile_photo'] = ['पार्टनर प्रोफाइल फोटो अपलोड करना आवश्यक है (Profile photo required).'];
        }

        if (!empty($errors)) {
            Response::validationError($errors, 'कृपया सभी आवश्यक फ़ील्ड एवं आधार व पैन कार्ड भरें।');
            return;
        }

        $primaryDoc = $processedDocs[0] ?? null;
        $idType = $primaryDoc['type'] ?? $idType;
        $idNumber = $primaryDoc['number'] ?? $idNumber;
        $uploadedDoc = $primaryDoc['file'] ?? null;
        $idDocumentsJson = json_encode($processedDocs, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        // PACS & Location Fields
        $districtId   = !empty($input['district_id']) ? $input['district_id'] : null;
        $districtName = trim((string)($input['district_name'] ?? ''));
        $tehseelId    = !empty($input['tehseel_id']) ? $input['tehseel_id'] : null;
        $tehseelName  = trim((string)($input['tehseel_name'] ?? ''));
        $blockId      = !empty($input['block_id']) ? $input['block_id'] : null;
        $blockName    = trim((string)($input['block_name'] ?? ''));
        $pacsId       = !empty($input['pacs_id']) ? $input['pacs_id'] : null;
        $pacsName     = trim((string)($input['pacs_name'] ?? ''));

        // Password Storage (Plain text as requested)
        $storedPassword = $password;

        // Secure Authentication Token
        $token     = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

        $providerId = $this->providerModel->create([
            'name'                => $name,
            'phone'               => $phone,
            'email'               => $email,
            'password'            => $storedPassword,
            'category'            => $category,
            'experience_years'    => $expYears,
            'city'                => $city,
            'id_type'             => $idType,
            'id_number'           => $idNumber,
            'id_document'         => $uploadedDoc,
            'id_documents_json'   => $idDocumentsJson,
            'profile_photo'       => $profilePhoto,
            'verification_status' => 'pending_verification',
            'auth_token'          => $token,
            'token_expires_at'    => $expiresAt,
            'district_id'         => $districtId,
            'district_name'       => $districtName,
            'tehseel_id'          => $tehseelId,
            'tehseel_name'        => $tehseelName,
            'block_id'            => $blockId,
            'block_name'          => $blockName,
            'pacs_id'             => $pacsId,
            'pacs_name'           => $pacsName,
            'bank_name'           => $bankName,
            'account_holder_name' => $accHolderName,
            'account_number'      => $accNumber,
            'ifsc_code'           => $ifscCode,
            'bank_branch'         => $bankBranch,
        ]);

        // Save each document in the dedicated provider_documents table
        foreach ($processedDocs as $doc) {
            $this->documentModel->addDocument(
                $providerId,
                $doc['type'],
                $doc['number'],
                $doc['file']
            );
        }

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
        $loginId  = trim($input['login_id'] ?? ($input['phone'] ?? ''));
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

        $passwordValid = ($provider && ($provider['password'] === $password || password_verify($password, $provider['password'])));
        if (!$provider || !$passwordValid) {
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
