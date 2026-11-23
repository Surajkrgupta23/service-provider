<?php
/**
 * Cooperative Clap - Central Web Admin Portal
 * Path: backend/admin/index.php
 * Modern Dashboard with Left Sidebar Navigation & Multi-App Management
 */

declare(strict_types=1);
session_start();

// Enforce Admin Authentication
if (!isset($_SESSION['admin_user'])) {
    header('Location: login.php');
    exit;
}

$admin = $_SESSION['admin_user'];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Cooperative Clap</title>
    <style>
        :root {
            --primary: #FF5E00;
            --primary-dark: #D44E00;
            --primary-light: #FFF0E6;
            --success: #10B981;
            --warning: #F59E0B;
            --danger: #EF4444;
            --dark: #0F172A;
            --sidebar-bg: #1E293B;
            --sidebar-hover: #334155;
            --sidebar-active: #FF5E00;
            --gray-50: #F8FAFC;
            --gray-100: #F1F5F9;
            --gray-200: #E2E8F0;
            --gray-400: #94A3B8;
            --gray-500: #64748B;
            --white: #FFFFFF;
            --sidebar-width: 260px;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        body {
            background-color: var(--gray-50);
            color: var(--dark);
            min-height: 100vh;
            display: flex;
        }

        /* ================= SIDEBAR (LEFT) ================= */
        aside.sidebar {
            width: var(--sidebar-width);
            background-color: var(--sidebar-bg);
            color: var(--white);
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            z-index: 100;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.08);
        }
        .sidebar-brand {
            padding: 24px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }
        .brand-logo {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, #FF5E00, #FF8A00);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            font-weight: 800;
            box-shadow: 0 4px 12px rgba(255, 94, 0, 0.35);
        }
        .brand-text h1 {
            font-size: 16px;
            font-weight: 700;
            color: var(--white);
            line-height: 1.2;
        }
        .brand-text p {
            font-size: 11px;
            color: var(--gray-400);
            margin-top: 2px;
        }

        .sidebar-menu {
            flex: 1;
            padding: 20px 14px;
            overflow-y: auto;
        }
        .menu-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--gray-400);
            padding: 10px 12px 6px;
            font-weight: 700;
        }
        .nav-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
            background: none;
            border: none;
            color: #CBD5E1;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 4px;
            text-align: left;
        }
        .nav-item:hover {
            background-color: var(--sidebar-hover);
            color: var(--white);
        }
        .nav-item.active {
            background-color: var(--primary);
            color: var(--white);
            box-shadow: 0 4px 12px rgba(255, 94, 0, 0.3);
        }
        .nav-item .nav-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .nav-badge {
            background: rgba(255, 255, 255, 0.15);
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }
        .nav-item.active .nav-badge {
            background: rgba(0, 0, 0, 0.2);
        }
        .sidebar-btn-add {
            width: 100%;
            background: rgba(255, 94, 0, 0.15);
            border: 1px dashed var(--primary);
            color: #FFA566;
            padding: 10px 14px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            margin-top: 10px;
            transition: all 0.2s;
        }
        .sidebar-btn-add:hover {
            background: var(--primary);
            color: white;
            border-style: solid;
        }

        .sidebar-user {
            padding: 16px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
        }
        .user-name {
            font-size: 13px;
            font-weight: 600;
            color: var(--white);
        }
        .user-role {
            font-size: 11px;
            color: var(--gray-400);
        }
        .btn-logout {
            background: rgba(239, 68, 68, 0.15);
            color: #FCA5A5;
            border: 1px solid rgba(239, 68, 68, 0.3);
            border-radius: 8px;
            padding: 6px 10px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-logout:hover {
            background: var(--danger);
            color: white;
        }

        /* ================= MAIN CONTENT (RIGHT) ================= */
        .main-wrapper {
            margin-left: var(--sidebar-width);
            flex: 1;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        header.top-header {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 36px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 40;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .page-title h2 {
            font-size: 20px;
            font-weight: 800;
            color: var(--dark);
        }
        .page-title p {
            font-size: 13px;
            color: var(--gray-500);
            margin-top: 2px;
        }
        .header-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .btn-action-primary {
            background: var(--primary);
            color: white;
            padding: 9px 18px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(255, 94, 0, 0.25);
        }
        .btn-action-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }

        main.content-body {
            padding: 32px 36px;
            max-width: 1400px;
            width: 100%;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 20px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: var(--white);
            padding: 22px;
            border-radius: 14px;
            border: 1px solid var(--gray-200);
            box-shadow: 0 2px 6px rgba(0,0,0,0.02);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .stat-title {
            font-size: 12px;
            color: var(--gray-500);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-value {
            font-size: 32px;
            font-weight: 800;
            margin-top: 8px;
            color: var(--dark);
        }
        .stat-card.all { border-left: 4px solid var(--primary); }
        .stat-card.pending { border-left: 4px solid var(--warning); }
        .stat-card.verified { border-left: 4px solid var(--success); }
        .stat-card.rejected { border-left: 4px solid var(--danger); }

        /* Tables & Content Cards */
        .content-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--gray-200);
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }
        .card-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }
        .card-title h3 {
            font-size: 17px;
            font-weight: 700;
            color: var(--dark);
        }
        .card-title p {
            font-size: 13px;
            color: var(--gray-500);
            margin-top: 2px;
        }
        .filters {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-btn {
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            color: var(--gray-500);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .filter-btn:hover {
            background: var(--gray-200);
            color: var(--dark);
        }
        .filter-btn.active {
            background: var(--primary);
            color: var(--white);
            border-color: var(--primary);
        }

        .table-responsive {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        th {
            background: var(--gray-100);
            padding: 14px 20px;
            font-size: 12px;
            font-weight: 700;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--gray-200);
        }
        td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--gray-200);
            font-size: 14px;
            vertical-align: middle;
        }
        tr:hover td {
            background-color: #FAFCFE;
        }
        .provider-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--primary-light);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 15px;
        }
        .provider-name {
            font-weight: 600;
            color: var(--dark);
        }
        .provider-id {
            font-size: 12px;
            color: var(--gray-500);
        }
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: capitalize;
        }
        .badge.pending_verification {
            background: #FEF3C7;
            color: #92400E;
        }
        .badge.under_review {
            background: #E0E7FF;
            color: #3730A3;
        }
        .badge.verified {
            background: #D1FAE5;
            color: #065F46;
        }
        .badge.rejected {
            background: #FEE2E2;
            color: #991B1B;
        }
        .badge.active {
            background: #D1FAE5;
            color: #065F46;
        }
        .skills-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            max-width: 250px;
        }
        .chip {
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            color: var(--dark);
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
        }
        .action-btns {
            display: flex;
            gap: 8px;
        }
        .btn {
            border: none;
            padding: 7px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .btn-approve {
            background: #10B981;
            color: white;
        }
        .btn-approve:hover {
            background: #059669;
        }
        .btn-reject {
            background: #EF4444;
            color: white;
        }
        .btn-reject:hover {
            background: #DC2626;
        }
        .btn-delete {
            background: #FEE2E2;
            color: #991B1B;
            border: 1px solid #FECACA;
        }
        .btn-delete:hover {
            background: #EF4444;
            color: white;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--gray-500);
        }
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: var(--dark);
            color: white;
            padding: 14px 20px;
            border-radius: 10px;
            font-size: 14px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            display: none;
            z-index: 1000;
            animation: slideIn 0.3s forwards;
        }
        @keyframes slideIn {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        /* Modal Styles */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 200;
            backdrop-filter: blur(2px);
        }
        .modal {
            background: var(--white);
            border-radius: 18px;
            width: 100%;
            max-width: 480px;
            padding: 28px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            animation: modalFadeIn 0.25s ease;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .modal-header h3 {
            font-size: 18px;
            font-weight: 700;
            color: var(--dark);
        }
        .modal-close {
            background: none;
            border: none;
            font-size: 22px;
            cursor: pointer;
            color: var(--gray-500);
        }
        .modal-group {
            margin-bottom: 16px;
        }
        .modal-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 6px;
        }
        .modal-input, .modal-textarea {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 9px;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }
        .modal-input:focus, .modal-textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(255, 94, 0, 0.12);
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 24px;
        }
        .btn-cancel {
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            color: var(--dark);
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
        }
    </style>
</head>
<body>

    <!-- ================= LEFT SIDEBAR ================= -->
    <aside class="sidebar">
        <div>
            <!-- Brand -->
            <div class="sidebar-brand">
                <div class="brand-logo">CP</div>
                <div class="brand-text">
                    <h1>Cooperative Clap</h1>
                    <p>Central Admin Portal</p>
                </div>
            </div>

            <!-- Navigation Links -->
            <div class="sidebar-menu">
                <div class="menu-label">CORE OPERATIONS</div>
                
                <button class="nav-item active" id="side-btn-providers" onclick="navigateTo('providers')">
                    <div class="nav-left">
                        <span>👥</span>
                        <span>Service Providers</span>
                    </div>
                    <span class="nav-badge" id="side-count-providers">0</span>
                </button>

                <button class="nav-item" id="side-btn-categories" onclick="navigateTo('categories')">
                    <div class="nav-left">
                        <span>🏷️</span>
                        <span>Service Categories</span>
                    </div>
                    <span class="nav-badge" id="side-count-categories">0</span>
                </button>

                <!-- Direct Add Category Option in Sidebar -->
                <button class="sidebar-btn-add" onclick="openAddCategoryModal()">
                    <span>➕</span>
                    <span>Add New Category</span>
                </button>

                <div class="menu-label" style="margin-top: 20px;">APPS ECOSYSTEM</div>
                
                <div class="nav-item" style="opacity: 0.8; cursor: default;">
                    <div class="nav-left">
                        <span>📱</span>
                        <span>App 1: Provider App</span>
                    </div>
                    <span class="badge active" style="font-size: 10px; padding: 2px 6px;">Live</span>
                </div>

                <div class="nav-item" style="opacity: 0.5; cursor: not-allowed;">
                    <div class="nav-left">
                        <span>🛍️</span>
                        <span>App 2: Customer App</span>
                    </div>
                    <span style="font-size: 10px; color: var(--gray-400);">Soon</span>
                </div>

                <div class="nav-item" style="opacity: 0.5; cursor: not-allowed;">
                    <div class="nav-left">
                        <span>🚚</span>
                        <span>App 3: Delivery App</span>
                    </div>
                    <span style="font-size: 10px; color: var(--gray-400);">Soon</span>
                </div>
            </div>
        </div>

        <!-- Sidebar User Card at Bottom -->
        <div class="sidebar-user">
            <div class="user-info">
                <div class="user-avatar"><?= strtoupper(substr($admin['name'] ?? 'A', 0, 1)) ?></div>
                <div>
                    <div class="user-name"><?= htmlspecialchars($admin['name'] ?? 'Super Admin') ?></div>
                    <div class="user-role">@<?= htmlspecialchars($admin['username'] ?? 'admin') ?></div>
                </div>
            </div>
            <a href="logout.php" class="btn-logout" title="Log Out">Logout 🚪</a>
        </div>
    </aside>

    <!-- ================= RIGHT CONTENT AREA ================= -->
    <div class="main-wrapper">
        <header class="top-header">
            <div class="page-title">
                <h2 id="header-title">Service Provider Approvals</h2>
                <p id="header-desc">Review and manage partner verification status across the platform</p>
            </div>
            <div class="header-actions">
                <button class="btn-action-primary" id="btn-header-add-cat" style="display: none;" onclick="openAddCategoryModal()">
                    ➕ Add New Category
                </button>
            </div>
        </header>

        <main class="content-body">
            <!-- ================= VIEW 1: SERVICE PROVIDERS ================= -->
            <div id="view-providers">
                <!-- Stats Section -->
                <div class="stats-grid">
                    <div class="stat-card all">
                        <div class="stat-title">Total Registered Providers</div>
                        <div class="stat-value" id="count-all">0</div>
                    </div>
                    <div class="stat-card pending">
                        <div class="stat-title">Pending Verification</div>
                        <div class="stat-value" id="count-pending" style="color: var(--warning);">0</div>
                    </div>
                    <div class="stat-card verified">
                        <div class="stat-title">Approved & Verified</div>
                        <div class="stat-value" id="count-verified" style="color: var(--success);">0</div>
                    </div>
                    <div class="stat-card rejected">
                        <div class="stat-title">Rejected Applications</div>
                        <div class="stat-value" id="count-rejected" style="color: var(--danger);">0</div>
                    </div>
                </div>

                <!-- Providers List Section -->
                <div class="content-card">
                    <div class="card-header">
                        <div class="card-title">
                            <h3>Partner Applications</h3>
                            <p>Verify KYC and enable dashboard access for service providers</p>
                        </div>
                        <div class="filters">
                            <button class="filter-btn active" onclick="setFilter('all', this)">All</button>
                            <button class="filter-btn" onclick="setFilter('pending_verification', this)">Pending Review</button>
                            <button class="filter-btn" onclick="setFilter('verified', this)">Verified</button>
                            <button class="filter-btn" onclick="setFilter('rejected', this)">Rejected</button>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Provider</th>
                                    <th>Phone / Email</th>
                                    <th>Selected Categories</th>
                                    <th>City / Area</th>
                                    <th>Status</th>
                                    <th>Registered On</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="providers-table-body">
                                <tr>
                                    <td colspan="7" class="empty-state">Loading partner applications...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ================= VIEW 2: CATEGORIES MANAGEMENT ================= -->
            <div id="view-categories" style="display: none;">
                <div class="content-card">
                    <div class="card-header">
                        <div class="card-title">
                            <h3>Master Service Categories</h3>
                            <p>These master categories feed the registration skill selection across all 3 apps</p>
                        </div>
                        <button class="btn-action-primary" onclick="openAddCategoryModal()">
                            ➕ Add New Category
                        </button>
                    </div>

                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Icon</th>
                                    <th>Category Name</th>
                                    <th>Description</th>
                                    <th>Status</th>
                                    <th>Created Date</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="categories-table-body">
                                <tr>
                                    <td colspan="7" class="empty-state">Loading categories...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Modal: Add New Category -->
    <div id="category-modal" class="modal-overlay">
        <div class="modal">
            <div class="modal-header">
                <h3>➕ Add New Service Category</h3>
                <button class="modal-close" onclick="closeAddCategoryModal()">&times;</button>
            </div>
            <form onsubmit="submitNewCategory(event)">
                <div class="modal-group">
                    <label for="cat-name">Category Name *</label>
                    <input type="text" id="cat-name" class="modal-input" placeholder="e.g. Pest Control, Car Wash" required>
                </div>
                <div class="modal-group">
                    <label for="cat-icon">Category Icon (Emoji / Symbol) *</label>
                    <input type="text" id="cat-icon" class="modal-input" placeholder="e.g. 🛠️, ⚡, 🪠, 🚗, 🧹, ✂️, 💧" value="🛠️" required>
                </div>
                <div class="modal-group">
                    <label for="cat-desc">Short Description</label>
                    <textarea id="cat-desc" class="modal-textarea" rows="2" placeholder="Brief details about services under this category"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeAddCategoryModal()">Cancel</button>
                    <button type="submit" class="btn-action-primary" id="btn-save-cat">Save Category</button>
                </div>
            </form>
        </div>
    </div>

    <div id="toast" class="toast"></div>

    <script>
        const API_URL = '../api/index.php';
        let allProviders = [];
        let allCategories = [];
        let currentFilter = 'all';

        // Sidebar Navigation
        function navigateTo(section) {
            const viewProviders = document.getElementById('view-providers');
            const viewCategories = document.getElementById('view-categories');
            const btnProviders = document.getElementById('side-btn-providers');
            const btnCategories = document.getElementById('side-btn-categories');
            const headerTitle = document.getElementById('header-title');
            const headerDesc = document.getElementById('header-desc');
            const headerAddBtn = document.getElementById('btn-header-add-cat');

            if (section === 'providers') {
                viewProviders.style.display = 'block';
                viewCategories.style.display = 'none';
                btnProviders.classList.add('active');
                btnCategories.classList.remove('active');
                headerTitle.innerText = 'Service Provider Approvals';
                headerDesc.innerText = 'Review and manage partner verification status across the platform';
                headerAddBtn.style.display = 'none';
            } else {
                viewProviders.style.display = 'none';
                viewCategories.style.display = 'block';
                btnProviders.classList.remove('active');
                btnCategories.classList.add('active');
                headerTitle.innerText = 'Service Categories Management';
                headerDesc.innerText = 'Manage master categories that feed all apps in the ecosystem';
                headerAddBtn.style.display = 'inline-flex';
                loadCategories();
            }
        }

        // ================= PROVIDERS =================
        async function loadProviders() {
            try {
                const res = await fetch(`${API_URL}?action=admin-list-providers`);
                const result = await res.json();
                if (result.success) {
                    allProviders = result.data.providers || [];
                    document.getElementById('side-count-providers').innerText = allProviders.length;
                    updateStats();
                    renderTable();
                } else {
                    showToast('Failed to load: ' + result.message);
                }
            } catch (err) {
                console.error(err);
                showToast('Network error loading providers.');
            }
        }

        function updateStats() {
            const counts = {
                all: allProviders.length,
                pending: allProviders.filter(p => p.verification_status === 'pending_verification' || p.verification_status === 'under_review').length,
                verified: allProviders.filter(p => p.verification_status === 'verified').length,
                rejected: allProviders.filter(p => p.verification_status === 'rejected').length
            };
            document.getElementById('count-all').innerText = counts.all;
            document.getElementById('count-pending').innerText = counts.pending;
            document.getElementById('count-verified').innerText = counts.verified;
            document.getElementById('count-rejected').innerText = counts.rejected;
        }

        function setFilter(filter, btn) {
            currentFilter = filter;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            renderTable();
        }

        function renderTable() {
            const tbody = document.getElementById('providers-table-body');
            let filtered = allProviders;

            if (currentFilter !== 'all') {
                filtered = allProviders.filter(p => p.verification_status === currentFilter);
            }

            if (filtered.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="empty-state">No service providers found in this filter.</td></tr>`;
                return;
            }

            tbody.innerHTML = filtered.map(p => {
                const initial = p.name ? p.name.charAt(0).toUpperCase() : 'P';
                const skills = p.category ? p.category.split(',').map(s => `<span class="chip">${escapeHtml(s.trim())}</span>`).join('') : '<span class="chip">General</span>';
                const status = p.verification_status || 'pending_verification';
                const formattedDate = p.created_at ? p.created_at.split(' ')[0] : '-';

                let actionHtml = '';
                if (status === 'verified') {
                    actionHtml = `<button class="btn btn-reject" onclick="updateStatus(${p.id}, 'rejected')">Revoke / Reject</button>`;
                } else if (status === 'rejected') {
                    actionHtml = `<button class="btn btn-approve" onclick="updateStatus(${p.id}, 'verified')">Re-Approve</button>`;
                } else {
                    actionHtml = `
                        <div class="action-btns">
                            <button class="btn btn-approve" onclick="updateStatus(${p.id}, 'verified')">✓ Approve</button>
                            <button class="btn btn-reject" onclick="updateStatus(${p.id}, 'rejected')">✕ Reject</button>
                        </div>
                    `;
                }

                return `
                    <tr>
                        <td>
                            <div class="provider-info">
                                <div class="avatar">${initial}</div>
                                <div>
                                    <div class="provider-name">${escapeHtml(p.name)}</div>
                                    <div class="provider-id">ID: #${p.id}</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div><strong>${escapeHtml(p.phone)}</strong></div>
                            <div style="font-size: 12px; color: var(--gray-500);">${escapeHtml(p.email || '-')}</div>
                        </td>
                        <td><div class="skills-chips">${skills}</div></td>
                        <td>${escapeHtml(p.city || '-')}</td>
                        <td><span class="badge ${status}">${formatStatus(status)}</span></td>
                        <td>${formattedDate}</td>
                        <td>${actionHtml}</td>
                    </tr>
                `;
            }).join('');
        }

        async function updateStatus(providerId, newStatus) {
            let reason = '';
            if (newStatus === 'rejected') {
                reason = prompt('Please enter rejection reason (optional):', 'Documents incomplete or invalid') || 'Review failed';
            }

            try {
                const res = await fetch(`${API_URL}?action=admin-update-status`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        provider_id: providerId,
                        status: newStatus,
                        reason: reason
                    })
                });

                const data = await res.json();
                if (data.success) {
                    showToast(`Partner #${providerId} status updated to ${newStatus.toUpperCase()}`);
                    loadProviders();
                } else {
                    showToast('Failed: ' + data.message);
                }
            } catch (err) {
                console.error(err);
                showToast('Error updating status.');
            }
        }

        // ================= CATEGORIES =================
        async function loadCategories() {
            try {
                const res = await fetch(`${API_URL}?action=admin-list-categories`);
                const result = await res.json();
                if (result.success) {
                    allCategories = result.data.categories || [];
                    document.getElementById('side-count-categories').innerText = allCategories.length;
                    renderCategoriesTable();
                } else {
                    showToast('Failed to load categories: ' + result.message);
                }
            } catch (err) {
                console.error(err);
                showToast('Error loading categories.');
            }
        }

        function renderCategoriesTable() {
            const tbody = document.getElementById('categories-table-body');
            if (allCategories.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="empty-state">No categories found. Click "+ Add New Category" to create one.</td></tr>`;
                return;
            }

            tbody.innerHTML = allCategories.map(cat => {
                const iconDisplay = cat.icon && !cat.icon.startsWith('fa-') ? cat.icon : '🛠️';
                const createdDate = cat.created_at ? cat.created_at.split(' ')[0] : '-';
                return `
                    <tr>
                        <td><strong>#${cat.id}</strong></td>
                        <td style="font-size: 20px;">${escapeHtml(iconDisplay)}</td>
                        <td><strong>${escapeHtml(cat.name)}</strong></td>
                        <td style="color: var(--gray-500);">${escapeHtml(cat.description || '-')}</td>
                        <td><span class="badge active">Active</span></td>
                        <td>${createdDate}</td>
                        <td>
                            <button class="btn btn-delete" onclick="deleteCategory(${cat.id}, '${escapeHtml(cat.name)}')">🗑️ Delete</button>
                        </td>
                    </tr>
                `;
            }).join('');
        }

        function openAddCategoryModal() {
            document.getElementById('category-modal').style.display = 'flex';
            document.getElementById('cat-name').value = '';
            document.getElementById('cat-desc').value = '';
            document.getElementById('cat-name').focus();
        }

        function closeAddCategoryModal() {
            document.getElementById('category-modal').style.display = 'none';
        }

        async function submitNewCategory(e) {
            e.preventDefault();
            const name = document.getElementById('cat-name').value.trim();
            const icon = document.getElementById('cat-icon').value.trim() || '🛠️';
            const desc = document.getElementById('cat-desc').value.trim();

            if (!name) {
                alert('Please enter category name');
                return;
            }

            const btn = document.getElementById('btn-save-cat');
            btn.disabled = true;
            btn.innerText = 'Saving...';

            try {
                const res = await fetch(`${API_URL}?action=admin-add-category`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        name: name,
                        icon: icon,
                        description: desc
                    })
                });

                const data = await res.json();
                if (data.success) {
                    showToast(`Category "${name}" added successfully! 🎉`);
                    closeAddCategoryModal();
                    loadCategories();
                    navigateTo('categories');
                } else {
                    alert('Error: ' + data.message);
                }
            } catch (err) {
                console.error(err);
                alert('Network error while saving category.');
            } finally {
                btn.disabled = false;
                btn.innerText = 'Save Category';
            }
        }

        async function deleteCategory(id, name) {
            if (!confirm(`Are you sure you want to delete category "${name}"?`)) {
                return;
            }

            try {
                const res = await fetch(`${API_URL}?action=admin-delete-category`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id: id })
                });

                const data = await res.json();
                if (data.success) {
                    showToast(`Category "${name}" deleted.`);
                    loadCategories();
                } else {
                    alert('Error: ' + data.message);
                }
            } catch (err) {
                console.error(err);
                alert('Network error deleting category.');
            }
        }

        function formatStatus(status) {
            return status.replace('_', ' ');
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/[&<>'"]/g, 
                tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
            );
        }

        function showToast(msg) {
            const toast = document.getElementById('toast');
            toast.innerText = msg;
            toast.style.display = 'block';
            setTimeout(() => {
                toast.style.display = 'none';
            }, 3500);
        }

        // Initialize on load
        loadProviders();
        loadCategories();
    </script>
</body>
</html>
