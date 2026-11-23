<?php
/**
 * Cooperative Clap - Central Web Admin Portal
 * Path: backend/admin/index.php
 * Handles Service Provider verification, KYC review, and ecosystem controls.
 */
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cooperative Clap — Central Admin Portal</title>
    <style>
        :root {
            --primary: #FF5E00;
            --primary-dark: #D44E00;
            --primary-light: #FFF0E6;
            --success: #10B981;
            --warning: #F59E0B;
            --danger: #EF4444;
            --dark: #1E293B;
            --gray-100: #F8FAFC;
            --gray-200: #E2E8F0;
            --gray-500: #64748B;
            --white: #FFFFFF;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        body {
            background-color: var(--gray-100);
            color: var(--dark);
            min-height: 100vh;
        }
        header {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 50;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .brand-logo {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #FF5E00, #FF8A00);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            font-weight: 700;
        }
        .brand h1 {
            font-size: 18px;
            font-weight: 700;
            color: var(--dark);
        }
        .brand p {
            font-size: 12px;
            color: var(--gray-500);
        }
        .admin-badge {
            background: var(--primary-light);
            color: var(--primary-dark);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        main {
            max-width: 1300px;
            margin: 32px auto;
            padding: 0 24px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
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
            font-size: 13px;
            color: var(--gray-500);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-value {
            font-size: 32px;
            font-weight: 700;
            margin-top: 8px;
            color: var(--dark);
        }
        .stat-card.pending { border-left: 4px solid var(--warning); }
        .stat-card.verified { border-left: 4px solid var(--success); }
        .stat-card.rejected { border-left: 4px solid var(--danger); }
        .stat-card.all { border-left: 4px solid var(--primary); }

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
        .card-title h2 {
            font-size: 18px;
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
            font-weight: 600;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--gray-200);
        }
        td {
            padding: 18px 20px;
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
    </style>
</head>
<body>

    <header>
        <div class="brand">
            <div class="brand-logo">CP</div>
            <div>
                <h1>Cooperative Clap</h1>
                <p>Central Admin Portal (Ecosystem Control)</p>
            </div>
        </div>
        <div class="admin-badge">Admin Mode Active</div>
    </header>

    <main>
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
                    <h2>Service Provider Approvals</h2>
                    <p>Manage verification status for all partner applications</p>
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
    </main>

    <div id="toast" class="toast"></div>

    <script>
        const API_URL = '../api/index.php';
        let allProviders = [];
        let currentFilter = 'all';

        async function loadProviders() {
            try {
                const res = await fetch(`${API_URL}?action=admin-list-providers`);
                const result = await res.json();
                if (result.success) {
                    allProviders = result.data.providers || [];
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
                tbody.innerHTML = `<tr><td colspan="7" class="empty-state">No service providers found in this category.</td></tr>`;
                return;
            }

            tbody.innerHTML = filtered.map(p => {
                const initial = p.name ? p.name.charAt(0).toUpperCase() : 'P';
                const skills = p.category ? p.category.split(',').map(s => `<span class="chip">${s.trim()}</span>`).join('') : '<span class="chip">General</span>';
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
                    // Refresh data
                    loadProviders();
                } else {
                    showToast('Failed: ' + data.message);
                }
            } catch (err) {
                console.error(err);
                showToast('Error updating status.');
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
    </script>
</body>
</html>
