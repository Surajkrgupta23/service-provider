<?php
/**
 * Standard REST API Response Helper
 * Follows SOP Section 9: REST API Standards
 */

declare(strict_types=1);

class Response {
    public static function json(bool $success, string $message, $data = null, $errors = null, int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=UTF-8');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data'    => $data,
            'errors'  => $errors
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function success(string $message, $data = null, int $statusCode = 200): void {
        self::json(true, $message, $data, null, $statusCode);
    }

    public static function error(string $message, $errors = null, int $statusCode = 400): void {
        self::json(false, $message, null, $errors, $statusCode);
    }

    public static function unauthorized(string $message = 'Unauthorized access'): void {
        self::json(false, $message, null, null, 401);
    }

    public static function forbidden(string $message = 'Forbidden access'): void {
        self::json(false, $message, null, null, 403);
    }

    public static function validationError(array $errors, string $message = 'Validation failed'): void {
        self::json(false, $message, null, $errors, 422);
    }
}
