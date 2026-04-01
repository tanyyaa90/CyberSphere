<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>CyberSphere | Sign Up</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #0a0c10 0%, #0f1115 100%);
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #e5e7eb;
            padding: 20px;
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

        .card {
            background: #0f1115;
            padding: 40px;
            border-radius: 24px;
            width: 500px;
            max-width: 100%;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
            z-index: 1;
            transition: transform 0.3s ease;
            max-height: 90vh;
            overflow-y: auto;
        }

        .card::-webkit-scrollbar {
            width: 6px;
        }

        .card::-webkit-scrollbar-track {
            background: #1a1e24;
            border-radius: 3px;
        }

        .card::-webkit-scrollbar-thumb {
            background: #44634d;
            border-radius: 3px;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .cybersphere-header {
            margin-bottom: 28px;
            text-align: center;
        }

        .cybersphere-header h1 {
            font-size: 32px;
            font-weight: 700;
            letter-spacing: -0.02em;
            background: linear-gradient(135deg, #ffffff 0%, #44634d 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin: 0;
        }

        .cybersphere-header p {
            color: #6b7280;
            font-size: 14px;
            margin-top: 8px;
        }

        h2 {
            text-align: left;
            margin-bottom: 28px;
            color: #ffffff;
            font-size: 24px;
            font-weight: 600;
            letter-spacing: -0.01em;
            position: relative;
            display: inline-block;
        }

        h2::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 50px;
            height: 3px;
            background: linear-gradient(90deg, #44634d, #5a8066);
            border-radius: 2px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 0;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
            color: #9ca3af;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        label i {
            margin-right: 6px;
            color: #44634d;
        }

        .input-wrapper {
            position: relative;
            width: 100%;
        }

        input {
            width: 100%;
            padding: 12px 14px;
            border-radius: 10px;
            border: 1px solid #2a2f3a;
            outline: none;
            background: #1a1e24;
            color: #ffffff;
            font-size: 14px;
            transition: all 0.2s ease;
            font-family: 'Inter', sans-serif;
        }

        input:focus {
            border-color: #44634d;
            background: #1f242b;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        input::placeholder {
            color: #4b5563;
            font-size: 13px;
        }

        .username-status {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 12px;
            font-weight: 500;
            z-index: 2;
        }

        .status-available {
            color: #86efac;
        }

        .status-available i {
            color: #86efac;
        }

        .status-unavailable {
            color: #f87171;
        }

        .status-unavailable i {
            color: #f87171;
        }

        .status-checking {
            color: #fbbf24;
        }

        .password-box {
            position: relative;
        }

        .password-box input {
            padding-right: 45px;
        }

        .eye {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #6b7280;
            user-select: none;
            z-index: 10;
            font-size: 18px;
            transition: color 0.2s ease;
        }

        .eye:hover {
            color: #44634d;
        }

        .password-requirements {
            background: #1a1e24;
            padding: 12px;
            border-radius: 10px;
            margin-top: 10px;
            border: 1px solid #2a2f3a;
        }

        .requirement {
            font-size: 11px;
            margin: 5px 0;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #6b7280;
            transition: all 0.2s ease;
        }

        .requirement.met {
            color: #86efac;
        }

        .requirement i {
            width: 16px;
            font-size: 10px;
        }

        .error-msg {
            background: #2c1515;
            color: #f87171;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 20px;
            border-left: 3px solid #ef4444;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .success-msg {
            background: #1a2e1a;
            color: #86efac;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 20px;
            border-left: 3px solid #44634d;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        small {
            font-size: 11px;
            color: #f87171;
            display: block;
            margin-top: 5px;
            margin-left: 4px;
        }

        button {
            margin-top: 8px;
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #44634d 0%, #36523d 100%);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            letter-spacing: 0.01em;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        button:hover {
            background: linear-gradient(135deg, #36523d 0%, #2a4233 100%);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.4);
        }

        button:active {
            transform: translateY(0);
        }

        button:disabled {
            background: #2a2f3a;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .link {
            text-align: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #1e1e1e;
            font-size: 14px;
            color: #9ca3af;
        }

        .link a {
            color: #44634d;
            text-decoration: none;
            font-weight: 600;
            margin-left: 6px;
            transition: color 0.2s ease;
        }

        .link a:hover {
            color: #5a7e64;
            text-decoration: underline;
        }

        .phone-input-wrapper {
            display: flex;
            align-items: center;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            overflow: hidden;
        }

        .phone-input-wrapper span {
            padding: 12px 14px;
            background: #13171d;
            color: #9ca3af;
            font-weight: 500;
            border-right: 1px solid #2a2f3a;
            font-size: 14px;
        }

        .phone-input-wrapper input {
            border: none;
            border-radius: 0;
            flex: 1;
        }

        .phone-input-wrapper input:focus {
            box-shadow: none;
        }

        @media (max-width: 550px) {
            .card {
                padding: 28px;
            }
            
            h2 {
                font-size: 20px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }
        }
    </style>

    <script>
        let usernameTimeout;
        let lastCheckedUsername = "";

        function togglePassword(id) {
            let field = document.getElementById(id);
            let eyeIcon = field.nextElementSibling;
            if (field.type === "password") {
                field.type = "text";
                eyeIcon.textContent = "👁️‍🗨️";
            } else {
                field.type = "password";
                eyeIcon.textContent = "👁";
            }
        }

        function validatePhone() {
            const phoneInput = document.getElementById("phone");
            const phoneError = document.getElementById("phoneError");
            let value = phoneInput.value.replace(/\D/g, '');

            if (value.length !== 10) {
                phoneError.innerText = "Phone number must contain exactly 10 digits";
                return false;
            }

            phoneError.innerText = "";
            phoneInput.value = value;
            return true;
        }

        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const requirements = {
                length: password.length >= 8,
                capital: /[A-Z]/.test(password),
                number: /\d/.test(password),
                special: /[@$!%*?&]/.test(password)
            };

            document.getElementById('req-length').className = requirements.length ? 'requirement met' : 'requirement';
            document.getElementById('req-capital').className = requirements.capital ? 'requirement met' : 'requirement';
            document.getElementById('req-number').className = requirements.number ? 'requirement met' : 'requirement';
            document.getElementById('req-special').className = requirements.special ? 'requirement met' : 'requirement';

            return requirements.length && requirements.capital && requirements.number && requirements.special;
        }

        function checkUsernameAvailability() {
            const username = document.getElementById('username').value;
            const statusDiv = document.getElementById('usernameStatus');
            
            if (username.length < 3) {
                statusDiv.innerHTML = '';
                statusDiv.className = 'username-status';
                lastCheckedUsername = "";
                return;
            }

            clearTimeout(usernameTimeout);
            statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
            statusDiv.className = 'username-status status-checking';

            usernameTimeout = setTimeout(function() {
                const xhr = new XMLHttpRequest();
                xhr.open('GET', '<%= request.getContextPath() %>/checkUsername?username=' + encodeURIComponent(username), true);
                
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        const response = JSON.parse(xhr.responseText);
                        lastCheckedUsername = username;
                        
                        if (response.available) {
                            statusDiv.innerHTML = '<i class="fas fa-check-circle"></i> Available';
                            statusDiv.className = 'username-status status-available';
                        } else {
                            statusDiv.innerHTML = '<i class="fas fa-times-circle"></i> ' + (response.message || 'Taken');
                            statusDiv.className = 'username-status status-unavailable';
                        }
                    }
                };
                xhr.send();
            }, 500);
        }

        function validateForm() {
            let email = document.forms["signup"]["email"].value;
            let password = document.forms["signup"]["password"].value;
            let confirm = document.forms["signup"]["confirmPassword"].value;
            let username = document.forms["signup"]["username"].value;
            let phone = document.getElementById("phone").value;
            let firstName = document.forms["signup"]["firstName"].value;
            
            if (!firstName || firstName.trim() === "") {
                alert("First name is required");
                return false;
            }
            
            if (!username || username.trim() === "") {
                alert("Username is required");
                return false;
            }
            
            if (!email || email.trim() === "") {
                alert("Email is required");
                return false;
            }
            
            if (!password || password.trim() === "") {
                alert("Password is required");
                return false;
            }
            
            let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            let passPattern = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$/;

            if(!emailPattern.test(email)){
                alert("Please enter a valid email address");
                return false;
            }

            if(!passPattern.test(password)){
                alert("Password must contain at least 8 characters, 1 capital letter, 1 number, and 1 special character");
                return false;
            }

            if(password !== confirm){
                alert("Passwords do not match");
                return false;
            }

            if(!validatePhone()){
                alert("Please enter a valid 10-digit phone number");
                return false;
            }

            const usernameStatus = document.getElementById('usernameStatus');
            if (!usernameStatus.classList.contains('status-available')) {
                alert("Please choose a different username - this one is not available");
                return false;
            }

            return true;
        }

        document.addEventListener('DOMContentLoaded', function() {
            const phoneInput = document.getElementById('phone');
            phoneInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 10) value = value.slice(0, 10);
                e.target.value = value;
                validatePhone();
            });
        });
    </script>
</head>

<body>
<div class="card">
    <div class="cybersphere-header">
        <h1>CyberSphere</h1>
        <p>Join the cybersecurity community</p>
    </div>

    <h2>Create Account</h2>

    <% if(request.getParameter("error") != null) { %>
        <div class="error-msg">
            <i class="fas fa-exclamation-triangle"></i>
            <%= request.getParameter("error") %>
        </div>
    <% } %>

    <% if(request.getParameter("success") != null) { %>
        <div class="success-msg">
            <i class="fas fa-check-circle"></i>
            <%= request.getParameter("success") %>
        </div>
    <% } %>

    <form name="signup"
          action="<%= request.getContextPath() %>/SignUpServlet"
          method="post"
          onsubmit="return validateForm()"
          autocomplete="off">

        <div class="form-row">
            <div class="form-group">
                <label><i class="fas fa-user"></i> First Name *</label>
                <input type="text" name="firstName" placeholder="Enter your first name" autocomplete="off" required>
            </div>

            <div class="form-group">
                <label><i class="fas fa-user"></i> Last Name</label>
                <input type="text" name="lastName" placeholder="Last name (optional)" autocomplete="off">
            </div>
        </div>

        <div class="form-group">
            <label><i class="fas fa-at"></i> Username *</label>
            <div class="input-wrapper">
                <input type="text" id="username" name="username" placeholder="Choose a unique username" 
                       autocomplete="off" onkeyup="checkUsernameAvailability()" required>
                <div id="usernameStatus" class="username-status"></div>
            </div>
        </div>

        <div class="form-group">
            <label><i class="fas fa-envelope"></i> Email *</label>
            <input type="email" name="email" placeholder="your@email.com" autocomplete="off" required>
        </div>

        <div class="form-group">
            <label><i class="fas fa-phone"></i> Phone Number *</label>
            <div class="phone-input-wrapper">
                <span>+91</span>
                <input type="tel" id="phone" name="phone" placeholder="9876543210" 
                       maxlength="10" autocomplete="off" required>
            </div>
            <small id="phoneError"></small>
        </div>

        <div class="form-group">
            <label><i class="fas fa-lock"></i> Password *</label>
            <div class="password-box">
                <input type="password" id="password" name="password"
                       placeholder="Create a strong password"
                       autocomplete="new-password"
                       onkeyup="checkPasswordStrength()"
                       required>
                <span class="eye" onclick="togglePassword('password')">👁</span>
            </div>
            <div class="password-requirements">
                <div id="req-length" class="requirement">
                    <i class="fas fa-circle"></i> At least 8 characters
                </div>
                <div id="req-capital" class="requirement">
                    <i class="fas fa-circle"></i> One capital letter (A-Z)
                </div>
                <div id="req-number" class="requirement">
                    <i class="fas fa-circle"></i> One number (0-9)
                </div>
                <div id="req-special" class="requirement">
                    <i class="fas fa-circle"></i> One special character (@$!%*?&)
                </div>
            </div>
        </div>

        <div class="form-group">
            <label><i class="fas fa-check-circle"></i> Confirm Password *</label>
            <div class="password-box">
                <input type="password" id="confirmPassword" name="confirmPassword"
                       placeholder="Re-enter your password"
                       autocomplete="new-password"
                       required>
                <span class="eye" onclick="togglePassword('confirmPassword')">👁</span>
            </div>
        </div>

        <button type="submit">
            <i class="fas fa-arrow-right"></i> Create Account
        </button>
    </form>

    <div class="link">
        Already have an account?
        <a href="login.jsp">Sign in →</a>
    </div>
</div>
</body>
</html>