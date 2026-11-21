/**
 * COOPERATIVE CLAP - CLIENT APPLICATION LOGIC
 * Connects directly to Core PHP REST API
 */

const API_BASE = 'backend/api/index.php';

// State
let currentPhone = '';
let selectedCategory = 'Electrician';
let authToken = localStorage.getItem('cp_auth_token') || '';
let providerData = JSON.parse(localStorage.getItem('cp_provider_data') || 'null');

// DOM View Containers
const loginView      = document.getElementById('loginView');
const otpView        = document.getElementById('otpView');
const registerView   = document.getElementById('registerView');
const pendingView    = document.getElementById('pendingView');
const dashboardView  = document.getElementById('dashboardView');
const topbarActions  = document.getElementById('topbarActions');
const toastBox       = document.getElementById('toastBox');

// Initialize on Load
document.addEventListener('DOMContentLoaded', () => {
    loadCategories();
    setupOtpInputListeners();

    if (authToken) {
        checkStatus();
    } else {
        switchView('login');
    }
});

// Toast notification helper
function showToast(message, isError = false) {
    toastBox.innerText = message;
    toastBox.style.background = isError ? '#ef4444' : '#1f2937';
    toastBox.style.display = 'block';
    setTimeout(() => {
        toastBox.style.display = 'none';
    }, 3500);
}

// Switch between screens
function switchView(viewName) {
    loginView.classList.remove('active');
    otpView.classList.remove('active');
    registerView.classList.remove('active');
    pendingView.classList.remove('active');
    dashboardView.classList.remove('active');

    if (viewName === 'login') {
        loginView.classList.add('active');
        topbarActions.style.display = 'none';
    } else if (viewName === 'otp') {
        otpView.classList.add('active');
        topbarActions.style.display = 'none';
        document.getElementById('otp1').focus();
    } else if (viewName === 'register') {
        registerView.classList.add('active');
        topbarActions.style.display = 'none';
    } else if (viewName === 'pending') {
        pendingView.classList.add('active');
        topbarActions.style.display = 'flex';
    } else if (viewName === 'dashboard') {
        dashboardView.classList.add('active');
        topbarActions.style.display = 'flex';
    }
}

// Setup 6-Box Segmented OTP Inputs
function setupOtpInputListeners() {
    const boxes = [
        document.getElementById('otp1'),
        document.getElementById('otp2'),
        document.getElementById('otp3'),
        document.getElementById('otp4'),
        document.getElementById('otp5'),
        document.getElementById('otp6')
    ];

    boxes.forEach((box, index) => {
        box.addEventListener('input', (e) => {
            const val = e.target.value;
            if (val.length === 1 && index < 5) {
                boxes[index + 1].focus();
            }
        });

        box.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && !box.value && index > 0) {
                boxes[index - 1].focus();
            }
        });
    });
}

function getEnteredOtp() {
    return [
        document.getElementById('otp1').value,
        document.getElementById('otp2').value,
        document.getElementById('otp3').value,
        document.getElementById('otp4').value,
        document.getElementById('otp5').value,
        document.getElementById('otp6').value
    ].join('');
}

function clearOtpBoxes() {
    ['otp1','otp2','otp3','otp4','otp5','otp6'].forEach(id => {
        document.getElementById(id).value = '';
    });
}

// Load Categories from API
async function loadCategories() {
    try {
        const res = await fetch(`${API_BASE}?action=categories`);
        const json = await res.json();
        if (json.success && json.data) {
            const grid = document.getElementById('regCategoryGrid');
            grid.innerHTML = '';
            json.data.forEach((cat, idx) => {
                const chip = document.createElement('div');
                chip.className = `cat-chip ${idx === 0 ? 'selected' : ''}`;
                chip.innerHTML = `<i class="${cat.icon || 'fa-solid fa-wrench'}"></i><span>${cat.name}</span>`;
                chip.onclick = () => selectCategory(cat.name, chip);
                grid.appendChild(chip);
                if (idx === 0) selectedCategory = cat.name;
            });
        }
    } catch (e) {
        console.error('Failed to load categories', e);
    }
}

function selectCategory(catName, chipEl) {
    selectedCategory = catName;
    document.querySelectorAll('.cat-chip').forEach(c => c.classList.remove('selected'));
    chipEl.classList.add('selected');
}

// 1. Send OTP Form Submit
document.getElementById('sendOtpForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const phoneInput = document.getElementById('loginPhone').value.trim();

    if (!phoneInput || phoneInput.length !== 10) {
        showToast('कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें', true);
        return;
    }

    currentPhone = phoneInput;
    const btn = document.getElementById('sendOtpBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> OTP भेजा जा रहा है...';

    try {
        const res = await fetch(`${API_BASE}?action=send-otp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ phone: currentPhone })
        });
        const json = await res.json();

        if (json.success) {
            document.getElementById('otpDisplayPhone').innerText = `+91 ${currentPhone}`;
            clearOtpBoxes();
            
            // Prefill sample test OTP (878786 as per Figma screenshot or 123456)
            document.getElementById('otp1').value = '8';
            document.getElementById('otp2').value = '7';
            document.getElementById('otp3').value = '8';
            document.getElementById('otp4').value = '7';
            document.getElementById('otp5').value = '8';
            document.getElementById('otp6').value = '6';

            showToast('OTP भेजा गया (Test OTP: 878786 या 123456)');
            switchView('otp');
        } else {
            showToast(json.message || 'OTP भेजने में विफल', true);
        }
    } catch (err) {
        showToast('सर्वर से कनेक्ट नहीं हो सका', true);
    } finally {
        btn.disabled = false;
        btn.innerHTML = 'OTP भेजें <i class="fa-solid fa-arrow-right"></i>';
    }
});

// 2. Verify OTP Submit
document.getElementById('verifyOtpBtn').addEventListener('click', async () => {
    const otp = getEnteredOtp();
    if (otp.length !== 6) {
        showToast('कृपया 6 अंकों का OTP दर्ज करें', true);
        return;
    }

    const btn = document.getElementById('verifyOtpBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> सत्यापन हो रहा है...';

    try {
        const res = await fetch(`${API_BASE}?action=verify-otp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ phone: currentPhone, otp: otp })
        });
        const json = await res.json();

        if (json.success) {
            if (json.data.needs_registration) {
                // New user - redirect to registration form
                document.getElementById('regPhone').value = currentPhone;
                showToast('नया मोबाइल नंबर! कृपया पार्टनर रजिस्ट्रेशन पूरा करें।');
                switchView('register');
            } else {
                // Existing provider
                authToken = json.data.auth_token;
                providerData = json.data.provider;
                localStorage.setItem('cp_auth_token', authToken);
                localStorage.setItem('cp_provider_data', JSON.stringify(providerData));

                showToast('लॉगिन सफल!');
                await checkStatus();
            }
        } else {
            showToast(json.message || 'OTP अमान्य है', true);
        }
    } catch (err) {
        showToast('सत्यापन के दौरान नेटवर्क त्रुटि', true);
    } finally {
        btn.disabled = false;
        btn.innerHTML = 'सत्यापित करें';
    }
});

// 3. Register Form Submit
document.getElementById('partnerRegForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const submitBtn = document.getElementById('regSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> प्रोफाइल सबमिट हो रही है...';

    const formData = new FormData(document.getElementById('partnerRegForm'));
    formData.append('category', selectedCategory);

    try {
        const res = await fetch(`${API_BASE}?action=register`, {
            method: 'POST',
            body: formData
        });
        const json = await res.json();

        if (json.success) {
            authToken = json.data.auth_token;
            providerData = json.data.provider;
            localStorage.setItem('cp_auth_token', authToken);
            localStorage.setItem('cp_provider_data', JSON.stringify(providerData));

            showToast('रजिस्ट्रेशन सबमिट! आपका आवेदन जांच के अधीन है।');
            renderPendingScreen(json.data.status, providerData.name);
            switchView('pending');
        } else {
            let errMsg = json.message || 'रजिस्ट्रेशन विफल';
            if (json.errors) {
                const firstKey = Object.keys(json.errors)[0];
                errMsg = json.errors[firstKey][0];
            }
            showToast(errMsg, true);
        }
    } catch (err) {
        showToast('सर्वर से कनेक्ट करने में त्रुटि', true);
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'पार्टनर रजिस्ट्रेशन पूरा करें <i class="fa-solid fa-arrow-right"></i>';
    }
});

// 4. Check Live Status from Server
async function checkStatus() {
    if (!authToken) {
        switchView('login');
        return;
    }

    try {
        const res = await fetch(`${API_BASE}?action=status`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        const json = await res.json();

        if (json.success) {
            const status = json.data.verification_status;
            const name   = json.data.name;

            if (status === 'verified') {
                // Verified provider gets the dashboard!
                await loadDashboard();
            } else {
                // Pending or under review
                renderPendingScreen(status, name, json.data.rejection_reason);
                switchView('pending');
            }
        } else {
            logout();
        }
    } catch (e) {
        showToast('सर्वर स्टेटस जांचने में असमर्थ', true);
    }
}

// 5. Render Pending / Waiting Screen
function renderPendingScreen(status, name, reason = '') {
    document.getElementById('pendingName').innerText = name || 'पार्टनर';
    const pill = document.getElementById('pendingStatusBadge');
    const title = document.getElementById('pendingTitle');
    const desc  = document.getElementById('pendingDesc');

    if (status === 'rejected') {
        pill.innerText = 'आवेदन अस्वीकृत (Rejected)';
        pill.style.background = '#fee2e2';
        pill.style.color = '#b91c1c';
        title.innerText = 'आवेदन अस्वीकृत हुआ';
        desc.innerText = reason || 'दस्तावेज़ सत्यापन पूर्ण नहीं हो सका।';
    } else {
        pill.innerText = 'सत्यापन प्रक्रियाधीन (Under Review)';
        pill.style.background = '#fef3c7';
        pill.style.color = '#b45309';
        title.innerText = 'आवेदन जांच के अधीन है';
        desc.innerText = 'आपका रजिस्ट्रेशन सबमिट हो चुका है। एडमिन द्वारा सत्यापन पूर्ण होने पर आपका डैशबोर्ड स्वतः खुल जाएगा।';
    }
}

// 6. Load Verified Dashboard
async function loadDashboard() {
    try {
        const res = await fetch(`${API_BASE}?action=dashboard`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        const json = await res.json();

        if (json.success) {
            const data = json.data;
            document.getElementById('dashWelcome').innerText = data.welcome_message;
            document.getElementById('dashProviderName').innerText = data.provider.name;
            document.getElementById('dashCategory').innerText = data.provider.category;
            document.getElementById('dashCity').innerText = data.provider.city;

            switchView('dashboard');
        } else {
            renderPendingScreen('pending_verification', providerData ? providerData.name : '');
            switchView('pending');
        }
    } catch (e) {
        showToast('डैशबोर्ड लोड करने में त्रुटि', true);
    }
}

// Logout
function logout() {
    localStorage.removeItem('cp_auth_token');
    localStorage.removeItem('cp_provider_data');
    authToken = '';
    providerData = null;
    switchView('login');
    showToast('लॉगआउट सफल');
}
