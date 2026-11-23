<?php
/**
 * Cooperative Clap - Admin Login
 * Path: backend/admin/login.php
 */

declare(strict_types=1);
session_start();

// If already logged in, redirect to dashboard
if (isset($_SESSION['admin_user'])) {
    header('Location: index.php');
    exit;
}

require_once __DIR__ . '/../config/database.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = trim($_POST['password'] ?? '');

    if ($username === '' || $password === '') {
        $error = 'कृपया Username और Password दोनों भरें।';
    } else {
        try {
            $db = Database::getConnection();
            $stmt = $db->prepare("SELECT * FROM admins WHERE username = ? LIMIT 1");
            $stmt->bind_param("s", $username);
            $stmt->execute();
            $res = $stmt->get_result();
            $admin = $res->fetch_assoc();
            $stmt->close();

            if ($admin && ($admin['password'] === $password || password_verify($password, $admin['password']))) {
                $_SESSION['admin_user'] = [
                    'id'       => $admin['id'],
                    'username' => $admin['username'],
                    'name'     => $admin['name'],
                    'email'    => $admin['email']
                ];
                header('Location: index.php');
                exit;
            } else {
                $error = 'गलत Username या Password! कृपया पुनः प्रयास करें।';
            }
        } catch (Throwable $e) {
            $error = 'Server Error: ' . $e->getMessage();
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — Cooperative Clap</title>
    <style>
        :root {
            --primary: #FF5E00;
            --primary-dark: #D44E00;
            --primary-light: #FFF0E6;
            --dark: #1E293B;
            --gray-100: #F8FAFC;
            --gray-200: #E2E8F0;
            --gray-400: #94A3B8;
            --gray-500: #64748B;
            --danger: #EF4444;
            --white: #FFFFFF;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        body {
            background: linear-gradient(135deg, #FFF5ED 0%, #F1F5F9 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .login-card {
            background: var(--white);
            width: 100%;
            max-width: 420px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--gray-200);
            padding: 36px 32px;
        }
        .brand-header {
            text-align: center;
            margin-bottom: 28px;
        }
        .logo {
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, #FF5E00, #FF8A00);
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 26px;
            font-weight: 800;
            box-shadow: 0 6px 16px rgba(255, 94, 0, 0.3);
            margin-bottom: 14px;
        }
        .brand-header h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--dark);
        }
        .brand-header p {
            font-size: 13px;
            color: var(--gray-500);
            margin-top: 4px;
        }
        .error-box {
            background: #FEE2E2;
            border: 1px solid #FCA5A5;
            color: #991B1B;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 8px;
        }
        .input-wrapper {
            position: relative;
        }
        .form-input {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 10px;
            font-size: 14px;
            color: var(--dark);
            outline: none;
            transition: all 0.2s;
        }
        .form-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(255, 94, 0, 0.12);
        }
        .submit-btn {
            width: 100%;
            background: var(--primary);
            color: white;
            border: none;
            padding: 13px;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 14px rgba(255, 94, 0, 0.25);
            margin-top: 8px;
        }
        .submit-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }
        .credentials-hint {
            margin-top: 24px;
            padding-top: 18px;
            border-top: 1px solid var(--gray-200);
            text-align: center;
            font-size: 12px;
            color: var(--gray-500);
            line-height: 1.6;
        }
        .credentials-hint strong {
            color: var(--dark);
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="brand-header">
            <div class="logo">CP</div>
            <h1>Admin Portal Login</h1>
            <p>Cooperative Clap Central Ecosystem</p>
        </div>

        <?php if (!empty($error)): ?>
            <div class="error-box"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <form method="POST" action="login.php">
            <div class="form-group">
                <label for="username">Admin Username</label>
                <div class="input-wrapper">
                    <input type="text" id="username" name="username" class="form-input" placeholder="admin" required autofocus value="<?= htmlspecialchars($_POST['username'] ?? '') ?>">
                </div>
            </div>

            <div class="form-group">
                <label for="password">Admin Password</label>
                <div class="input-wrapper">
                    <input type="password" id="password" name="password" class="form-input" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="submit-btn">लॉगिन करें (Sign In)</button>
        </form>

        <div class="credentials-hint">
            <div>🔑 Default Admin Credentials:</div>
            <div>Username: <strong>admin</strong> | Password: <strong>admin123</strong></div>
        </div>
    </div>

</body>
</html>
