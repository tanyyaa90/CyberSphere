<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CyberSphere Dark Theme */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
            background: #0a0c10;
            min-height: 100vh;
            color: #e5e7eb;
        }

        /* Header - matching header.jsp */
        .about-header {
            background: #0f1115;
            border-bottom: 1px solid #1e1e1e;
            padding: 18px 0;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }

        .header-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Logo Section */
        .logo-section {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .logo-link {
            display: flex;
            align-items: center;
            text-decoration: none;
        }

        .logo-svg {
            height: 45px;
            width: auto;
            filter: brightness(0) invert(1);
        }

        .tagline {
            color: #44634d;
            font-size: 13px;
            font-weight: 500;
            border-left: 1px solid #2a2f3a;
            padding-left: 15px;
            text-transform: uppercase;
        }

        /* Auth Buttons */
        .auth-buttons {
            display: flex;
            gap: 12px;
        }

        .btn-login {
            background: transparent;
            color: #ffffff;
            border: 1px solid #2a2f3a;
            padding: 8px 24px;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .btn-login:hover {
            border-color: #44634d;
            color: #44634d;
        }

        .btn-signup {
            background: #44634d;
            color: white;
            border: none;
            padding: 8px 24px;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .btn-signup:hover {
            background: #36523d;
        }

        /* Main Content - Compact */
        .main-content {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* About Card */
        .about-card {
            background: #0f1115;
            border-radius: 20px;
            border: 1px solid #1e1e1e;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .about-header-image {
            height: 150px;
            background: linear-gradient(135deg, #1a2a1a 0%, #1f2e25 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            border-bottom: 1px solid #2a4a2a;
        }

        .about-header-image i {
            font-size: 60px;
            color: #44634d;
            opacity: 0.5;
        }

        .about-content {
            padding: 40px;
        }

        .about-title {
            font-size: 32px;
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 20px;
            letter-spacing: -0.02em;
        }

        .about-title span {
            color: #44634d;
        }

        .about-subtitle {
            color: #9ca3af;
            font-size: 16px;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #1e1e1e;
        }

        /* Stats in a row */
        .quick-stats {
            display: flex;
            gap: 40px;
            margin: 30px 0;
            background: #1a1e24;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #2a2f3a;
        }

        .stat {
            flex: 1;
            text-align: center;
        }

        .stat-number {
            font-size: 28px;
            font-weight: 700;
            color: #44634d;
        }

        .stat-label {
            color: #9ca3af;
            font-size: 13px;
            margin-top: 5px;
        }

        /* Info Grid - 2 columns */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin: 30px 0;
        }

        .info-item {
            background: #1a1e24;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #2a2f3a;
            transition: all 0.2s ease;
        }

        .info-item:hover {
            border-color: #44634d;
        }

        .info-item i {
            color: #44634d;
            font-size: 24px;
            margin-bottom: 12px;
        }

        .info-item h3 {
            color: #ffffff;
            font-size: 16px;
            margin-bottom: 8px;
        }

        .info-item p {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.5;
        }

        /* Team Section - Compact */
        .team-section {
            margin: 30px 0;
        }

        .team-section h3 {
            color: #ffffff;
            font-size: 20px;
            margin-bottom: 20px;
        }

        .team-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }

        .team-member {
            background: #1a1e24;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #2a2f3a;
            text-align: center;
        }

        .team-member i {
            font-size: 40px;
            color: #44634d;
            margin-bottom: 10px;
        }

        .team-member h4 {
            color: #ffffff;
            font-size: 16px;
            margin-bottom: 4px;
        }

        .team-member p {
            color: #9ca3af;
            font-size: 12px;
        }

        /* Footer */
        .about-footer {
            background: #0f1115;
            border-top: 1px solid #1e1e1e;
            padding: 30px 0;
            margin-top: 40px;
        }

        .footer-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #9ca3af;
            font-size: 14px;
        }

        .footer-links a {
            color: #9ca3af;
            text-decoration: none;
            margin-left: 20px;
            transition: color 0.2s ease;
        }

        .footer-links a:hover {
            color: #44634d;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .quick-stats {
                flex-direction: column;
                gap: 20px;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .team-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .footer-container {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .footer-links a {
                margin: 0 10px;
            }
        }
    </style>
</head>
<body>

    <!-- Header -->
    <header class="about-header">
        <div class="header-container">
            <div class="logo-section">
                <a href="index.jsp" class="logo-link">
                    <img src="images/logo.svg" alt="CyberSphere" class="logo-svg" 
                         onerror="this.onerror=null; this.src='images/logo.png'">
                </a>
                <span class="tagline">ABOUT US</span>
            </div>
            
            <div class="auth-buttons">
                <a href="login.jsp" class="btn-login">Login</a>
                <a href="signup.jsp" class="btn-signup">Sign Up</a>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="main-content">
        <div class="about-card">
            <div class="about-header-image">
                <i class="fas fa-shield-halved"></i>
            </div>
            
            <div class="about-content">
                <h1 class="about-title">About <span>CyberSphere</span></h1>
                
                <p class="about-subtitle">
                    Your trusted partner in cybersecurity education since 2024.
                </p>
                
                <!-- Quick Stats -->
                <div class="quick-stats">
                    <div class="stat">
                        <div class="stat-number">24/7</div>
                        <div class="stat-label">Resources Available</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">250+</div>
                        <div class="stat-label">Interactive Quiz Questions</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">100%</div>
                        <div class="stat-label">Free Learning</div>
                    </div>
                </div>
                
                <!-- Short Description -->
                <p style="color: #9ca3af; line-height: 1.6; margin-bottom: 30px;">
                    CyberSphere was created to make cybersecurity education accessible to everyone. 
                    We believe that in today's digital world, understanding online threats isn't just 
                    for IT professionals—it's for everyone.
                </p>
                
                <!-- Info Grid - 4 items in 2 columns -->
                <div class="info-grid">
                    <div class="info-item">
                        <i class="fas fa-bullseye"></i>
                        <h3>Our Mission</h3>
                        <p>Empower individuals with the knowledge to stay safe online through interactive learning.</p>
                    </div>
                    
                    <div class="info-item">
                        <i class="fas fa-eye"></i>
                        <h3>Our Vision</h3>
                        <p>A world where everyone can recognize and protect themselves from cyber threats.</p>
                    </div>
                    
                    <div class="info-item">
                        <i class="fas fa-heart"></i>
                        <h3>Our Values</h3>
                        <p>Accessibility, quality education, and practical skills that make a difference.</p>
                    </div>
                    
                    <div class="info-item">
                        <i class="fas fa-handshake"></i>
                        <h3>Our Promise</h3>
                        <p>Always free, always updated, and always focused on real-world scenarios.</p>
                    </div>
                </div>
                
                <!-- Contact CTA -->
                <div style="background: #1a1e24; padding: 20px; border-radius: 12px; border: 1px solid #2a2f3a; margin-top: 20px; text-align: center;">
                    <p style="color: #9ca3af; margin-bottom: 15px;">
                        Have questions? We'd love to hear from you.
                    </p>
                    <a href="#" style="color: #44634d; text-decoration: none; font-weight: 500;">
                        <i class="fas fa-envelope"></i> contact@cybersphere.com
                    </a>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="about-footer">
        <div class="footer-container">
            <div>&copy; 2026 CyberSphere. All rights reserved.</div>
            <div class="footer-links">
                <a href="about.jsp">About</a>
                <a href="contact.jsp">Contact</a>
            </div>
        </div>
    </footer>
</body>
</html>