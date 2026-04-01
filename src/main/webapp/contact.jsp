<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us | CyberSphere</title>
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

        /* Header */
        .contact-header {
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

        /* Main Content */
        .main-content {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* Page Title */
        .page-title {
            text-align: center;
            margin-bottom: 40px;
        }

        .page-title h1 {
            font-size: 36px;
            color: #ffffff;
            margin-bottom: 10px;
        }

        .page-title h1 span {
            color: #44634d;
        }

        .page-title p {
            color: #9ca3af;
            font-size: 16px;
        }

        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .alert-success {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }

        .alert-error {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }

        /* Contact Form */
        .contact-form {
            background: #0f1115;
            border-radius: 20px;
            padding: 40px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .form-title {
            color: #ffffff;
            font-size: 24px;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #1e1e1e;
        }

        .form-title i {
            color: #44634d;
            margin-right: 10px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            color: #9ca3af;
            font-size: 14px;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-group label i {
            color: #44634d;
            margin-right: 8px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            color: #ffffff;
            font-size: 15px;
            transition: all 0.2s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        .form-control::placeholder {
            color: #4b5563;
        }

        /* Phone Input Wrapper */
        .phone-input-wrapper {
            display: flex;
            align-items: center;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            overflow: hidden;
        }

        .phone-prefix {
            background: #2a2f3a;
            color: #44634d;
            padding: 14px 16px;
            font-weight: 600;
            font-size: 15px;
            border-right: 1px solid #3a3f4a;
            user-select: none;
        }

        .phone-input {
            flex: 1;
            padding: 14px 16px;
            background: #1a1e24;
            border: none;
            color: #ffffff;
            font-size: 15px;
        }

        .phone-input:focus {
            outline: none;
        }

        .phone-input::placeholder {
            color: #4b5563;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 150px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .btn-submit {
            background: #44634d;
            color: white;
            border: none;
            padding: 16px 30px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            justify-content: center;
            margin-top: 20px;
        }

        .btn-submit:hover {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        .btn-submit i {
            font-size: 18px;
        }

        /* Contact Info Cards (only Email and Phone) */
        .contact-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-top: 40px;
        }

        .info-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            text-align: center;
            transition: all 0.2s ease;
        }

        .info-card:hover {
            border-color: #44634d;
            transform: translateY(-3px);
        }

        .info-icon {
            width: 60px;
            height: 60px;
            background: #1a1e24;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            border: 1px solid #2a2f3a;
        }

        .info-icon i {
            font-size: 24px;
            color: #44634d;
        }

        .info-card h3 {
            color: #ffffff;
            font-size: 18px;
            margin-bottom: 10px;
        }

        .info-card p {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.6;
        }

        .info-card a {
            color: #44634d;
            text-decoration: none;
            font-weight: 500;
        }

        .info-card a:hover {
            text-decoration: underline;
        }

        /* FAQ Section */
        .faq-section {
            background: #0f1115;
            border-radius: 20px;
            padding: 40px;
            border: 1px solid #1e1e1e;
            margin-top: 40px;
        }

        .faq-section h2 {
            color: #ffffff;
            font-size: 24px;
            margin-bottom: 25px;
        }

        .faq-section h2 i {
            color: #44634d;
            margin-right: 10px;
        }

        .faq-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .faq-item {
            background: #1a1e24;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #2a2f3a;
        }

        .faq-item h3 {
            color: #ffffff;
            font-size: 16px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .faq-item h3 i {
            color: #44634d;
            font-size: 14px;
        }

        .faq-item p {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.5;
        }

        /* Footer */
        .contact-footer {
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
            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }
            
            .contact-info {
                grid-template-columns: 1fr;
            }
            
            .faq-grid {
                grid-template-columns: 1fr;
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
    <header class="contact-header">
        <div class="header-container">
            <div class="logo-section">
                <a href="index.jsp" class="logo-link">
                    <img src="images/logo.svg" alt="CyberSphere" class="logo-svg" 
                         onerror="this.onerror=null; this.src='images/logo.png'">
                </a>
                <span class="tagline">CONTACT US</span>
            </div>
            
            <div class="auth-buttons">
                <a href="login.jsp" class="btn-login">Login</a>
                <a href="signup.jsp" class="btn-signup">Sign Up</a>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="main-content">
        
        <!-- Page Title -->
        <div class="page-title">
            <h1>Get in <span>Touch</span></h1>
            <p>Have questions? We'd love to hear from you. Send us a message and we'll respond within 24 hours.</p>
        </div>

        <!-- Success/Error Messages -->
        <% 
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            
            if(success != null) { 
        %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <%= success %>
            </div>
        <% } %>
        
        <% if(error != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= error %>
            </div>
        <% } %>

        <!-- Contact Form -->
        <div class="contact-form">
            <h2 class="form-title"><i class="fas fa-paper-plane"></i>Send us a Message</h2>
            
            <form action="ContactServlet" method="post" onsubmit="return validateForm()">
                <div class="form-row">
                    <div class="form-group">
                        <label><i class="fas fa-user"></i> First Name *</label>
                        <input type="text" class="form-control" name="firstName" placeholder="John" required>
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-user"></i> Last Name</label>
                        <input type="text" class="form-control" name="lastName" placeholder="Doe">
                    </div>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> Email *</label>
                    <input type="email" class="form-control" name="email" placeholder="john.doe@example.com" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-phone"></i> Phone Number *</label>
                    <div class="phone-input-wrapper">
                        <span class="phone-prefix">+91</span>
                        <input type="tel" 
                               class="phone-input" 
                               name="phone" 
                               id="phoneInput"
                               placeholder="9876543210" 
                               maxlength="10"
                               oninput="validatePhoneInput(this)"
                               required>
                    </div>
                    <small style="color: #6b7280; display: block; margin-top: 5px;">
                        <i class="fas fa-info-circle"></i> Enter 10-digit mobile number
                    </small>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-tag"></i> Subject *</label>
                    <select class="form-control" name="subject" required>
                        <option value="" disabled selected>Select a subject</option>
                        <option value="general">General Inquiry</option>
                        <option value="support">Technical Support</option>
                        <option value="feedback">Feedback/Suggestion</option>
                        <option value="partnership">Partnership Opportunity</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-comment"></i> Message *</label>
                    <textarea class="form-control" name="message" placeholder="How can we help you?" required></textarea>
                </div>
                
                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> Send Message
                </button>
            </form>
        </div>

        <!-- Contact Info (Email and Phone only) -->
        <div class="contact-info">
            <div class="info-card">
                <div class="info-icon">
                    <i class="fas fa-envelope"></i>
                </div>
                <h3>Email Us</h3>
                <p>
                    <a href="mailto:cybersphere.contactus@gmail.com">cybersphere.contactus@gmail.com</a>
                </p>
                <p style="color: #6b7280; font-size: 12px; margin-top: 10px;">
                    We reply within 24 hours
                </p>
            </div>

            <div class="info-card">
                <div class="info-icon">
                    <i class="fas fa-phone-alt"></i>
                </div>
                <h3>Call Us</h3>
                <p>
                    <a href="tel:+919876543210">+91 98765 43210</a>
                </p>
                <p style="color: #6b7280; font-size: 12px; margin-top: 10px;">
                    Mon-Fri, 9am-6pm IST
                </p>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="faq-section">
            <h2><i class="fas fa-question-circle"></i> Frequently Asked Questions</h2>
            <div class="faq-grid">
                <div class="faq-item">
                    <h3><i class="fas fa-clock"></i> How fast is your response?</h3>
                    <p>We typically respond to all inquiries within 24 hours during business days.</p>
                </div>
                
                <div class="faq-item">
                    <h3><i class="fas fa-lock"></i> Is my information secure?</h3>
                    <p>Yes, all messages are encrypted and handled according to our privacy policy.</p>
                </div>
                
                <div class="faq-item">
                    <h3><i class="fas fa-question"></i> I forgot my password</h3>
                    <p>Use the "Forgot Password" link on the login page to reset your password.</p>
                </div>
                
                <div class="faq-item">
                    <h3><i class="fas fa-trophy"></i> How do I get certificates?</h3>
                    <p>Complete all 5 levels of a quiz with 35%+ score to earn your certificate.</p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="contact-footer">
        <div class="footer-container">
            <div>&copy; 2026 CyberSphere. All rights reserved.</div>
            <div class="footer-links">
                <a href="about.jsp">About</a>
                <a href="contact.jsp">Contact</a>
                <a href="#">Privacy</a>
                <a href="#">Terms</a>
            </div>
        </div>
    </footer>

    <script>
        // Phone number validation - only allow digits, max 10
        function validatePhoneInput(input) {
            // Remove any non-digit characters
            input.value = input.value.replace(/[^0-9]/g, '');
            
            // Limit to 10 digits
            if (input.value.length > 10) {
                input.value = input.value.slice(0, 10);
            }
        }
        
        // Form validation
        function validateForm() {
            const firstName = document.querySelector('input[name="firstName"]').value.trim();
            const email = document.querySelector('input[name="email"]').value.trim();
            const phone = document.querySelector('input[name="phone"]').value.trim();
            const subject = document.querySelector('select[name="subject"]').value;
            const message = document.querySelector('textarea[name="message"]').value.trim();
            
            // Validate first name
            if (firstName === '') {
                alert('Please enter your first name');
                return false;
            }
            
            // Validate email
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert('Please enter a valid email address');
                return false;
            }
            
            // Validate phone - exactly 10 digits
            if (phone.length !== 10) {
                alert('Please enter a valid 10-digit mobile number');
                return false;
            }
            
            // Validate subject
            if (subject === '' || subject === null) {
                alert('Please select a subject');
                return false;
            }
            
            // Validate message - at least 10 characters
            if (message.length < 10) {
                alert('Message must be at least 10 characters long');
                return false;
            }
            
            return true;
        }
        
        // Ensure phone input always has +91 prefix in backend
        document.querySelector('form').addEventListener('submit', function(e) {
            const phoneInput = document.querySelector('input[name="phone"]');
            // The +91 is already in the prefix, so we just send the digits
            // The servlet will combine them
        });
    </script>
</body>
</html>