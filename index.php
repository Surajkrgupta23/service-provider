<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Cooperative Clap - सेवा साथी पार्टनर पोर्टल</title>
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Cooperative Clap Custom Stylesheet -->
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

    <div class="app-container">
        <!-- Top App Bar (Dashboard & Profile view) -->
        <header class="app-topbar">
            <div class="topbar-brand">
                <div class="topbar-logo">
                    <i class="fa-solid fa-handshake"></i>
                </div>
                <div class="topbar-title">Cooperative Clap</div>
            </div>
            <div id="topbarActions" class="topbar-icons" style="display: none;">
                <button class="icon-btn" onclick="checkStatus()" title="ताज़ा करें">
                    <i class="fa-solid fa-rotate-right"></i>
                </button>
                <button class="icon-btn" onclick="logout()" title="लॉगआउट">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i>
                </button>
            </div>
        </header>

        <!-- Main Content Body -->
        <main class="app-content">

            <!-- ========================================================
                 SCREEN 1: LOGIN (Figma Screen 1: लॉगिन करें)
                 ======================================================== -->
            <section id="loginView" class="app-view active">
                <div class="brand-hero">
                    <div class="brand-hero-logo">
                        <i class="fa-solid fa-hands-holding-child"></i>
                    </div>
                    <h1 class="brand-hero-title">Cooperative Clap</h1>
                    <p class="brand-hero-tagline">आपका विश्वसनीय सेवा साथी</p>
                </div>

                <div class="figma-card">
                    <h2 class="card-heading">लॉगिन करें</h2>

                    <form id="sendOtpForm">
                        <div class="form-group">
                            <label class="form-label">मोबाइल नंबर</label>
                            <input type="tel" id="loginPhone" class="form-input" placeholder="9876543210" maxlength="10" required>
                        </div>

                        <button type="submit" id="sendOtpBtn" class="btn-primary" style="margin-top: 10px;">
                            OTP भेजें <i class="fa-solid fa-arrow-right"></i>
                        </button>
                    </form>

                    <div style="text-align: center; margin-top: 18px;">
                        <a onclick="switchView('register')" class="otp-link" style="font-size: 0.88rem;">
                            नया पार्टनर खाता बनाएं (Register as Partner)
                        </a>
                    </div>

                    <p class="card-footer-note">
                        जारी रखने से आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत हैं।
                    </p>
                </div>
            </section>

            <!-- ========================================================
                 SCREEN 2: OTP VERIFICATION (Figma Screen 2 & 3: OTP सत्यापन)
                 ======================================================== -->
            <section id="otpView" class="app-view">
                <div class="brand-hero">
                    <div class="brand-hero-logo">
                        <i class="fa-solid fa-hands-holding-child"></i>
                    </div>
                    <h1 class="brand-hero-title">Cooperative Clap</h1>
                    <p class="brand-hero-tagline">आपका विश्वसनीय सेवा साथी</p>
                </div>

                <div class="figma-card">
                    <h2 class="card-heading">OTP सत्यापन</h2>
                    <p class="otp-subtext">
                        <span id="otpDisplayPhone">+91 98XXXXXXXX</span> पर भेजे गए 6 अंकों का OTP दर्ज करें
                    </p>

                    <!-- 6 Segmented PIN boxes matching Figma design -->
                    <div class="otp-container">
                        <input type="text" id="otp1" class="otp-box" maxlength="1" inputmode="numeric">
                        <input type="text" id="otp2" class="otp-box" maxlength="1" inputmode="numeric">
                        <input type="text" id="otp3" class="otp-box" maxlength="1" inputmode="numeric">
                        <input type="text" id="otp4" class="otp-box" maxlength="1" inputmode="numeric">
                        <input type="text" id="otp5" class="otp-box" maxlength="1" inputmode="numeric">
                        <input type="text" id="otp6" class="otp-box" maxlength="1" inputmode="numeric">
                    </div>

                    <button type="button" id="verifyOtpBtn" class="btn-primary">
                        सत्यापित करें
                    </button>

                    <div class="otp-actions-row">
                        <a onclick="switchView('login')" class="otp-link">नंबर बदलें</a>
                        <a onclick="document.getElementById('sendOtpBtn').click()" class="otp-link">OTP दोबारा भेजें</a>
                    </div>

                    <p class="card-footer-note">
                        जारी रखने से आप हमारी सेवा की शर्तों से सहमत हैं।
                    </p>
                </div>
            </section>

            <!-- ========================================================
                 SCREEN 3: PARTNER REGISTRATION (पार्टनर रजिस्ट्रेशन)
                 ======================================================== -->
            <section id="registerView" class="app-view">
                <div style="margin-bottom: 16px;">
                    <a onclick="switchView('login')" class="otp-link" style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;">
                        <i class="fa-solid fa-arrow-left"></i> वापस लॉगिन पर जाएं
                    </a>
                </div>

                <div class="figma-card">
                    <h2 class="card-heading" style="text-align: left; margin-bottom: 6px;">पार्टनर रजिस्ट्रेशन</h2>
                    <p style="font-size: 0.82rem; color: #6b7280; margin-bottom: 18px;">
                        Cooperative Clap सेवा साथी बनकर अपने शहर में बुकिंग्स प्राप्त करें।
                    </p>

                    <form id="partnerRegForm" enctype="multipart/form-data">
                        <div class="form-group">
                            <label class="form-label">पूरा नाम (Full Name) *</label>
                            <input type="text" name="name" class="form-input" placeholder="उदा. रमेश कुमार" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">मोबाइल नंबर *</label>
                                <input type="tel" id="regPhone" name="phone" class="form-input" placeholder="10-digit mobile" maxlength="10" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">ईमेल पता *</label>
                                <input type="email" name="email" class="form-input" placeholder="ramesh@gmail.com" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">अपनी सेवा श्रेणी चुनें (Select Skill) *</label>
                            <div id="regCategoryGrid" class="category-chip-grid">
                                <!-- Populated dynamically -->
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">शहर / कार्य क्षेत्र *</label>
                                <input type="text" name="city" class="form-input" placeholder="उदा. नोएडा / दिल्ली" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">अनुभव (Experience)</label>
                                <select name="experience_years" class="form-input">
                                    <option value="1">1 वर्ष</option>
                                    <option value="3" selected>3-5 वर्ष</option>
                                    <option value="8">8+ वर्ष</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">पहचान पत्र प्रकार (ID Proof)</label>
                                <select name="id_type" class="form-input">
                                    <option value="Aadhar Card">आधार कार्ड (Aadhar)</option>
                                    <option value="PAN Card">पैन कार्ड (PAN)</option>
                                    <option value="Driving License">ड्राइविंग लाइसेंस</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label">पहचान पत्र संख्या (ID No.)</label>
                                <input type="text" name="id_number" class="form-input" placeholder="XXXX-XXXX-XXXX">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">गोपनीय पासवर्ड बनाएं *</label>
                            <input type="password" name="password" class="form-input" placeholder="न्यूनतम 6 अक्षर" required>
                        </div>

                        <button type="submit" id="regSubmitBtn" class="btn-primary" style="margin-top: 10px;">
                            पार्टनर रजिस्ट्रेशन पूरा करें <i class="fa-solid fa-arrow-right"></i>
                        </button>
                    </form>
                </div>
            </section>

            <!-- ========================================================
                 SCREEN 4: WAITING FOR APPROVAL (सत्यापन प्रक्रियाधीन)
                 ======================================================== -->
            <section id="pendingView" class="app-view">
                <div class="pending-hero-card">
                    <div class="pending-pulse-icon">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <span id="pendingStatusBadge" class="status-badge">सत्यापन प्रक्रियाधीन</span>
                    <h3 id="pendingTitle" style="font-size: 1.18rem; font-weight: 800; color: #7c2d12; margin-bottom: 6px;">
                        आवेदन जांच के अधीन है
                    </h3>
                    <p id="pendingDesc" style="font-size: 0.84rem; color: #78350f; line-height: 1.45;">
                        नमस्ते <strong id="pendingName">पार्टनर</strong>, आपका रजिस्ट्रेशन प्राप्त हो गया है। एडमिन द्वारा सत्यापन पूर्ण होते ही आपका डैशबोर्ड खुल जाएगा।
                    </p>
                </div>

                <!-- Progress Stepper -->
                <div class="verification-stepper">
                    <div class="stepper-item">
                        <div class="stepper-icon completed">
                            <i class="fa-solid fa-check"></i>
                        </div>
                        <div class="stepper-text">
                            <h4>रजिस्ट्रेशन सबमिट हुआ</h4>
                            <p>प्रोफ़ाइल और केवाईसी विवरण सफलता से दर्ज</p>
                        </div>
                    </div>

                    <div class="stepper-item">
                        <div class="stepper-icon active">
                            <i class="fa-solid fa-spinner fa-spin"></i>
                        </div>
                        <div class="stepper-text">
                            <h4>एडमिन द्वारा सत्यापन</h4>
                            <p>दस्तावेज़ और कार्य अनुभव की समीक्षा जारी है</p>
                        </div>
                    </div>

                    <div class="stepper-item">
                        <div class="stepper-icon upcoming">
                            <i class="fa-solid fa-lock"></i>
                        </div>
                        <div class="stepper-text">
                            <h4>सेवा साथी डैशबोर्ड सक्रियण</h4>
                            <p>सत्यापन के बाद डैशबोर्ड स्वतः अनलॉक होगा</p>
                        </div>
                    </div>
                </div>

                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <button class="btn-primary" onclick="checkStatus()">
                        <i class="fa-solid fa-rotate-right"></i> स्थिति पुनः जांचें (Check Status)
                    </button>
                    <button class="btn-outline" onclick="logout()">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> लॉगआउट
                    </button>
                </div>
            </section>

            <!-- ========================================================
                 SCREEN 5: VERIFIED DASHBOARD (Figma Screen 4 & 5: डैशबोर्ड)
                 ======================================================== -->
            <section id="dashboardView" class="app-view">
                <!-- Figma Exact "नमस्ते 🙏" Hero Card -->
                <div class="namaste-banner">
                    <h2>नमस्ते 🙏</h2>
                    <p>आपकी सेवा के लिए तैयार • प्रमाणित सेवा साथी</p>

                    <!-- User Requested Welcome Message -->
                    <div class="namaste-highlight-msg">
                        <i class="fa-solid fa-circle-check"></i>
                        <span id="dashWelcome">Thank you for joining CP Clap, we will serve soon</span>
                    </div>
                </div>

                <!-- Provider Profile Summary -->
                <div style="background: #ffffff; border: 1px solid var(--border-light); border-radius: 18px; padding: 14px 16px; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 44px; height: 44px; border-radius: 50%; background: #fff7ed; border: 1.5px solid var(--brand-orange); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; color: var(--brand-orange);">
                            <i class="fa-solid fa-user-check"></i>
                        </div>
                        <div>
                            <h4 id="dashProviderName" style="font-size: 0.98rem; font-weight: 800; color: #1f2937;">पार्टनर नाम</h4>
                            <p style="font-size: 0.78rem; color: #6b7280;">
                                <span id="dashCategory">Category</span> • <span id="dashCity">City</span>
                            </p>
                        </div>
                    </div>
                    <span style="background: #ecfdf5; color: #047857; padding: 4px 10px; border-radius: 12px; font-size: 0.72rem; font-weight: 800;">
                        सक्रिय साथी
                    </span>
                </div>

                <!-- Stats Row -->
                <div class="stats-row">
                    <div class="stat-box">
                        <div class="stat-value">₹0.00</div>
                        <div class="stat-label">आज की कमाई</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value">0</div>
                        <div class="stat-label">पूर्ण कार्य</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value">5.0 ★</div>
                        <div class="stat-label">रेटिंग</div>
                    </div>
                </div>

                <!-- Figma Screen 4 Service Grid Preview -->
                <div class="section-subtitle">
                    <span>हमारी सेवाएं (Active Services)</span>
                    <span style="font-size: 0.75rem; color: var(--brand-orange); font-weight: 700;">सभी देखें</span>
                </div>

                <div class="services-grid">
                    <div class="service-card">
                        <div class="service-card-icon"><i class="fa-solid fa-bolt"></i></div>
                        <div class="service-card-name">इलेक्ट्रिशियन</div>
                    </div>
                    <div class="service-card">
                        <div class="service-card-icon"><i class="fa-solid fa-faucet-drip"></i></div>
                        <div class="service-card-name">प्लंबर</div>
                    </div>
                    <div class="service-card">
                        <div class="service-card-icon"><i class="fa-solid fa-snowflake"></i></div>
                        <div class="service-card-name">एसी रिपेयर</div>
                    </div>
                    <div class="service-card">
                        <div class="service-card-icon"><i class="fa-solid fa-broom"></i></div>
                        <div class="service-card-name">क्लीनिंग</div>
                    </div>
                </div>

                <!-- Duty Status Switch -->
                <div style="background: #ffffff; border: 1px solid var(--border-light); border-radius: 16px; padding: 14px 16px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <h4 style="font-size: 0.88rem; font-weight: 800; color: #1f2937;">ड्यूटी स्थिति (Duty Status)</h4>
                        <p style="font-size: 0.74rem; color: #6b7280;">नई बुकिंग स्वीकार करने के लिए</p>
                    </div>
                    <span style="color: #10b981; font-weight: 800; font-size: 0.85rem;">
                        <i class="fa-solid fa-circle"></i> ऑनलाइन
                    </span>
                </div>

                <button class="btn-outline" onclick="logout()" style="margin-top: 10px;">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i> लॉगआउट
                </button>
            </section>

        </main>
    </div>

    <!-- Toast Notification Message Box -->
    <div id="toastBox" class="toast-msg"></div>

    <!-- Application Script -->
    <script src="assets/js/app.js"></script>
</body>
</html>
