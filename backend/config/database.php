<?php
/**
 * Database Configuration & Connection
 * Technology: Core PHP MySQLi with Prepared Statements
 * Follows SOP Standards: Section 8 & Section 10 (UTF8mb4, Transactions, Security)
 */

declare(strict_types=1);

class Database {
    private static ?mysqli $instance = null;

    public static function getConnection(): mysqli {
        if (self::$instance === null) {
            $host     = '127.0.0.1';
            $port     = 3306;
            $dbName   = 'cp_clap_db';
            $username = 'root';
            $password = 'mysql';

            // Enable strict error reporting
            mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

            try {
                $conn = new mysqli($host, $username, $password, $dbName, $port);
                $conn->set_charset('utf8mb4');
                self::$instance = $conn;
            } catch (mysqli_sql_exception $e) {
                // If database does not exist, initialize it
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
