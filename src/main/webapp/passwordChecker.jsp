<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jsp" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Password Checker - CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
            background: #0a0c10;
            min-height: 100vh;
            position: relative;
            color: #e5e7eb;
        }

        /* Cyber icons background pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.05"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-repeat: repeat;
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
            position: relative;
            z-index: 1;
        }

        /* Two Column Layout */
        .two-column-layout {
            display: flex;
            gap: 30px;
            align-items: flex-start;
        }

        .main-card {
            flex: 2;
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 24px;
            padding: 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .samples-section {
            flex: 1;
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 24px;
            padding: 30px;
            position: sticky;
            top: 100px;
        }

        h2 {
            color: #44634d;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
            border-left: 3px solid #44634d;
            padding-left: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        h2 i {
            color: #44634d;
        }

        .description {
            color: #9ca3af;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 30px;
            margin-left: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 8px;
            display: block;
            color: #9ca3af;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        label i {
            color: #44634d;
            margin-right: 8px;
        }

        .password-box {
            position: relative;
            display: flex;
            align-items: center;
        }

        input[type=password] {
            width: 100%;
            padding: 14px 16px;
            font-size: 15px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            color: #ffffff;
            transition: all 0.2s ease;
            padding-right: 50px;
        }

        input[type=password]:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        input[type=password]::placeholder {
            color: #4b5563;
        }

        .toggle-eye {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #6b7280;
            transition: color 0.2s ease;
            z-index: 2;
        }

        .toggle-eye:hover {
            color: #44634d;
        }

        button {
            margin-top: 10px;
            padding: 14px 28px;
            background: #44634d;
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            width: 100%;
            justify-content: center;
        }

        button:hover {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        button i {
            font-size: 16px;
        }

        .error-message {
            background: #2c1515;
            color: #f87171;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-top: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 3px solid #ef4444;
            border: 1px solid #3f1f1f;
        }

        .error-message i {
            color: #f87171;
        }

        .result-box {
            margin-top: 30px;
            padding: 25px;
            border-radius: 16px;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .result-box.safe {
            background: #1a2e1a;
            border: 1px solid #2a4a2a;
        }

        .result-box.warning {
            background: #2c2415;
            border: 1px solid #3f341f;
        }

        .result-box.danger {
            background: #2c1515;
            border: 1px solid #3f1f1f;
        }

        .result-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }

        .result-header i {
            font-size: 24px;
        }

        .result-box.safe i {
            color: #86efac;
        }

        .result-box.warning i {
            color: #fbbf24;
        }

        .result-box.danger i {
            color: #f87171;
        }

        .result-header h3 {
            font-size: 18px;
            font-weight: 600;
        }

        .result-box.safe h3 {
            color: #86efac;
        }

        .result-box.warning h3 {
            color: #fbbf24;
        }

        .result-box.danger h3 {
            color: #f87171;
        }

        .result-count {
            font-size: 24px;
            font-weight: 700;
            margin: 10px 0;
        }

        .result-box.safe .result-count {
            color: #86efac;
        }

        .result-box.warning .result-count {
            color: #fbbf24;
        }

        .result-box.danger .result-count {
            color: #f87171;
        }

        .result-message {
            color: #9ca3af;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .tip {
            font-size: 13px;
            color: #6b7280;
            display: flex;
            align-items: center;
            gap: 8px;
            padding-top: 15px;
            border-top: 1px solid #2a2f3a;
            margin-top: 15px;
        }

        .tip i {
            color: #44634d;
        }

        /* Sample passwords section - Right side */
        .section-title {
            color: #ffffff;
            font-size: 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 3px solid #44634d;
            padding-left: 15px;
        }

        .section-title i {
            color: #44634d;
        }

        .sample-note {
            color: #9ca3af;
            font-size: 13px;
            margin-bottom: 25px;
            line-height: 1.5;
        }

        .samples-grid {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .sample-category {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 15px;
        }

        .category-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px solid #2a2f3a;
        }

        .category-header i {
            font-size: 16px;
        }

        .category-header.high-risk i {
            color: #f87171;
        }

        .category-header.moderate i {
            color: #fbbf24;
        }

        .category-header.low-risk i {
            color: #86efac;
        }

        .category-header h4 {
            color: #ffffff;
            font-size: 14px;
            font-weight: 600;
        }

        .password-list {
            list-style: none;
        }

        .password-list li {
            margin: 6px 0;
            padding: 8px 12px;
            background: #0f1115;
            border-radius: 8px;
            border: 1px solid #2a2f3a;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-family: monospace;
            font-size: 13px;
        }

        .password-list li:hover {
            border-color: #44634d;
            background: #1f242b;
        }

        .password-list li span {
            color: #9ca3af;
            word-break: break-all;
        }

        .password-list li i {
            color: #44634d;
            font-size: 12px;
            opacity: 0.6;
        }

        .password-list li:hover i {
            opacity: 1;
        }

        @media (max-width: 968px) {
            .two-column-layout {
                flex-direction: column;
            }
            
            .samples-section {
                position: static;
                width: 100%;
            }
        }

        @media (max-width: 768px) {
            .main-card {
                padding: 25px;
            }
            
            h2 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- Two Column Layout -->
    <div class="two-column-layout">
        
        <!-- Left Column - Password Checker Main Card -->
        <div class="main-card">
            <h2>
                <i class="fas fa-shield-halved"></i>
                Password Breach Checker
            </h2>
            
            <div class="description">
                Check if your password has appeared in a known data breach. 
                Your password is never sent to any server – we use a secure hash verification method.
            </div>

            <form method="post" action="checkPassword" id="passwordForm">
                <div class="form-group">
                    <label><i class="fas fa-lock"></i> Enter Password</label>
                    <div class="password-box">
                        <input type="password" name="password" id="password" 
                               placeholder="Type a password to check" required/>
                        <span class="toggle-eye" onclick="togglePassword()">
                            <i class="far fa-eye" id="eyeIcon"></i>
                        </span>
                    </div>
                </div>
                
                <button type="submit">
                    <i class="fas fa-search"></i> Check Password
                </button>
            </form>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <% if (Boolean.TRUE.equals(request.getAttribute("checked"))) {
                int count = (int) request.getAttribute("pwnCount");
                if (count == 0) { %>
                    <div class="result-box safe">
                        <div class="result-header">
                            <i class="fas fa-check-circle"></i>
                            <h3>✓ Safe Password</h3>
                        </div>
                        <div class="result-count">0 breaches found</div>
                        <div class="result-message">
                            Good news! This password has not been found in any known breach.
                        </div>
                        <div class="tip">
                            <i class="fas fa-lightbulb"></i>
                            Still, use a unique password for every site and enable 2FA where possible.
                        </div>
                    </div>
                <% } else if (count < 200) { %>
                    <div class="result-box warning">
                        <div class="result-header">
                            <i class="fas fa-exclamation-triangle"></i>
                            <h3>⚠ Caution Recommended</h3>
                        </div>
                        <div class="result-count"><%= count %> breach<%= count > 1 ? "es" : "" %> found</div>
                        <div class="result-message">
                            This password appeared in <strong><%= count %></strong> known breach<%= count > 1 ? "es" : "" %>.
                        </div>
                        <div class="tip">
                            <i class="fas fa-lightbulb"></i>
                            Consider changing this password, especially if used on important accounts.
                        </div>
                    </div>
                <% } else { %>
                    <div class="result-box danger">
                        <div class="result-header">
                            <i class="fas fa-skull-crosswind"></i>
                            <h3>🚨 Compromised Password</h3>
                        </div>
                        <div class="result-count"><%= String.format("%,d", count) %> breaches found</div>
                        <div class="result-message">
                            This password appeared <strong><%= String.format("%,d", count) %></strong> times in known breaches!
                        </div>
                        <div class="tip">
                            <i class="fas fa-lightbulb"></i>
                            Stop using this password immediately. Use a password manager to create a strong, unique one.
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>

        <!-- Right Column - Sample Passwords Section -->
        <div class="samples-section">
            <h3 class="section-title">
                <i class="fas fa-flask"></i>
                Sample Passwords
            </h3>
            <p class="sample-note">
                Click any password to fill the field, then click "Check Password" to analyze
            </p>
            
            <div class="samples-grid">
                <!-- High Risk Passwords -->
                <div class="sample-category">
                    <div class="category-header high-risk">
                        <i class="fas fa-skull-crosswind"></i>
                        <h4>High Risk</h4>
                    </div>
                    <ul class="password-list">
                        <li onclick="fillPassword('qwerty')">
                            <span>qwerty</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('123456789')">
                            <span>123456789</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('siddhi1')">
                            <span>siddhi1</span>
                            <i class="fas fa-copy"></i>
                        </li>
                    </ul>
                </div>
                
                <!-- Moderate Risk Passwords -->
                <div class="sample-category">
                    <div class="category-header moderate">
                        <i class="fas fa-exclamation-triangle"></i>
                        <h4>Moderate Risk</h4>
                    </div>
                    <ul class="password-list">
                        <li onclick="fillPassword('payal67')">
                            <span>payal67</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('diksha07')">
                            <span>diksha07</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('wednesdaypink')">
                            <span>wednesdaypink</span>
                            <i class="fas fa-copy"></i>
                        </li>
                    </ul>
                </div>
                
                <!-- Low Risk Passwords -->
                <div class="sample-category">
                    <div class="category-header low-risk">
                        <i class="fas fa-check-circle"></i>
                        <h4>Low Risk</h4>
                    </div>
                    <ul class="password-list">
                        <li onclick="fillPassword('Tanyamane@28')">
                            <span>Tanyamane@28</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('KashishT@03')">
                            <span>KashishT@03</span>
                            <i class="fas fa-copy"></i>
                        </li>
                        <li onclick="fillPassword('$*y*hiYRX2HgHzND')">
                            <span>$*y*hiYRX2HgHzND</span>
                            <i class="fas fa-copy"></i>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Prevent browser back button from showing password history
    (function() {
        window.history.pushState(null, null, window.location.href);
        
        window.onpopstate = function() {
            window.location.href = 'detectiontools.jsp';
        };
        
        window.addEventListener('load', function() {
            const passwordField = document.getElementById('password');
            if (passwordField) {
                passwordField.value = '';
            }
        });
        
        window.addEventListener('beforeunload', function() {
            const passwordField = document.getElementById('password');
            if (passwordField) {
                passwordField.value = '';
            }
        });
    })();
    
    function togglePassword() {
        const passwordInput = document.getElementById('password');
        const eyeIcon = document.getElementById('eyeIcon');
        
        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.className = 'far fa-eye-slash';
        } else {
            passwordInput.type = 'password';
            eyeIcon.className = 'far fa-eye';
        }
    }
    
    function fillPassword(password) {
        document.getElementById('password').value = password;
        document.getElementById('password').focus();
    }
</script>

</body>
</html>