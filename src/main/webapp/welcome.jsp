<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CyberSphere - Your Security Partner</title>
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
            position: relative;
        }

        /* Cyber icons background pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.03"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-repeat: repeat;
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        /* Header - with logo from header.jsp */
        .landing-header {
            background: #0f1115;
            border-bottom: 1px solid #1e1e1e;
            padding: 18px 0;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }

        .header-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 0 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 40px;
        }

        /* Logo Section - exact same as header.jsp */
        .logo-section {
            display: flex;
            align-items: center;
            gap: 20px;
            flex-shrink: 0;
        }

        .logo-link {
            display: flex;
            align-items: center;
            text-decoration: none;
        }

        .logo-svg {
            height: 50px;
            width: auto;
            max-width: 200px;
            filter: brightness(0) invert(1);
        }

        .logo-fallback {
            display: none;
            font-size: 28px;
            font-weight: 600;
            color: #ffffff;
            letter-spacing: -0.02em;
        }

        /* Show fallback if image fails to load */
        .logo-svg[src=""],
        .logo-svg:not([src]) {
            display: none;
        }

        .logo-svg[src=""] + .logo-fallback,
        .logo-svg:not([src]) + .logo-fallback {
            display: block;
        }

        .tagline {
            color: #44634d;
            font-size: 14px;
            font-weight: 500;
            border-left: 1px solid #2a2f3a;
            padding-left: 20px;
            text-transform: uppercase;
            letter-spacing: 1px;
            white-space: nowrap;
        }

        /* Auth Buttons */
        .auth-buttons {
            display: flex;
            gap: 15px;
        }

        .btn-login {
            background: transparent;
            color: #ffffff;
            border: 1px solid #2a2f3a;
            padding: 10px 28px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-login:hover {
            border-color: #44634d;
            color: #44634d;
            transform: translateY(-1px);
        }

        .btn-signup {
            background: #44634d;
            color: white;
            border: none;
            padding: 10px 28px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-signup:hover {
            background: #36523d;
            transform: translateY(-1px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        /* Main Content */
        .main-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 60px 40px;
            position: relative;
            z-index: 1;
        }

        /* Hero Section */
        .hero-section {
            display: flex;
            align-items: center;
            gap: 60px;
            margin-bottom: 80px;
        }

        .hero-text {
            flex: 1;
        }

        .hero-text h1 {
            font-size: 52px;
            font-weight: 700;
            line-height: 1.2;
            margin-bottom: 25px;
            color: #ffffff;
            letter-spacing: -0.02em;
        }

        .hero-text h1 span {
            color: #44634d;
            position: relative;
            display: inline-block;
        }

        .hero-text h1 span::after {
            content: '';
            position: absolute;
            bottom: 5px;
            left: 0;
            width: 100%;
            height: 8px;
            background: rgba(68, 99, 77, 0.2);
            z-index: -1;
        }

        .hero-description {
            font-size: 18px;
            color: #9ca3af;
            line-height: 1.8;
            margin-bottom: 35px;
            max-width: 600px;
        }

        .hero-stats {
            display: flex;
            gap: 40px;
            margin-top: 40px;
        }

        .stat-item {
            display: flex;
            flex-direction: column;
        }

        .stat-number {
            font-size: 32px;
            font-weight: 700;
            color: #44634d;
        }

        .stat-label {
            font-size: 14px;
            color: #9ca3af;
            margin-top: 5px;
        }

        .hero-image {
            flex: 1;
            background: #1a1e24;
            border-radius: 30px;
            padding: 40px;
            border: 1px solid #2a2f3a;
            position: relative;
            overflow: hidden;
        }

        .hero-image::before {
            content: '🛡️';
            position: absolute;
            font-size: 150px;
            opacity: 0.1;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .feature-icons {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            position: relative;
            z-index: 1;
        }

        .feature-icon-item {
            text-align: center;
            padding: 25px;
            background: #0f1115;
            border-radius: 20px;
            border: 1px solid #2a2f3a;
            transition: all 0.2s ease;
        }

        .feature-icon-item:hover {
            transform: translateY(-5px);
            border-color: #44634d;
        }

        .feature-icon-item i {
            font-size: 40px;
            color: #44634d;
            margin-bottom: 15px;
        }

        .feature-icon-item h4 {
            color: #ffffff;
            font-size: 18px;
            margin-bottom: 8px;
        }

        .feature-icon-item p {
            color: #9ca3af;
            font-size: 13px;
        }

        /* About Section */
        .about-section {
            background: #0f1115;
            border-radius: 30px;
            padding: 60px;
            border: 1px solid #1e1e1e;
            margin-bottom: 80px;
        }

        .section-title {
            font-size: 36px;
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 30px;
            letter-spacing: -0.02em;
        }

        .section-title span {
            color: #44634d;
            border-left: 3px solid #44634d;
            padding-left: 15px;
        }

        .about-description {
            font-size: 17px;
            color: #9ca3af;
            line-height: 1.8;
            margin-bottom: 40px;
            max-width: 900px;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            margin-top: 50px;
        }

        .feature-card {
            background: #1a1e24;
            padding: 35px 25px;
            border-radius: 20px;
            border: 1px solid #2a2f3a;
            transition: all 0.2s ease;
        }

        .feature-card:hover {
            border-color: #44634d;
            transform: translateY(-5px);
            box-shadow: 0 20px 30px -10px rgba(68, 99, 77, 0.2);
        }

        .feature-card i {
            font-size: 48px;
            color: #44634d;
            margin-bottom: 20px;
        }

        .feature-card h3 {
            font-size: 22px;
            color: #ffffff;
            margin-bottom: 15px;
        }

        .feature-card p {
            color: #9ca3af;
            line-height: 1.6;
            font-size: 15px;
        }

        /* How It Works */
        .how-it-works {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            margin: 60px 0;
        }

        .step-card {
            text-align: center;
            padding: 40px 30px;
            background: #1a1e24;
            border-radius: 20px;
            border: 1px solid #2a2f3a;
            position: relative;
        }

        .step-number {
            width: 60px;
            height: 60px;
            background: #44634d;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: 700;
            color: white;
            margin: 0 auto 25px;
        }

        .step-card h3 {
            color: #ffffff;
            font-size: 22px;
            margin-bottom: 15px;
        }

        .step-card p {
            color: #9ca3af;
            line-height: 1.6;
        }

        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, #1a2a1a 0%, #1f2e25 100%);
            border-radius: 30px;
            padding: 60px;
            text-align: center;
            border: 1px solid #2a4a2a;
            margin-top: 60px;
        }

        .cta-section h2 {
            font-size: 42px;
            color: #ffffff;
            margin-bottom: 20px;
        }

        .cta-section p {
            font-size: 18px;
            color: #9ca3af;
            margin-bottom: 35px;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
        }

        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
        }

        .cta-btn-primary {
            background: #44634d;
            color: white;
            border: none;
            padding: 16px 40px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .cta-btn-primary:hover {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 15px 30px -10px rgba(68, 99, 77, 0.4);
        }

        .cta-btn-secondary {
            background: transparent;
            color: #ffffff;
            border: 1px solid #2a4a2a;
            padding: 16px 40px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .cta-btn-secondary:hover {
            border-color: #44634d;
            color: #44634d;
            transform: translateY(-2px);
        }

        /* Footer */
        .landing-footer {
            background: #0f1115;
            border-top: 1px solid #1e1e1e;
            padding: 40px 0;
            margin-top: 60px;
        }

        .footer-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #9ca3af;
        }

        .footer-links {
            display: flex;
            gap: 30px;
        }

        .footer-links a {
            color: #9ca3af;
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .footer-links a:hover {
            color: #44634d;
        }

        .footer-copyright {
            font-size: 14px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .hero-section {
                flex-direction: column;
                text-align: center;
            }
            
            .hero-description {
                margin-left: auto;
                margin-right: auto;
            }
            
            .hero-stats {
                justify-content: center;
            }
            
            .features-grid,
            .how-it-works {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                gap: 20px;
                padding: 0 20px;
            }
            
            .logo-section {
                flex-direction: column;
                text-align: center;
                gap: 10px;
            }
            
            .logo-svg {
                height: 45px;
            }
            
            .logo-fallback {
                font-size: 24px;
            }
            
            .tagline {
                border-left: none;
                padding-left: 0;
                border-top: 1px solid #2a2f3a;
                padding-top: 10px;
            }
            
            .hero-text h1 {
                font-size: 38px;
            }
            
            .features-grid,
            .how-it-works {
                grid-template-columns: 1fr;
            }
            
            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .footer-container {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            .footer-links {
                flex-wrap: wrap;
                justify-content: center;
            }
        }
    </style>
</head>
<body>

    <!-- Header with real logo from header.jsp -->
    <header class="landing-header">
        <div class="header-container">
            <div class="logo-section">
                <a href="index.jsp" class="logo-link">
                    <img src="images/logo.svg" alt="CyberSphere" class="logo-svg" 
                         onerror="this.onerror=null; this.src='images/logo.png'">
                    <span class="logo-fallback">🛡️ CyberSphere</span>
                </a>
                <span class="tagline">YOUR SECURITY PARTNER</span>
            </div>
            
            <div class="auth-buttons">
                <a href="login.jsp" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Login
                </a>
                <a href="signup.jsp" class="btn-signup">
                    <i class="fas fa-user-plus"></i> Sign Up
                </a>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="main-content">
        
        <!-- Hero Section -->
        <div class="hero-section">
            <div class="hero-text">
                <h1>Master <span>Cybersecurity</span><br>With Interactive Learning</h1>
                <p class="hero-description">
                    CyberSphere is your comprehensive platform for learning cybersecurity, 
                    detecting phishing attempts, and testing your knowledge through interactive 
                    quizzes at various difficulty levels.
                </p>
                <div class="hero-stats">
                    <div class="stat-item">
                        <span class="stat-number">10+</span>
                        <span class="stat-label">Interactive Quizzes</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">200+</span>
                        <span class="stat-label">Security Questions</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">24/7</span>
                        <span class="stat-label">Learning Resources</span>
                    </div>
                </div>
            </div>
            <div class="hero-image">
                <div class="feature-icons">
                    <div class="feature-icon-item">
                        <i class="fas fa-shield-alt"></i>
                        <h4>Phishing Detection</h4>
                        <p>Analyze emails for threats</p>
                    </div>
                    <div class="feature-icon-item">
                        <i class="fas fa-question-circle"></i>
                        <h4>Interactive Quizzes</h4>
                        <p>Test your knowledge</p>
                    </div>
                    <div class="feature-icon-item">
                        <i class="fas fa-graduation-cap"></i>
                        <h4>Learning Hub</h4>
                        <p>Curated resources</p>
                    </div>
                    <div class="feature-icon-item">
                        <i class="fas fa-trophy"></i>
                        <h4>Certificates</h4>
                        <p>Earn recognition</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- About Section - Long Description -->
        <div class="about-section">
            <h2 class="section-title"><span>About CyberSphere</span></h2>
            
            <p class="about-description">
                <strong>CyberSphere</strong> was founded with a single mission: to make cybersecurity education accessible, engaging, and effective for everyone. In today's digital age, where cyber threats are becoming increasingly sophisticated, we believe that knowledge is the first line of defense.
            </p>
            
            <p class="about-description">
                Our platform offers a comprehensive learning experience that adapts to your skill level. Whether you're a complete beginner just starting your cybersecurity journey or an experienced professional looking to sharpen your skills, CyberSphere provides the tools and resources you need to succeed.
            </p>
            
            <div class="features-grid">
                <div class="feature-card">
                    <i class="fas fa-brain"></i>
                    <h3>Adaptive Learning</h3>
                    <p>Our quizzes adjust to your knowledge level, providing personalized challenges that help you grow. Start with beginner concepts and progress to expert-level scenarios at your own pace.</p>
                </div>
                
                <div class="feature-card">
                    <i class="fas fa-envelope-open-text"></i>
                    <h3>Phishing Detection</h3>
                    <p>Learn to identify sophisticated phishing attempts with our real-world email analyzer. Understand the red flags that indicate malicious intent and protect yourself and your organization.</p>
                </div>
                
                <div class="feature-card">
                    <i class="fas fa-video"></i>
                    <h3>Curated Resources</h3>
                    <p>Access a vast library of videos, articles, and tutorials carefully selected by cybersecurity experts. Stay updated with the latest threats and defense mechanisms through our Learning Hub.</p>
                </div>
                
                <div class="feature-card">
                    <i class="fas fa-certificate"></i>
                    <h3>Progress Tracking</h3>
                    <p>Earn certificates as you complete levels, track your improvement over time, and identify areas that need more attention. Our detailed analytics help you focus your learning efforts.</p>
                </div>
                
                <div class="feature-card">
                    <i class="fas fa-lock"></i>
                    <h3>Real-World Scenarios</h3>
                    <p>Practice with simulations based on actual cybersecurity incidents. Learn how to respond to security breaches, identify vulnerabilities, and implement best practices.</p>
                </div>
                
                <div class="feature-card">
                    <i class="fas fa-users"></i>
                    <h3>Community Learning</h3>
                    <p>Join a community of security enthusiasts, share knowledge, and learn from peers. Our platform fosters collaborative learning through discussion forums and shared resources.</p>
                </div>
            </div>
        </div>

        <!-- How It Works -->
        <h2 class="section-title" style="margin-bottom: 30px;"><span>How It Works</span></h2>
        
        <div class="how-it-works">
            <div class="step-card">
                <div class="step-number">1</div>
                <h3>Create Your Account</h3>
                <p>Sign up for free and set up your profile. Choose your areas of interest and skill level to personalize your learning journey.</p>
            </div>
            
            <div class="step-card">
                <div class="step-number">2</div>
                <h3>Take Assessments</h3>
                <p>Start with our quizzes to assess your current knowledge. Our system will identify your strengths and areas for improvement.</p>
            </div>
            
            <div class="step-card">
                <div class="step-number">3</div>
                <h3>Learn & Improve</h3>
                <p>Access personalized learning resources based on your quiz results. Watch videos, read articles, and practice with our phishing detector.</p>
            </div>
        </div>

        <!-- Call to Action -->
        <div class="cta-section">
            <h2>Ready to Start Your Cybersecurity Journey?</h2>
            <p>Join thousands of learners who are already protecting themselves and their organizations with CyberSphere.</p>
            
            <div class="cta-buttons">
                <a href="signup.jsp" class="cta-btn-primary">
                    <i class="fas fa-user-plus"></i> Create Free Account
                </a>
                <a href="login.jsp" class="cta-btn-secondary">
                    <i class="fas fa-sign-in-alt"></i> Existing User? Login
                </a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="landing-footer">
        <div class="footer-container">
            <div class="footer-copyright">
                &copy; 2026 CyberSphere. All rights reserved.
            </div>
            <div class="footer-links">
                <a href="about.jsp">About</a>
                <a href="contact.jsp">Contact</a>
            </div>
        </div>
    </footer>

    <!-- Smooth scroll for anchor links -->
<script>
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // ✅ Replace this page in history + block going back to it
    history.replaceState(null, null, window.location.href);
    window.addEventListener('popstate', function() {
        history.pushState(null, null, window.location.href);
    });
</script>
</body>
</html>