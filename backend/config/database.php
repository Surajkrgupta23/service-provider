<?php
/**
 * Database Configuration & Connection
 * Technology: Core PHP MySQLi with Prepared Statements
 * Follows SOP Standards: Section 8, 10 & 17 (.env Configured)
 */

declare(strict_types=1);

require_once __DIR__ . '/app.php';

class Database {
    private static ?mysqli $instance = null;

    public static function getConnection(): mysqli {
        if (self::$instance === null) {
            // Read all credentials centrally from .env via Env::get()
            $host     = (string)Env::get('DB_HOST', '127.0.0.1');
            $port     = (int)Env::get('DB_PORT', 3306);
            $dbName   = (string)Env::get('DB_NAME', 'cp_clap_db');
            $username = (string)Env::get('DB_USER', 'root');
            $password = (string)Env::get('DB_PASS', 'mysql');

            mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

            try {
                $conn = new mysqli($host, $username, $password, $dbName, $port);
                $conn->set_charset((string)Env::get('DB_CHARSET', 'utf8mb4'));
                self::$instance = $conn;
            } catch (mysqli_sql_exception $e) {
                try {
                    $initConn = new mysqli($host, $username, $password, '', $port);
                    $initConn->query("CREATE DATABASE IF NOT EXISTS `{$dbName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                    $initConn->close();

                    $conn = new mysqli($host, $username, $password, $dbName, $port);
                    $conn->set_charset('utf8mb4');
                    self::$instance = $conn;
                } catch (Exception $ex) {
                    http_response_code(500);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Database connection failed: ' . $ex->getMessage(),
                        'data'    => null,
                        'errors'  => null
                    ]);
                    exit;
                }
            }
        }

        return self::$instance;
    }
}
