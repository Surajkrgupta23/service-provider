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
        <!-- Top App Header Bar (Figma Exact Header) -->
        <header class="app-header-bar">
            <div class="header-brand">
                <div class="header-logo-circle">
                    <i class="fa-solid fa-handshake"></i>
                </div>
                <div class="header-brand-text">
                    <span class="header-brand-name">Cooperative Clap</span>
                    <span class="header-brand-tag">पार्टनर पोर्टल (Partner Portal)</span>
                </div>
            </div>
            
            <div id="topbarActions" class="header-actions" style="display: none;">
                <button type="button" class="header-refresh-btn" onclick="checkStatus()" title="ताज़ा करें (Refresh)">
                    <i class="fa-solid fa-rotate-right"></i>
                </button>
                
                <!-- Profile Trigger Pill Button -->
                <button type="button" class="header-profile-btn" onclick="openProfileModal()" title="मेरी प्रोफाइल (My Profile)">
                    <div class="header-avatar-circle" id="topbarAvatarInitial">P</div>
                    <span class="header-profile-label" id="topbarProfileName">प्रोफाइल</span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 0.72rem; color: var(--brand-orange);"></i>
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
                            <label class="form-label">अपनी सेवा श्रेणियां चुनें (Select Skills - Multiple) *</label>
                            <div class="multiselect-dropdown">
                                <div id="categoryDropdownBtn" class="multiselect-btn" onclick="toggleCategoryDropdown()">
                                    <span id="selectedCategoriesText">श्रेणियां चुनें (Click to Select)</span>
                                    <i class="fa-solid fa-chevron-down"></i>
                                </div>
                                <div id="categoryDropdownMenu" class="multiselect-menu">
                                    <!-- Populated dynamically with checkboxes -->
                                </div>
                            </div>
                            <div id="selectedCategoryChips" class="selected-chips-box"></div>
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

    <!-- ========================================================
         PROFILE MODAL BOTTOM SHEET (With 2-3 Future Options)
         ======================================================== -->
    <div id="profileModalOverlay" class="profile-modal-overlay" onclick="closeProfileModal(event)">
        <div class="profile-modal-card" onclick="event.stopPropagation()">
            <!-- Drag Handle Bar -->
            <div class="profile-modal-handle"></div>

            <!-- Profile Summary Card -->
            <div class="profile-user-header">
                <div class="profile-user-avatar" id="modalAvatarInitial">P</div>
                <div class="profile-user-meta">
                    <h3 id="modalPartnerName">पार्टनर नाम</h3>
                    <p id="modalPartnerCategory">सेवा साथी • शहर</p>
                    <div id="modalPartnerStatus" class="profile-status-pill">✓ सत्यापित सेवा साथी</div>
                </div>
                <button type="button" class="profile-modal-close-btn" onclick="closeProfileModal()" title="बंद करें">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="profile-divider"></div>

            <!-- 2-3 Future Options requested by user -->
            <div class="profile-options-list">
                <!-- Option 1: मेरी प्रोफाइल -->
                <div class="profile-option-item" onclick="openProfileDetailsSubmodal()">
                    <div class="profile-option-icon bg-orange-soft">
                        <i class="fa-solid fa-user"></i>
                    </div>
                    <div class="profile-option-content">
                        <h4>मेरी प्रोफाइल (My Profile)</h4>
                        <p>व्यक्तिगत जानकारी, मोबाइल एवं कार्य अनुभव</p>
                    </div>
                    <i class="fa-solid fa-chevron-right profile-option-arrow"></i>
                </div>

                <!-- Option 2: केवाईसी एवं दस्तावेज़ -->
                <div class="profile-option-item" onclick="openKycSubmodal()">
                    <div class="profile-option-icon bg-emerald-soft">
                        <i class="fa-solid fa-id-card"></i>
                    </div>
                    <div class="profile-option-content">
                        <h4>केवाईसी एवं दस्तावेज़ (KYC & Documents)</h4>
                        <p>आधार कार्ड, पैन कार्ड एवं सत्यापन स्थिति</p>
                    </div>
                    <i class="fa-solid fa-chevron-right profile-option-arrow"></i>
                </div>

                <!-- Option 3: सेटिंग्स एवं सहायता -->
                <div class="profile-option-item" onclick="openSupportSubmodal()">
                    <div class="profile-option-icon bg-blue-soft">
                        <i class="fa-solid fa-headset"></i>
                    </div>
                    <div class="profile-option-content">
                        <h4>सेटिंग्स एवं सहायता (Settings & Support)</h4>
                        <p>24x7 पार्टनर हेल्पलाइन एवं ऐप सेटिंग्स</p>
                    </div>
                    <i class="fa-solid fa-chevron-right profile-option-arrow"></i>
                </div>
            </div>

            <div class="profile-divider"></div>

            <!-- Logout Tile -->
            <div class="profile-option-item profile-logout-item" onclick="closeProfileModal(); logout();">
                <div class="profile-option-icon bg-red-soft">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i>
                </div>
                <div class="profile-option-content">
                    <h4 style="color: #dc2626;">लॉगआउट (Logout)</h4>
                    <p>खाते से सुरक्षित बाहर निकलें</p>
                </div>
                <i class="fa-solid fa-chevron-right profile-option-arrow" style="color: #dc2626;"></i>
            </div>
        </div>
    </div>

    <!-- SUBMODAL 1: Profile Details View -->
    <div id="profileDetailsModal" class="submodal-overlay" onclick="closeSubmodal('profileDetailsModal', event)">
        <div class="submodal-card" onclick="event.stopPropagation()">
            <div class="submodal-header">
                <h3><i class="fa-solid fa-user" style="color: var(--brand-orange);"></i> मेरी प्रोफाइल विवरण</h3>
                <button type="button" class="submodal-close-btn" onclick="closeSubmodal('profileDetailsModal')"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="submodal-body">
                <div class="info-row"><span class="info-label">पूरा नाम:</span><span id="detailName" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">मोबाइल नंबर:</span><span id="detailPhone" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">ईमेल पता:</span><span id="detailEmail" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">सेवा श्रेणियां:</span><span id="detailSkills" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">शहर / क्षेत्र:</span><span id="detailCity" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">कार्य अनुभव:</span><span id="detailExp" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">आईडी प्रकार:</span><span id="detailIdType" class="info-val">-</span></div>
                <div class="info-row"><span class="info-label">आईडी नंबर:</span><span id="detailIdNumber" class="info-val">-</span></div>
            </div>
            <p class="submodal-note"><i class="fa-solid fa-circle-info"></i> भविष्य में प्रोफाइल एडिट करने का विकल्प यहां सक्रिय होगा।</p>
        </div>
    </div>

    <!-- SUBMODAL 2: KYC Details View -->
    <div id="kycDetailsModal" class="submodal-overlay" onclick="closeSubmodal('kycDetailsModal', event)">
        <div class="submodal-card" onclick="event.stopPropagation()">
            <div class="submodal-header">
                <h3><i class="fa-solid fa-id-card" style="color: #059669;"></i> केवाईसी एवं दस्तावेज़</h3>
                <button type="button" class="submodal-close-btn" onclick="closeSubmodal('kycDetailsModal')"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="submodal-body">
                <div class="info-row"><span class="info-label">दस्तावेज़ प्रकार:</span><span id="kycDocType" class="info-val">आधार कार्ड / पैन</span></div>
                <div class="info-row"><span class="info-label">दस्तावेज़ संख्या:</span><span id="kycDocNum" class="info-val">XXXX-XXXX-8921</span></div>
                <div class="info-row"><span class="info-label">सत्यापन स्थिति:</span><span id="kycStatusBadge" class="info-val" style="color: #059669; font-weight: 800;">✓ सत्यापित</span></div>
                <div class="info-row"><span class="info-label">सत्यापन स्तर:</span><span class="info-val">एडमिन स्वीकृत (Level 1)</span></div>
            </div>
            <p class="submodal-note"><i class="fa-solid fa-shield-halved"></i> आपके सभी दस्तावेज़ एन्क्रिप्टेड और सुरक्षित हैं।</p>
        </div>
    </div>

    <!-- SUBMODAL 3: Settings & Support View -->
    <div id="supportDetailsModal" class="submodal-overlay" onclick="closeSubmodal('supportDetailsModal', event)">
        <div class="submodal-card" onclick="event.stopPropagation()">
            <div class="submodal-header">
                <h3><i class="fa-solid fa-headset" style="color: #2563eb;"></i> सेटिंग्स एवं 24x7 सहायता</h3>
                <button type="button" class="submodal-close-btn" onclick="closeSubmodal('supportDetailsModal')"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="submodal-body">
                <div class="support-card-box">
                    <h4>पार्टनर टोल-फ्री हेल्पलाइन</h4>
                    <p style="font-size: 1.15rem; font-weight: 800; color: var(--brand-orange); margin: 6px 0;">
                        <i class="fa-solid fa-phone"></i> 1800-889-CLAP (2527)
                    </p>
                    <p style="font-size: 0.78rem; color: #6b7280;">सोमवार - रविवार (24x7 सेवा)</p>
                </div>
                <div class="support-card-box" style="margin-top: 10px;">
                    <h4>व्हाट्सएप एवं ईमेल सहायता</h4>
                    <p style="font-size: 0.86rem; color: #374151; margin-top: 4px;">
                        <i class="fa-brands fa-whatsapp" style="color: #22c55e;"></i> +91 98765 43210<br>
                        <i class="fa-solid fa-envelope" style="color: var(--brand-orange);"></i> partner@cooperativeclap.com
                    </p>
                </div>
            </div>
            <p class="submodal-note"><i class="fa-solid fa-gear"></i> भाषा व ऐप नोटिफिकेशन सेटिंग्स जल्द उपलब्ध होंगी।</p>
        </div>
    </div>

    <!-- Toast Notification Message Box -->
    <div id="toastBox" class="toast-msg"></div>

    <!-- Application Script -->
    <script src="assets/js/app.js"></script>
</body>
</html>
