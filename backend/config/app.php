<?php
/**
 * Application Environment Loader
 * Follows SOP Section 8 ("config/app.php, config/database.php, .env")
 */

declare(strict_types=1);

class Env {
    private static array $variables = [];

    public static function load(string $path): void {
        if (!file_exists($path)) {
            return;
        }

        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line) || str_starts_with($line, '#')) {
                continue;
            }
            if (strpos($line, '=') !== false) {
                [$key, $value] = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value, " \t\n\r\0\x0B\"'");
                self::$variables[$key] = $value;
                putenv("{$key}={$value}");
                $_ENV[$key] = $value;
            }
        }
    }

    public static function get(string $key, $default = null) {
        if (array_key_exists($key, self::$variables)) {
            return self::$variables[$key];
        }
        $val = getenv($key);
        return $val !== false ? $val : $default;
    }
}

// Automatically load .env
Env::load(__DIR__ . '/../.env');
