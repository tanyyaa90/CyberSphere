<%@ page contentType="text/html;charset=UTF-8" %>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <title>CyberSphere | Forgot Password</title>
    <style>
        /* CyberSphere dark theme - matching login.jsp */
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
            background: #0a0c10;  /* Dark charcoal background */
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #e5e7eb;
            padding: 20px;
            position: relative;
        }

        /* Cyber icons background pattern - matching login.jsp */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.08"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-repeat: repeat;
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        /* Main container */
        .card {
            background: #0f1115;  /* Slightly lighter than background */
            padding: 40px;
            border-radius: 16px;
            width: 480px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
            z-index: 1;
        }

        /* CyberSphere header */
        .cybersphere-header {
            margin-bottom: 24px;
        }

        h1 {
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.02em;
            color: #ffffff;
            margin: 0;
        }

        h2 {
            text-align: left;
            margin-bottom: 8px;
            color: #44634d;  /* Forest green accent */
            font-size: 20px;
            font-weight: 500;
            letter-spacing: -0.01em;
            border-left: 3px solid #44634d;
            padding-left: 12px;
        }
        
        .subtitle {
            color: #9ca3af;
            font-size: 14px;
            margin-bottom: 28px;
            margin-left: 15px;
        }
        
        /* Toggle Switch Styles - updated with CyberSphere theme */
        .toggle-container {
            display: flex;
            gap: 16px;
            margin-bottom: 28px;
        }
        
        .toggle-option {
            flex: 1;
            text-align: center;
            padding: 20px 0;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid #2a2f3a;
            background: #1a1e24;
        }
        
        .toggle-option:hover {
            border-color: #44634d;
            background: #1f242b;
        }
        
        .toggle-option.active {
            border: 2px solid #44634d;
            background: #1f2e25;
            box-shadow: 0 0 20px rgba(68, 99, 77, 0.2);
        }
        
        .toggle-option .icon {
            font-size: 32px;
            margin-bottom: 8px;
        }
        
        .toggle-option .label {
            font-size: 16px;
            font-weight: 600;
            color: #e5e7eb;
        }
        
        .toggle-option .sub-label {
            font-size: 12px;
            color: #9ca3af;
            margin-top: 5px;
        }
        
        .toggle-option.active .icon,
        .toggle-option.active .label,
        .toggle-option.active .sub-label {
            color: #86efac;
        }
        
        /* Input Container Styles */
        .input-container {
            margin-bottom: 25px;
            animation: slideDown 0.3s ease;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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
        
        .input-wrapper {
            display: flex;
            align-items: center;
            background: #1a1e24;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #2a2f3a;
            transition: all 0.2s ease;
        }
        
        .input-wrapper:focus-within {
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }
        
        .country-code {
            background: #1e242b;
            color: #44634d;
            padding: 12px 15px;
            font-weight: 600;
            border-right: 1px solid #2a2f3a;
            user-select: none;
        }
        
        .input-wrapper input {
            flex: 1;
            padding: 12px 15px;
            border: none;
            outline: none;
            background: #1a1e24;
            color: #ffffff;
            font-size: 15px;
        }
        
        .input-wrapper input::placeholder {
            color: #4b5563;
        }
        
        .input-wrapper input:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #151a20;
        }
        
        .email-icon {
            padding: 0 15px;
            color: #44634d;
        }
        
        button {
            width: 100%;
            padding: 14px;
            background: #44634d;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            letter-spacing: 0.01em;
            margin-top: 10px;
        }
        
        button:hover:not(:disabled) {
            background: #36523d;
            transform: translateY(-1px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #2a2f3a;
        }
        
        /* Message styles */
        .message {
            background: #1a2e1a;
            color: #86efac;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
            text-align: left;
            border-left: 3px solid #44634d;
            border: 1px solid #2a4a2a;
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
        }
        
        .warning {
            background: #2c2415;
            color: #fbbf24;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
            text-align: left;
            border-left: 3px solid #f59e0b;
            border: 1px solid #3f341f;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: #9ca3af;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s ease;
        }
        
        .back-link a:hover {
            color: #44634d;
        }
        
        .note {
            text-align: center;
            color: #6b7280;
            font-size: 12px;
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px solid #1e1e1e;
        }
        
        /* Mobile number hint */
        .mobile-hint {
            font-size: 12px;
            color: #6b7280;
            margin-top: 5px;
            margin-left: 4px;
        }
    </style>
</head>
<body>
    <div class="card">
        <!-- CyberSphere header - matching login.jsp -->
        <div class="cybersphere-header">
            <h1>CyberSphere</h1>
        </div>
        
        <h2>🔐 Forgot Password</h2>
        <div class="subtitle">Choose how you want to reset your password</div>
        
        <% if(request.getAttribute("message") != null) { %>
            <div class="message"><%= request.getAttribute("message") %></div>
        <% } %>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <% if(request.getAttribute("warning") != null) { %>
            <div class="warning"><%= request.getAttribute("warning") %></div>
        <% } %>
        
        <form action="forgotPassword" method="post" id="resetForm">
            <!-- Hidden input for method -->
            <input type="hidden" name="method" id="methodInput" value="email">
            
            <!-- Toggle Buttons -->
            <div class="toggle-container">
                <div class="toggle-option email active" onclick="selectMethod('email')" id="emailOption">
                    <div class="icon">📧</div>
                    <div class="label">Email</div>
                    <div class="sub-label">Get reset link via email</div>
                </div>
                <div class="toggle-option mobile" onclick="selectMethod('mobile')" id="mobileOption">
                    <div class="icon">📱</div>
                    <div class="label">Mobile</div>
                    <div class="sub-label">Get reset code via SMS</div>
                </div>
            </div>
            
            <!-- Email Input (shown by default) -->
            <div class="input-container" id="emailInput">
                <label>Email Address</label>
                <div class="input-wrapper">
                    <span class="email-icon">📧</span>
                    <input type="email" 
                           name="contact" 
                           id="emailField"
                           placeholder="your@email.com" 
                           value="<%= request.getParameter("contact") != null ? request.getParameter("contact") : "" %>">
                </div>
            </div>
            
            <!-- Mobile Input (hidden by default) -->
            <div class="input-container" id="mobileInput" style="display: none;">
                <label>Mobile Number</label>
                <div class="input-wrapper">
                    <span class="country-code">+91</span>
                    <input type="tel" 
                           name="contact" 
                           id="mobileField"
                           placeholder="9876543210" 
                           pattern="[0-9]{10}" 
                           maxlength="10"
                           value="<%= request.getParameter("contact") != null && request.getParameter("method") != null && request.getParameter("method").equals("mobile") ? request.getParameter("contact").replace("+91", "") : "" %>"
                           disabled>
                </div>
                <div class="mobile-hint">
                    Enter 10-digit mobile number without country code
                </div>
            </div>
            
            <button type="submit" id="submitBtn">Send Reset Instructions</button>
        </form>
        
        <div class="back-link">
            <a href="login.jsp">← Back to Login</a>
        </div>
        
        <div class="note">
            We'll send you a secure link or code to reset your password
        </div>
    </div>
    
    <script>
        function selectMethod(method) {
            // Update hidden input
            document.getElementById('methodInput').value = method;
            
            // Update toggle buttons appearance
            const emailOption = document.getElementById('emailOption');
            const mobileOption = document.getElementById('mobileOption');
            const emailInput = document.getElementById('emailInput');
            const mobileInput = document.getElementById('mobileInput');
            const emailField = document.getElementById('emailField');
            const mobileField = document.getElementById('mobileField');
            
            if (method === 'email') {
                // Email selected
                emailOption.classList.add('active');
                mobileOption.classList.remove('active');
                
                // Show email input, hide mobile input
                emailInput.style.display = 'block';
                mobileInput.style.display = 'none';
                
                // Enable/disable fields
                emailField.disabled = false;
                mobileField.disabled = true;
                mobileField.value = ''; // Clear mobile field
                
                // Update placeholder
                emailField.placeholder = 'your@email.com';
                emailField.focus();
                
            } else {
                // Mobile selected
                mobileOption.classList.add('active');
                emailOption.classList.remove('active');
                
                // Show mobile input, hide email input
                mobileInput.style.display = 'block';
                emailInput.style.display = 'none';
                
                // Enable/disable fields
                mobileField.disabled = false;
                emailField.disabled = true;
                emailField.value = ''; // Clear email field
                
                // Format mobile number as user types
                mobileField.placeholder = '9876543210';
                mobileField.focus();
            }
        }
        
        // Format mobile number to only allow digits and ensure +91 prefix in backend
        document.addEventListener('DOMContentLoaded', function() {
            const mobileField = document.getElementById('mobileField');
            
            mobileField.addEventListener('input', function(e) {
                // Remove any non-digit characters
                this.value = this.value.replace(/[^0-9]/g, '');
                
                // Limit to 10 digits
                if (this.value.length > 10) {
                    this.value = this.value.slice(0, 10);
                }
            });
            
            // Form validation before submit
            document.getElementById('resetForm').addEventListener('submit', function(e) {
                const method = document.getElementById('methodInput').value;
                
                if (method === 'email') {
                    const email = document.getElementById('emailField').value;
                    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                    if (!email || !emailPattern.test(email)) {
                        e.preventDefault();
                        alert('Please enter a valid email address');
                    }
                } else {
                    const mobile = document.getElementById('mobileField').value;
                    if (!mobile || mobile.length !== 10 || !/^\d+$/.test(mobile)) {
                        e.preventDefault();
                        alert('Please enter a valid 10-digit mobile number');
                    } else {
                        // Add +91 prefix before submitting
                        // This will be handled by the servlet
                        console.log('Mobile number with +91: +91' + mobile);
                    }
                }
            });
            
            // Check URL parameters to pre-select method if coming back with error
            <%
                // Get parameters - use a different variable name to avoid conflict
                String forgotMethod = request.getParameter("method");
                String contactParam = request.getParameter("contact");
                
                if ("mobile".equals(forgotMethod)) {
            %>
                selectMethod('mobile');
                <% if (contactParam != null && !contactParam.isEmpty()) { %>
                    // Pre-fill mobile field after DOM is loaded
                    setTimeout(function() {
                        document.getElementById('mobileField').value = '<%= contactParam.replace("+91", "") %>';
                    }, 200);
                <% } %>
            <%
                } else {
            %>
                selectMethod('email');
                <% if (contactParam != null && !contactParam.isEmpty()) { %>
                    // Pre-fill email field after DOM is loaded
                    setTimeout(function() {
                        document.getElementById('emailField').value = '<%= contactParam %>';
                    }, 200);
                <% } %>
            <%
                }
            %>
        });
    </script>
</body>
</html>