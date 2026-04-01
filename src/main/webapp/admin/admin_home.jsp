<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="header_a.jsp" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(userRole)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String displayName = firstName;
    if (displayName == null) displayName = "Admin";

    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    int totalUsers = 0, totalMessages = 0, unreadMessages = 0,
        totalSublevels = 0, totalContent = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users");
        if (rs.next()) totalUsers = rs.getInt("count"); rs.close();
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages");
        if (rs.next()) totalMessages = rs.getInt("count"); rs.close();
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages WHERE status = 'unread'");
        if (rs.next()) unreadMessages = rs.getInt("count"); rs.close();
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT CONCAT(level, '_', sub_level)) as count FROM questions_new");
        if (rs.next()) totalSublevels = rs.getInt("count"); rs.close();
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM learning_content");
        if (rs.next()) totalContent = rs.getInt("count"); rs.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Home | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* ── all your existing styles unchanged ── */
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif; }
        body { background:#0a0c10; min-height:100vh; position:relative; }
        body::before { content:''; position:fixed; top:0; left:0; width:100%; height:100%; background-image:url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.05"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>'); background-repeat:repeat; background-size:60px 60px; pointer-events:none; z-index:0; }
        .container { max-width:1200px; margin:40px auto; padding:20px; position:relative; z-index:1; }
        .hero-section { text-align:center; color:#fff; padding:20px; }
        .hero-section h1 { font-size:42px; margin-bottom:15px; font-weight:600; letter-spacing:-0.02em; }
        .hero-section h1 span { color:#44634d; }
        .hero-section p { font-size:18px; color:#9ca3af; margin-bottom:10px; }
        .admin-badge { display:inline-block; background:#1a2a1a; color:#86efac; padding:8px 20px; border-radius:30px; font-size:14px; font-weight:600; border:1px solid #2a4a2a; margin-top:10px; }
        .admin-badge i { margin-right:8px; color:#44634d; }
        .features-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:30px; margin-top:40px; }
        .feature-card { background:#0f1115; padding:35px 30px; border-radius:16px; text-align:center; transition:transform 0.2s ease,border-color 0.2s ease; border:1px solid #1e1e1e; box-shadow:0 10px 30px rgba(0,0,0,0.3); text-decoration:none; color:inherit; display:block; position:relative; overflow:hidden; }
        .feature-card:hover { transform:translateY(-5px); border-color:#44634d; box-shadow:0 20px 40px rgba(68,99,77,0.2); }
        .feature-card i { font-size:48px; color:#44634d; margin-bottom:20px; }
        .feature-card h3 { color:#fff; margin-bottom:12px; font-size:20px; font-weight:600; }
        .feature-card p { color:#9ca3af; margin-bottom:20px; line-height:1.6; font-size:14px; }
        .feature-badge { position:absolute; top:10px; right:10px; background:#1a2a1a; color:#86efac; padding:4px 8px; border-radius:20px; font-size:12px; font-weight:600; border:1px solid #2a4a2a; }
        .stat-number { font-size:24px; font-weight:700; color:#fff; margin-top:10px; }
        .stat-number span { color:#86efac; font-size:14px; margin-left:5px; }
        @media(max-width:1024px){.features-grid{grid-template-columns:repeat(2,1fr);}}
        @media(max-width:768px){.hero-section h1{font-size:32px;}.features-grid{grid-template-columns:1fr;}}

        /* ── Logout modal ── */
        #logoutModal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.65);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        #logoutModal.show { display: flex; }
        .modal-box {
            background: #0f1115;
            border: 1px solid #2a4a2a;
            border-radius: 16px;
            padding: 40px 36px;
            max-width: 400px;
            width: 90%;
            text-align: center;
            animation: popIn 0.18s ease;
        }
        @keyframes popIn {
            from { transform: scale(0.92); opacity: 0; }
            to   { transform: scale(1);    opacity: 1; }
        }
        .modal-icon {
            width: 56px; height: 56px;
            border-radius: 50%;
            background: #1a1a0a;
            border: 1px solid #44634d;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
            font-size: 22px;
            color: #86efac;
        }
        .modal-box h2 { color: #fff; font-size: 20px; font-weight: 600; margin-bottom: 10px; }
        .modal-box p  { color: #9ca3af; font-size: 14px; line-height: 1.6; margin-bottom: 28px; }
        .modal-actions { display: flex; gap: 12px; justify-content: center; }
        .btn-logout {
            flex: 1; padding: 10px 0;
            background: #2c1515; color: #f87171;
            border: 1px solid #4a2020;
            border-radius: 8px; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: background 0.15s;
        }
        .btn-logout:hover { background: #3d1a1a; }
        .btn-stay {
            flex: 1; padding: 10px 0;
            background: #1a2a1a; color: #86efac;
            border: 1px solid #2a4a2a;
            border-radius: 8px; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: background 0.15s;
        }
        .btn-stay:hover { background: #223322; }
    </style>
</head>
<body>

<!-- ── Logout confirmation modal ── -->
<div id="logoutModal">
    <div class="modal-box">
        <div class="modal-icon"><i class="fas fa-sign-out-alt"></i></div>
        <h2>Leaving the dashboard?</h2>
        <p>Do you want to log out and return to the welcome page?</p>
        <div class="modal-actions">
            <button class="btn-logout" onclick="confirmLogout()">Yes, log out</button>
            <button class="btn-stay"   onclick="stayOnPage()">No, stay here</button>
        </div>
    </div>
</div>

<div class="container">
    <div class="hero-section">
        <h1>Admin <span>Dashboard</span></h1>
        <p>Manage and monitor your cybersecurity platform</p>
        <div class="admin-badge">
            <i class="fas fa-shield-halved"></i> Welcome, <%= displayName %>! You have admin privileges
        </div>
    </div>

    <div class="features-grid">
        <a href="dashboard.jsp" class="feature-card">
            <i class="fas fa-tachometer-alt"></i>
            <h3>Dashboard</h3>
            <p>View system statistics, recent activity, and analytics</p>
            <div class="stat-number"><%= totalUsers + totalMessages + totalContent %> <span>total activities</span></div>
        </a>
        <a href="users.jsp" class="feature-card">
            <i class="fas fa-users"></i>
            <h3>Users</h3>
            <p>Manage user accounts, roles, and permissions</p>
            <div class="stat-number"><%= totalUsers %> <span>registered users</span></div>
            <% if (totalUsers > 0) { %><div class="feature-badge"><%= totalUsers %></div><% } %>
        </a>
        <a href="messages.jsp" class="feature-card">
            <i class="fas fa-envelope"></i>
            <h3>Contact Messages</h3>
            <p>View and respond to user inquiries</p>
            <div class="stat-number">
                <%= totalMessages %> <span>total</span>
                <% if (unreadMessages > 0) { %><span style="color:#f87171;">(<%= unreadMessages %> unread)</span><% } %>
            </div>
            <% if (unreadMessages > 0) { %><div class="feature-badge" style="background:#2c1515;color:#f87171;"><%= unreadMessages %> new</div><% } %>
        </a>
        <a href="quizzes.jsp" class="feature-card">
            <i class="fas fa-question-circle"></i>
            <h3>Quizzes</h3>
            <p>Manage quiz questions, levels, and content</p>
            <div class="stat-number"><%= totalSublevels %> <span>total quizzes</span></div>
        </a>
        <a href="content.jsp" class="feature-card">
            <i class="fas fa-newspaper"></i>
            <h3>Learning Content</h3>
            <p>Manage videos, articles, and images</p>
            <div class="stat-number"><%= totalContent %> <span>resources</span></div>
        </a>
        <a href="settings.jsp" class="feature-card">
            <i class="fas fa-cog"></i>
            <h3>Settings</h3>
            <p>Configure system preferences and email settings</p>
            <div class="stat-number"><i class="fas fa-sliders-h" style="font-size:16px;"></i> <span>system config</span></div>
        </a>
    </div>
</div>

<script>
    // Push a dummy state so we can intercept the first back press
    history.pushState({ adminHome: true }, '', window.location.href);

    window.addEventListener('popstate', function(e) {
        // Back button was pressed — show the modal instead of navigating
        showLogoutModal();
    });

    function showLogoutModal() {
        document.getElementById('logoutModal').classList.add('show');
    }

    function stayOnPage() {
        // Hide modal and re-arm the history trap
        document.getElementById('logoutModal').classList.remove('show');
        history.pushState({ adminHome: true }, '', window.location.href);
    }

    // Optional: also catch Escape key to dismiss (stay on page)
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') stayOnPage();
    });
</script>

</body>
</html>