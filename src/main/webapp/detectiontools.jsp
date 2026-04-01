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
    <title>Detection Tools - CyberSphere</title>
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
        }

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
            padding: 20px;
            position: relative;
            z-index: 1;
        }

        .hero-section {
            text-align: center;
            color: #ffffff;
            padding: 40px 20px 20px 20px;
        }

        .hero-section h1 {
            font-size: 42px;
            margin-bottom: 15px;
            font-weight: 600;
            letter-spacing: -0.02em;
            color: #ffffff;
        }

        .hero-section h1 span {
            color: #44634d;
        }

        .hero-section p {
            font-size: 18px;
            color: #9ca3af;
            margin-bottom: 10px;
        }

        .tools-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 30px;
            margin-top: 50px;
        }

        .tool-card {
            background: #0f1115;
            border-radius: 24px;
            padding: 35px 30px;
            text-align: center;
            transition: all 0.3s ease;
            border: 1px solid #1e1e1e;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }

        .tool-card:hover {
            transform: translateY(-10px);
            border-color: #44634d;
            box-shadow: 0 20px 40px rgba(68, 99, 77, 0.2);
        }

        .tool-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #44634d, #5a7e64);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .tool-card:hover::before {
            transform: scaleX(1);
        }

        .tool-icon {
            width: 80px;
            height: 80px;
            background: #1a1e24;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            border: 1px solid #2a2f3a;
            transition: all 0.3s ease;
        }

        .tool-card:hover .tool-icon {
            border-color: #44634d;
            background: #1f242b;
        }

        .tool-icon i {
            font-size: 40px;
            color: #44634d;
            transition: all 0.3s ease;
        }

        .tool-card:hover .tool-icon i {
            transform: scale(1.1);
            color: #5a7e64;
        }

        .tool-title {
            color: #ffffff;
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 12px;
        }

        .tool-description {
            color: #9ca3af;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 25px;
            flex-grow: 1;
        }

        .tool-meta {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .tool-tag {
            background: #1a1e24;
            color: #9ca3af;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            border: 1px solid #2a2f3a;
        }

        .tool-tag i {
            color: #44634d;
            margin-right: 5px;
        }

        .tool-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 12px 30px;
            background: #1a1e24;
            color: #ffffff;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 500;
            font-size: 15px;
            transition: all 0.2s ease;
            border: 1px solid #2a2f3a;
            margin-top: auto;
        }

        .tool-card:hover .tool-button {
            background: #44634d;
            border-color: #44634d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        .tool-button i {
            font-size: 14px;
            transition: transform 0.2s ease;
        }

        .tool-card:hover .tool-button i {
            transform: translateX(5px);
        }

        .feature-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #1a2a1a;
            color: #86efac;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            border: 1px solid #2a4a2a;
        }

        .feature-badge i {
            margin-right: 4px;
        }

        .stats-section {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-top: 60px;
            padding: 30px;
            background: #0f1115;
            border-radius: 24px;
            border: 1px solid #1e1e1e;
        }

        .stat-item {
            text-align: center;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #44634d;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #9ca3af;
            font-size: 14px;
        }

        .stats-footer {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 60px;
            padding: 20px;
            border-top: 1px solid #1e1e1e;
        }

        .footer-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #9ca3af;
            font-size: 14px;
        }

        .dot {
            width: 8px;
            height: 8px;
            background: #44634d;
            border-radius: 50%;
            display: inline-block;
        }
        .back-home {
    margin-bottom: 20px;
}

.back-home a {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 18px;
    background: #1a1e24;
    color: #ffffff;
    text-decoration: none;
    border-radius: 10px;
    font-size: 14px;
    border: 1px solid #2a2f3a;
    transition: all 0.2s ease;
}

.back-home a:hover {
    background: #44634d;
    border-color: #44634d;
}

        @media (max-width: 768px) {
            .hero-section h1 {
                font-size: 32px;
            }
            
            .tools-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-section {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .stats-footer {
                flex-direction: column;
                align-items: center;
                gap: 15px;
            }
            
        }
    </style>
</head>
<body>

<div class="container">
<div class="back-home">
    <a href="#" onclick="window.location.replace('home.jsp')">
        <i class="fas fa-arrow-left"></i> Home
    </a>
</div>
    <div class="hero-section">
        <h1>Security <span>Detection Tools</span></h1>
        <p>Comprehensive tools to analyze and detect security threats in real-time</p>
    </div>
    
    <div class="tools-grid">
        <div class="tool-card" onclick="window.location.replace('phishing.jsp')">
            <div class="tool-icon">
                <i class="fas fa-fish"></i>
            </div>
            <h2 class="tool-title">Phishing Detector</h2>
            <p class="tool-description">
                Analyze emails and messages to detect sophisticated phishing attempts.
                Identify malicious links, spoofed senders, and social engineering tactics.
            </p>
            <div class="tool-meta">
                <span class="tool-tag"><i class="fas fa-envelope"></i> Email</span>
                <span class="tool-tag"><i class="fas fa-link"></i> Links</span>
                <span class="tool-tag"><i class="fas fa-flag"></i> 15+ patterns</span>
            </div>
            <span class="tool-button">
                Launch Detector <i class="fas fa-arrow-right"></i>
            </span>
        </div>

        <!-- Password Checker Card -->
        <div class="tool-card" onclick="window.location.replace('passwordChecker.jsp')">
            <div class="tool-icon">
                <i class="fas fa-key"></i>
            </div>
            <h2 class="tool-title">Password Checker</h2>
            <p class="tool-description">
                Check if your passwords have been compromised in known data breaches.
                Uses secure hash verification - your password never leaves your device.
            </p>
            <div class="tool-meta">
                <span class="tool-tag"><i class="fas fa-database"></i> 10B+ records</span>
                <span class="tool-tag"><i class="fas fa-lock"></i> Private</span>
                <span class="tool-tag"><i class="fas fa-check"></i> Instant</span>
            </div>
            <span class="tool-button">
                Check Password <i class="fas fa-arrow-right"></i>
            </span>
        </div>

        <!-- URL Scanner Card -->
        <div class="tool-card" onclick="window.location.replace('urlScanner.jsp')">
            <div class="tool-icon">
                <i class="fas fa-search"></i>
            </div>
            <h2 class="tool-title">URL Scanner</h2>
            <p class="tool-description">
                Scan any URL for malware, phishing, fraud, and other threats.
                Get detailed risk scores, domain age, server info, and threat detection.
            </p>
            <div class="tool-meta">
                <span class="tool-tag"><i class="fas fa-chart-line"></i> Risk Score</span>
                <span class="tool-tag"><i class="fas fa-globe"></i> Domain Check</span>
                <span class="tool-tag"><i class="fas fa-shield-alt"></i> Malware</span>
            </div>
            <span class="tool-button">
                Scan URL <i class="fas fa-arrow-right"></i>
            </span>
        </div>

        <!-- SSL Certificate Checker Card -->
        <div class="tool-card" onclick="window.location.replace('sslChecker.jsp')">
            <div class="tool-icon">
                <i class="fas fa-lock"></i>
            </div>
            <h2 class="tool-title">SSL Certificate Checker</h2>
            <p class="tool-description">
                Verify SSL/TLS certificates for any website. Check expiration dates,
                issuer details, and security configurations to ensure secure connections.
            </p>
            <div class="tool-meta">
                <span class="tool-tag"><i class="fas fa-calendar"></i> Expiry</span>
                <span class="tool-tag"><i class="fas fa-building"></i> Issuer</span>
                <span class="tool-tag"><i class="fas fa-check-circle"></i> Validation</span>
            </div>
            <span class="tool-button" style="opacity: 0.7;">
                Check SSL <i class="fas fa-arrow-right"></i>
            </span>
        </div>

    </div>
</div>

</body>
</html>