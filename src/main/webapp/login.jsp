<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Set cache headers first
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // ✅ Fixed: was "user", now matches LoginServlet's "userId"
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("home");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>CyberSphere | Login</title>
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
            background: #0a0c10;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #e5e7eb;
            padding: 20px;
        }

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

        .card {
            background: #0f1115;
            padding: 40px;
            border-radius: 16px;
            width: 420px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
            z-index: 1;
        }

        .cybersphere-header {
            margin-bottom: 32px;
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
            margin-bottom: 24px;
            color: #44634d;
            font-size: 20px;
            font-weight: 500;
            letter-spacing: -0.01em;
            border-left: 3px solid #44634d;
            padding-left: 12px;
        }

        label {
            font-size: 13px;
            font-weight: 500;
            margin-top: 20px;
            margin-bottom: 6px;
            display: block;
            color: #9ca3af;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        input {
            width: 100%;
            padding: 12px 14px;
            margin-top: 4px;
            border-radius: 8px;
            border: 1px solid #2a2f3a;
            outline: none;
            background: #1a1e24;
            color: #ffffff;
            font-size: 15px;
            box-sizing: border-box;
            transition: all 0.2s ease;
        }

        input:focus {
            border-color: #44634d;
            background: #1f242b;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
        }

        input::placeholder {
            color: #4b5563;
            font-size: 14px;
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

        .error {
            background: #2c1515;
            color: #f87171;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            text-align: left;
            border: 1px solid #3f1f1f;
            border-left: 3px solid #ef4444;
        }

        .success {
            background: #1a2e1a;
            color: #86efac;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            text-align: left;
            border: 1px solid #2a4a2a;
            border-left: 3px solid #44634d;
        }

        button {
            margin-top: 28px;
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
        }

        button:hover {
            background: #36523d;
            transform: translateY(-1px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        button:active {
            transform: translateY(0);
        }

        .forgot-password {
            text-align: right;
            margin-top: 10px;
        }

        .forgot-password a {
            color: #6b7280;
            text-decoration: none;
            font-size: 13px;
            transition: color 0.2s ease;
        }

        .forgot-password a:hover {
            color: #44634d;
        }

        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 28px 0 20px;
            color: #2a2f3a;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #2a2f3a;
        }

        .divider span {
            padding: 0 12px;
            font-size: 12px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .link {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #9ca3af;
        }

        .link a {
            color: #44634d;
            text-decoration: none;
            font-weight: 500;
            margin-left: 6px;
            transition: color 0.2s ease;
        }

        .link a:hover {
            color: #5a7e64;
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="card">
    <div class="cybersphere-header">
        <h1>CyberSphere</h1>
    </div>

    <h2>Login</h2>

    <%
        String error = request.getParameter("error");
        if (error != null) {
    %>
        <div class="error"><%= error %></div>
    <% } %>

    <%
        String success = request.getParameter("success");
        if (success != null) {
    %>
        <div class="success"><%= success %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/LoginServlet" method="post" autocomplete="off">

        <label>Username or Email</label>
        <input type="text" name="loginInput" placeholder="Enter your username or email" autocomplete="off" required>

        <label>Password</label>
        <div class="password-box">
            <input type="password" id="password" name="password" placeholder="Enter your password" autocomplete="new-password" required>
            <span class="eye" onclick="togglePassword()" id="eyeIcon">👁️</span>
        </div>

        <div class="forgot-password">
            <a href="forgotPassword.jsp">Forgot password?</a>
        </div>

        <button type="submit">Login →</button>
    </form>

    <div class="divider">
        <span>OR</span>
    </div>

    <div class="link">
        Don't have an account?
        <a href="signup.jsp">Sign up</a>
    </div>
</div>

<script>
    function togglePassword() {
        const passwordInput = document.getElementById('password');
        const eyeIcon = document.getElementById('eyeIcon');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.textContent = '👁️‍🗨️';
        } else {
            passwordInput.type = 'password';
            eyeIcon.textContent = '👁️';
        }
    }

    // ✅ Replace this page in history + block going back to it
    history.replaceState(null, null, window.location.href);
    window.addEventListener('popstate', function() {
        history.pushState(null, null, window.location.href);
    });
</script>

</body>
</html>
