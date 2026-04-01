<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%
    String token = request.getParameter("token");
    boolean validToken = false;
    String errorMessage = "";
    String email = "";
    String firstName = "";
    int userId = 0;
    
    // Database connection parameters
    String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    String DB_USER = "root";
    String DB_PASS = "root";
    
    if (token == null || token.trim().isEmpty()) {
        errorMessage = "No reset token provided.";
    } else {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Check if token exists and is not expired
            String sql = "SELECT id, email, first_name FROM users WHERE reset_token = ? AND reset_token_expiry > NOW()";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, token);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                validToken = true;
                userId = rs.getInt("id");
                email = rs.getString("email");
                firstName = rs.getString("first_name");
                
                session.setAttribute("resetUserId", userId);
                session.setAttribute("resetEmail", email);
                session.setAttribute("resetFirstName", firstName);
                session.setAttribute("resetToken", token);
            } else {
                // Check if token exists but expired
                String checkSql = "SELECT reset_token_expiry FROM users WHERE reset_token = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, token);
                ResultSet checkRs = checkStmt.executeQuery();
                
                if (checkRs.next()) {
                    Timestamp expiry = checkRs.getTimestamp("reset_token_expiry");
                    if (expiry != null && expiry.before(new Timestamp(System.currentTimeMillis()))) {
                        errorMessage = "This reset link has expired. Please request a new one.";
                    } else {
                        errorMessage = "Invalid reset token.";
                    }
                } else {
                    errorMessage = "Invalid reset token.";
                }
                checkRs.close();
                checkStmt.close();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Database error: " + e.getMessage();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    // Handle password reset form submission
    if (request.getMethod().equalsIgnoreCase("POST") && validToken) {
        String newPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String resetToken = request.getParameter("token");
        
        // Validate password
        boolean hasUpperCase = false;
        boolean hasLowerCase = false;
        boolean hasDigit = false;
        boolean hasSpecialChar = false;
        String specialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?";
        
        for (char c : newPassword.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpperCase = true;
            else if (Character.isLowerCase(c)) hasLowerCase = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else if (specialChars.indexOf(c) >= 0) hasSpecialChar = true;
        }
        
        boolean isValidLength = newPassword.length() >= 8;
        boolean isValidPassword = hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar && isValidLength;
        
        if (!isValidPassword) {
            response.sendRedirect("resetPassword.jsp?token=" + token + "&error=Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one digit, and one special character");
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("resetPassword.jsp?token=" + token + "&error=Passwords do not match");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Hash the new password
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            
            // Update password and clear reset token
            String sql = "UPDATE users SET password = ?, reset_token = NULL, reset_token_expiry = NULL WHERE reset_token = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, hashedPassword);
            stmt.setString(2, resetToken);
            
            int rowsUpdated = stmt.executeUpdate();
            
            if (rowsUpdated > 0) {
                response.sendRedirect("login.jsp?success=Password reset successful! Please login with your new password.");
            } else {
                response.sendRedirect("forgotPassword.jsp?error=Invalid or expired token. Please request a new one.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("resetPassword.jsp?token=" + token + "&error=Database error occurred");
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Reset Password | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CyberSphere dark theme */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
            background: #0a0c10;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
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
            width: 450px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
            z-index: 1;
        }

        /* CyberSphere header */
        .cybersphere-header {
            margin-bottom: 30px;
            text-align: center;
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 10px;
        }

        .logo i {
            font-size: 32px;
            color: #44634d;
        }

        .logo h1 {
            font-size: 28px;
            font-weight: 600;
            color: #ffffff;
            letter-spacing: -0.02em;
        }

        .logo span {
            color: #44634d;
        }

        .tagline {
            color: #9ca3af;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        h2 {
            color: #44634d;
            font-size: 24px;
            font-weight: 500;
            margin-bottom: 15px;
            border-left: 3px solid #44634d;
            padding-left: 15px;
        }

        .welcome-text {
            color: #9ca3af;
            font-size: 14px;
            margin-bottom: 25px;
            background: #1a1e24;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #2a2f3a;
        }

        .welcome-text i {
            color: #44634d;
            margin-right: 8px;
        }

        .error {
            background: #2c1515;
            color: #f87171;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
            text-align: left;
            border-left: 3px solid #ef4444;
            border: 1px solid #3f1f1f;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .error i {
            font-size: 16px;
        }

        .success {
            background: #1a2e1a;
            color: #86efac;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
            text-align: left;
            border-left: 3px solid #44634d;
            border: 1px solid #2a4a2a;
            display: flex;
            align-items: center;
            gap: 10px;
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
            margin-right: 6px;
        }

        .password-box {
            position: relative;
        }

        input {
            width: 100%;
            padding: 14px 16px;
            border-radius: 10px;
            border: 1px solid #2a2f3a;
            outline: none;
            background: #1a1e24;
            color: #ffffff;
            font-size: 15px;
            transition: all 0.2s ease;
        }

        input:focus {
            border-color: #44634d;
            background: #1f242b;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        .eye {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #6b7280;
            font-size: 18px;
            transition: color 0.2s ease;
        }

        .eye:hover {
            color: #44634d;
        }

        /* Password Requirements */
        .password-requirements {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            padding: 16px;
            margin: 15px 0 20px;
        }

        .requirement {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 8px 0;
            font-size: 13px;
            color: #9ca3af;
        }

        .requirement i {
            font-size: 14px;
        }

        .requirement.met {
            color: #86efac;
        }

        .requirement.met i {
            color: #86efac;
        }

        /* Password Strength Bar */
        .strength-bar {
            height: 4px;
            background: #1a1e24;
            border-radius: 2px;
            margin: 15px 0 5px;
            overflow: hidden;
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
        }

        .strength-fill.weak {
            width: 25%;
            background: #f87171;
        }

        .strength-fill.medium {
            width: 50%;
            background: #fbbf24;
        }

        .strength-fill.strong {
            width: 75%;
            background: #86efac;
        }

        .strength-fill.very-strong {
            width: 100%;
            background: #44634d;
        }

        .strength-text {
            font-size: 12px;
            color: #9ca3af;
            text-align: right;
            margin-bottom: 10px;
        }

        button {
            width: 100%;
            padding: 16px;
            background: #44634d;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            margin: 20px 0 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        button:hover:not(:disabled) {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        button:disabled {
            background: #2a2f3a;
            cursor: not-allowed;
            opacity: 0.5;
        }

        .links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .links a {
            color: #9ca3af;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .links a:hover {
            color: #44634d;
        }

        .invalid-card {
            text-align: center;
        }

        .invalid-card i {
            font-size: 48px;
            color: #f87171;
            margin-bottom: 20px;
        }

        .invalid-card h3 {
            color: #ffffff;
            font-size: 22px;
            margin-bottom: 10px;
        }

        .invalid-card p {
            color: #9ca3af;
            margin-bottom: 25px;
        }

        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #44634d;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            margin: 5px;
            transition: all 0.2s ease;
        }

        .btn:hover {
            background: #36523d;
            transform: translateY(-2px);
        }

        .btn-outline {
            background: transparent;
            border: 1px solid #2a2f3a;
            color: #9ca3af;
        }

        .btn-outline:hover {
            background: #1a1e24;
            color: #ffffff;
            border-color: #44634d;
        }

        @media (max-width: 480px) {
            .card {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>

<div class="card">
    <div class="cybersphere-header">
        <div class="logo">
            <i class="fas fa-shield-halved"></i>
            <h1>Cyber<span>Sphere</span></h1>
        </div>
        <div class="tagline">YOUR SECURITY PARTNER</div>
    </div>

    <% if (!validToken) { %>
        <!-- Invalid Token View -->
        <div class="invalid-card">
            <i class="fas fa-exclamation-triangle"></i>
            <h3>Invalid or Expired Link</h3>
            <p><%= errorMessage.isEmpty() ? "The password reset link is invalid or has expired." : errorMessage %></p>
            <div style="display: flex; gap: 10px; justify-content: center; margin-top: 20px;">
                <a href="forgotPassword.jsp" class="btn">
                    <i class="fas fa-redo-alt"></i> Request New Link
                </a>
                <a href="login.jsp" class="btn btn-outline">
                    <i class="fas fa-arrow-left"></i> Back to Login
                </a>
            </div>
        </div>
    <% } else { %>
        <!-- Valid Token View -->
        <h2><i class="fas fa-key"></i> Reset Password</h2>
        
        <div class="welcome-text">
            <i class="fas fa-user-circle"></i> Hello, <%= firstName != null ? firstName : "User" %>! Enter your new password below.
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="error">
                <i class="fas fa-exclamation-circle"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <form method="post" action="resetPassword.jsp" onsubmit="return validateForm()">
            <input type="hidden" name="token" value="<%= token %>">
            
            <div class="form-group">
                <label><i class="fas fa-lock"></i> New Password</label>
                <div class="password-box">
                    <input type="password" id="password" name="password" placeholder="Enter new password" required onkeyup="checkPasswordStrength()">
                    <span class="eye" onclick="togglePassword('password')">👁️</span>
                </div>
            </div>

            <!-- Password Requirements -->
            <div class="password-requirements">
                <div class="requirement" id="req-length">
                    <i class="fas fa-circle"></i> At least 8 characters
                </div>
                <div class="requirement" id="req-uppercase">
                    <i class="fas fa-circle"></i> One uppercase letter (A-Z)
                </div>
                <div class="requirement" id="req-lowercase">
                    <i class="fas fa-circle"></i> One lowercase letter (a-z)
                </div>
                <div class="requirement" id="req-digit">
                    <i class="fas fa-circle"></i> One digit (0-9)
                </div>
                <div class="requirement" id="req-special">
                    <i class="fas fa-circle"></i> One special character (!@#$%^&*)
                </div>
            </div>

            <!-- Password Strength -->
            <div class="strength-bar">
                <div class="strength-fill" id="strengthFill"></div>
            </div>
            <div class="strength-text" id="strengthText">Enter password</div>

            <div class="form-group">
                <label><i class="fas fa-lock"></i> Confirm Password</label>
                <div class="password-box">
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password" required onkeyup="checkPasswordMatch()">
                    <span class="eye" onclick="togglePassword('confirmPassword')">👁️</span>
                </div>
                <div id="matchMessage" style="font-size: 12px; margin-top: 5px; color: #f87171;"></div>
            </div>

            <button type="submit" id="submitBtn" disabled>
                <i class="fas fa-save"></i> Reset Password
            </button>
        </form>

        <div class="links">
            <a href="login.jsp"><i class="fas fa-arrow-left"></i> Back to Login</a>
            <a href="forgotPassword.jsp"><i class="fas fa-redo-alt"></i> Request New Link</a>
        </div>
    <% } %>
</div>

<script>
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        field.type = field.type === 'password' ? 'text' : 'password';
    }

    function checkPasswordStrength() {
        const password = document.getElementById('password').value;
        
        // Check requirements
        const hasLength = password.length >= 8;
        const hasUppercase = /[A-Z]/.test(password);
        const hasLowercase = /[a-z]/.test(password);
        const hasDigit = /[0-9]/.test(password);
        const hasSpecial = /[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]/.test(password);
        
        // Update requirement icons
        updateRequirement('req-length', hasLength);
        updateRequirement('req-uppercase', hasUppercase);
        updateRequirement('req-lowercase', hasLowercase);
        updateRequirement('req-digit', hasDigit);
        updateRequirement('req-special', hasSpecial);
        
        // Calculate strength
        const requirements = [hasLength, hasUppercase, hasLowercase, hasDigit, hasSpecial];
        const metCount = requirements.filter(Boolean).length;
        
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');
        
        // Remove all classes
        strengthFill.classList.remove('weak', 'medium', 'strong', 'very-strong');
        
        if (password.length === 0) {
            strengthFill.style.width = '0%';
            strengthText.innerText = 'Enter password';
        } else if (metCount <= 2) {
            strengthFill.classList.add('weak');
            strengthText.innerText = 'Weak password';
        } else if (metCount === 3) {
            strengthFill.classList.add('medium');
            strengthText.innerText = 'Medium password';
        } else if (metCount === 4) {
            strengthFill.classList.add('strong');
            strengthText.innerText = 'Strong password';
        } else if (metCount === 5) {
            strengthFill.classList.add('very-strong');
            strengthText.innerText = 'Very strong password';
        }
        
        // Check if all requirements are met
        const allMet = hasLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;
        
        if (allMet) {
            document.querySelector('.password-requirements').style.borderColor = '#44634d';
        } else {
            document.querySelector('.password-requirements').style.borderColor = '#2a2f3a';
        }
        
        // Check password match
        checkPasswordMatch();
    }

    function updateRequirement(elementId, met) {
        const element = document.getElementById(elementId);
        const icon = element.querySelector('i');
        
        if (met) {
            element.classList.add('met');
            icon.className = 'fas fa-check-circle';
        } else {
            element.classList.remove('met');
            icon.className = 'fas fa-circle';
        }
    }

    function checkPasswordMatch() {
        const password = document.getElementById('password').value;
        const confirm = document.getElementById('confirmPassword').value;
        const matchMessage = document.getElementById('matchMessage');
        const submitBtn = document.getElementById('submitBtn');
        
        // Check all password requirements
        const hasLength = password.length >= 8;
        const hasUppercase = /[A-Z]/.test(password);
        const hasLowercase = /[a-z]/.test(password);
        const hasDigit = /[0-9]/.test(password);
        const hasSpecial = /[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]/.test(password);
        const allRequirementsMet = hasLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;
        
        if (confirm.length > 0) {
            if (password === confirm) {
                matchMessage.innerHTML = '✅ Passwords match';
                matchMessage.style.color = '#86efac';
                
                // Enable submit only if all requirements are met
                submitBtn.disabled = !allRequirementsMet;
            } else {
                matchMessage.innerHTML = '❌ Passwords do not match';
                matchMessage.style.color = '#f87171';
                submitBtn.disabled = true;
            }
        } else {
            matchMessage.innerHTML = '';
            submitBtn.disabled = true;
        }
    }

    function validateForm() {
        const password = document.getElementById('password').value;
        const confirm = document.getElementById('confirmPassword').value;
        
        // Check all requirements
        const hasLength = password.length >= 8;
        const hasUppercase = /[A-Z]/.test(password);
        const hasLowercase = /[a-z]/.test(password);
        const hasDigit = /[0-9]/.test(password);
        const hasSpecial = /[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]/.test(password);
        
        if (!hasLength || !hasUppercase || !hasLowercase || !hasDigit || !hasSpecial) {
            alert('Password must meet all requirements:\n' +
                  '- At least 8 characters\n' +
                  '- One uppercase letter\n' +
                  '- One lowercase letter\n' +
                  '- One digit\n' +
                  '- One special character');
            return false;
        }
        
        if (password !== confirm) {
            alert('Passwords do not match');
            return false;
        }
        
        return true;
    }
</script>

</body>
</html>