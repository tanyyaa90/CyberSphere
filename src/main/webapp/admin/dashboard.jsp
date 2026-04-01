<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%!
    class ActivityItem {
        String icon;
        String title;
        String description;
        String time;
        String user;
        String color;
        String type;
        
        ActivityItem(String icon, String title, String description, String time, String user, String color, String type) {
            this.icon = icon;
            this.title = title;
            this.description = description;
            this.time = time;
            this.user = user;
            this.color = color;
            this.type = type;
        }
    }
    
    String getTimeAgo(Timestamp time) {
        if (time == null) return "Unknown";
        long now = System.currentTimeMillis();
        long diff = now - time.getTime();
        
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        
        if (days > 0) return days + " day" + (days > 1 ? "s" : "") + " ago";
        if (hours > 0) return hours + " hour" + (hours > 1 ? "s" : "") + " ago";
        if (minutes > 0) return minutes + " minute" + (minutes > 1 ? "s" : "") + " ago";
        return "Just now";
    }
%>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String firstName = (String) session.getAttribute("firstName");
    String profileImage = (String) session.getAttribute("profileImage");
    if (profileImage == null) profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    // Stats variables
    int totalUsers = 0;
    int totalAdmins = 0;
    int totalMessages = 0;
    int unreadMessages = 0;
    int totalQuizAttempts = 0;
    int phishingDetections = 0;
    int passwordChecks = 0;
    int urlScans = 0;
    int sslChecks = 0;
    int totalCertificates = 0;
    int totalContentViews = 0;
    int activeNow = 0;
    int activeToday = 0;
    
    // Activity lists by type
    List<ActivityItem> loginActivities = new ArrayList<>();
    List<ActivityItem> quizActivities = new ArrayList<>();
    List<ActivityItem> certificateActivities = new ArrayList<>();
    List<ActivityItem> phishingActivities = new ArrayList<>();
    List<ActivityItem> passwordActivities = new ArrayList<>();
    List<ActivityItem> urlActivities = new ArrayList<>();
    List<ActivityItem> sslActivities = new ArrayList<>();
    List<ActivityItem> contentActivities = new ArrayList<>();
    List<ActivityItem> messageActivities = new ArrayList<>();
    List<ActivityItem> inactiveUsers = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // ========== STATS ==========
        // Total users
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users");
        if (rs.next()) totalUsers = rs.getInt("count");
        rs.close();
        
        // Total admins
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE role = 'admin'");
        if (rs.next()) totalAdmins = rs.getInt("count");
        rs.close();
        
        // Total messages
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages");
        if (rs.next()) totalMessages = rs.getInt("count");
        rs.close();
        
        // Unread messages
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages WHERE status = 'unread'");
        if (rs.next()) unreadMessages = rs.getInt("count");
        rs.close();
        
        // Quiz attempts
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM quiz_attempts");
            if (rs.next()) totalQuizAttempts = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Phishing detections
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM phishing_log");
            if (rs.next()) phishingDetections = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Password checker logs
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM password_checker_log");
            if (rs.next()) passwordChecks = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // URL scanner logs
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM url_scanner_log");
            if (rs.next()) urlScans = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // SSL checker logs
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM ssl_checker_log");
            if (rs.next()) sslChecks = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Certificates earned
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM certificates");
            if (rs.next()) totalCertificates = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Content views
        try {
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM content_views");
            if (rs.next()) totalContentViews = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Active now (last 15 minutes)
        try {
            rs = stmt.executeQuery("SELECT COUNT(DISTINCT user_id) as count FROM user_sessions WHERE login_time > DATE_SUB(NOW(), INTERVAL 15 MINUTE) AND logout_time IS NULL");
            if (rs.next()) activeNow = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // Active today
        try {
            rs = stmt.executeQuery("SELECT COUNT(DISTINCT user_id) as count FROM user_sessions WHERE DATE(login_time) = CURDATE()");
            if (rs.next()) activeToday = rs.getInt("count");
            rs.close();
        } catch (SQLException e) {}
        
        // ========== LOGIN ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, u.profile_image, s.login_time, s.ip_address " +
                "FROM user_sessions s " +
                "JOIN users u ON s.user_id = u.id " +
                "ORDER BY s.login_time DESC LIMIT 10");
            while (rs.next()) {
                loginActivities.add(new ActivityItem(
                    "fas fa-sign-in-alt",
                    rs.getString("first_name") + " logged in",
                    "IP: " + rs.getString("ip_address"),
                    getTimeAgo(rs.getTimestamp("login_time")),
                    rs.getString("username"),
                    "#44634d",
                    "login"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== QUIZ ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, qa.level, qa.sub_level, qa.percentage, qa.completed_at " +
                "FROM quiz_attempts qa " +
                "JOIN users u ON qa.user_id = u.id " +
                "ORDER BY qa.completed_at DESC LIMIT 10");
            while (rs.next()) {
                String result = rs.getInt("percentage") >= 35 ? "✅ Passed" : "❌ Failed";
                quizActivities.add(new ActivityItem(
                    "fas fa-question-circle",
                    rs.getString("first_name") + " completed " + rs.getString("level") + " Level " + rs.getInt("sub_level"),
                    "Score: " + rs.getInt("percentage") + "% - " + result,
                    getTimeAgo(rs.getTimestamp("completed_at")),
                    rs.getString("username"),
                    rs.getInt("percentage") >= 35 ? "#86efac" : "#f87171",
                    "quiz"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== CERTIFICATE ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, c.level, c.earned_at " +
                "FROM certificates c " +
                "JOIN users u ON c.user_id = u.id " +
                "ORDER BY c.earned_at DESC LIMIT 10");
            while (rs.next()) {
                certificateActivities.add(new ActivityItem(
                    "fas fa-certificate",
                    rs.getString("first_name") + " earned a certificate",
                    "Level: " + rs.getString("level"),
                    getTimeAgo(rs.getTimestamp("earned_at")),
                    rs.getString("username"),
                    "#fbbf24",
                    "certificate"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== PHISHING ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, p.risk_percentage, p.risk_label, p.analyzed_at " +
                "FROM phishing_log p " +
                "JOIN users u ON p.user_id = u.id " +
                "ORDER BY p.analyzed_at DESC LIMIT 10");
            while (rs.next()) {
                String riskColor = "low".equals(rs.getString("risk_label")) ? "#86efac" : 
                                   "medium".equals(rs.getString("risk_label")) ? "#fbbf24" : "#f87171";
                phishingActivities.add(new ActivityItem(
                    "fas fa-shield-alt",
                    rs.getString("first_name") + " analyzed an email",
                    "Risk: " + rs.getInt("risk_percentage") + "% - " + rs.getString("risk_label"),
                    getTimeAgo(rs.getTimestamp("analyzed_at")),
                    rs.getString("username"),
                    riskColor,
                    "phishing"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== PASSWORD CHECKER ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, p.breach_count, p.risk_level, p.checked_at, p.prefix " +
                "FROM password_checker_log p " +
                "JOIN users u ON p.user_id = u.id " +
                "ORDER BY p.checked_at DESC LIMIT 10");
            while (rs.next()) {
                String riskColor = "low".equals(rs.getString("risk_level")) ? "#86efac" : 
                                   "medium".equals(rs.getString("risk_level")) ? "#fbbf24" : "#f87171";
                String riskText = rs.getString("risk_level").toUpperCase();
                int breaches = rs.getInt("breach_count");
                
                passwordActivities.add(new ActivityItem(
                    "fas fa-key",
                    rs.getString("first_name") + " checked a password",
                    breaches + " breach" + (breaches != 1 ? "es" : "") + " found - " + riskText + " risk",
                    getTimeAgo(rs.getTimestamp("checked_at")),
                    rs.getString("username"),
                    riskColor,
                    "password"
                ));
            }
            rs.close();
        } catch (SQLException e) {
            System.out.println("Note: password_checker_log table may not exist yet");
        }
        
        // ========== URL SCANNER ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, ua.risk_score, ua.risk_level, ua.scanned_at, ua.domain, " +
                "ua.is_phishing, ua.is_malware, ua.is_spam " +
                "FROM url_scanner_log ua " +
                "JOIN users u ON ua.user_id = u.id " +
                "ORDER BY ua.scanned_at DESC LIMIT 10");
            while (rs.next()) {
                String riskColor = "safe".equals(rs.getString("risk_level")) ? "#86efac" : 
                                   "medium".equals(rs.getString("risk_level")) ? "#fbbf24" : "#f87171";
                String riskText = rs.getString("risk_level").toUpperCase();
                int score = rs.getInt("risk_score");
                
                // Build threat indicators
                List<String> threats = new ArrayList<>();
                if (rs.getBoolean("is_phishing")) threats.add("phishing");
                if (rs.getBoolean("is_malware")) threats.add("malware");
                if (rs.getBoolean("is_spam")) threats.add("spam");
                
                String threatText = threats.isEmpty() ? "No threats" : String.join(", ", threats);
                
                urlActivities.add(new ActivityItem(
                    "fas fa-search",
                    rs.getString("first_name") + " scanned a URL",
                    rs.getString("domain") + " - Score: " + score + " - " + threatText,
                    getTimeAgo(rs.getTimestamp("scanned_at")),
                    rs.getString("username"),
                    riskColor,
                    "url"
                ));
            }
            rs.close();
        } catch (SQLException e) {
            System.out.println("Note: url_scanner_log table may not exist yet");
        }
        
        // ========== SSL CHECKER ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, s.domain, s.days_left, s.is_expired, " +
                "s.expiring_soon, s.weak_protocol, s.checked_at " +
                "FROM ssl_checker_log s " +
                "JOIN users u ON s.user_id = u.id " +
                "ORDER BY s.checked_at DESC LIMIT 10");
            while (rs.next()) {
                String status = "";
                String riskColor = "#86efac"; // safe green
                
                if (rs.getBoolean("is_expired")) {
                    status = "EXPIRED";
                    riskColor = "#f87171";
                } else if (rs.getBoolean("expiring_soon")) {
                    status = "Expiring soon (" + rs.getInt("days_left") + " days)";
                    riskColor = "#fbbf24";
                } else if (rs.getBoolean("weak_protocol")) {
                    status = "Weak protocol";
                    riskColor = "#fbbf24";
                } else {
                    status = rs.getInt("days_left") + " days left";
                }
                
                sslActivities.add(new ActivityItem(
                    "fas fa-lock",
                    rs.getString("first_name") + " checked SSL certificate",
                    rs.getString("domain") + " - " + status,
                    getTimeAgo(rs.getTimestamp("checked_at")),
                    rs.getString("username"),
                    riskColor,
                    "ssl"
                ));
            }
            rs.close();
        } catch (SQLException e) {
            System.out.println("Note: ssl_checker_log table may not exist yet");
        }
        
        // ========== CONTENT VIEWS ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, c.content_type, c.content_title, c.viewed_at " +
                "FROM content_views c " +
                "JOIN users u ON c.user_id = u.id " +
                "ORDER BY c.viewed_at DESC LIMIT 10");
            while (rs.next()) {
                String icon = "video".equals(rs.getString("content_type")) ? "fas fa-video" :
                             "article".equals(rs.getString("content_type")) ? "fas fa-newspaper" : "fas fa-image";
                String color = "video".equals(rs.getString("content_type")) ? "#f87171" :
                              "article".equals(rs.getString("content_type")) ? "#60a5fa" : "#fbbf24";
                contentActivities.add(new ActivityItem(
                    icon,
                    rs.getString("first_name") + " viewed " + rs.getString("content_type"),
                    "Title: " + rs.getString("content_title"),
                    getTimeAgo(rs.getTimestamp("viewed_at")),
                    rs.getString("username"),
                    color,
                    "content"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== MESSAGE ACTIVITIES ==========
        try {
            rs = stmt.executeQuery(
                "SELECT name, email, subject, submitted_at FROM contact_messages ORDER BY submitted_at DESC LIMIT 10");
            while (rs.next()) {
                messageActivities.add(new ActivityItem(
                    "fas fa-envelope",
                    "New message from " + rs.getString("name"),
                    "Subject: " + rs.getString("subject"),
                    getTimeAgo(rs.getTimestamp("submitted_at")),
                    rs.getString("email"),
                    "#fbbf24",
                    "message"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
        // ========== INACTIVE USERS (no activity in 7 days) ==========
        try {
            rs = stmt.executeQuery(
                "SELECT u.first_name, u.username, u.email, u.last_login, " +
                "COALESCE((SELECT MAX(login_time) FROM user_sessions WHERE user_id = u.id), u.last_login) as last_activity " +
                "FROM users u " +
                "WHERE u.last_login IS NULL OR u.last_login < DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                "ORDER BY last_activity ASC LIMIT 10");
            while (rs.next()) {
                Timestamp lastActive = rs.getTimestamp("last_activity");
                String timeAgo = lastActive == null ? "Never logged in" : getTimeAgo(lastActive);
                inactiveUsers.add(new ActivityItem(
                    "fas fa-user-clock",
                    rs.getString("first_name") + " (" + rs.getString("username") + ")",
                    "Last active: " + timeAgo,
                    timeAgo,
                    rs.getString("email"),
                    "#9ca3af",
                    "inactive"
                ));
            }
            rs.close();
        } catch (SQLException e) {}
        
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
    <title>Admin Dashboard | CyberSphere</title>
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
            color: #e5e7eb;
            padding: 20px;
        }
        
        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: #0f1115;
            padding: 20px 30px;
            border-radius: 16px;
            border: 1px solid #1e1e1e;
        }
        
        .header h1 {
            font-size: 28px;
            color: #ffffff;
        }
        
        .header h1 i {
            color: #44634d;
            margin-right: 10px;
        }
        
        .admin-profile {
            display: flex;
            align-items: center;
            gap: 15px;
            background: #1a1e24;
            padding: 8px 20px;
            border-radius: 40px;
            border: 1px solid #2a2f3a;
        }
        
        .admin-profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 2px solid #44634d;
            object-fit: cover;
        }
        
        .back-link {
            margin-left: 15px;
            color: #9ca3af;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s ease;
        }
        
        .back-link:hover {
            color: #44634d;
        }
        
        /* Stats Cards - Updated for 6 cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 20px;
            transition: all 0.2s ease;
        }
        
        .stat-card:hover {
            border-color: #44634d;
            transform: translateY(-2px);
        }
        
        .stat-icon {
            width: 40px;
            height: 40px;
            background: #1a1e24;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
        }
        
        .stat-icon i {
            font-size: 20px;
            color: #44634d;
        }
        
        .stat-label {
            color: #9ca3af;
            font-size: 12px;
            margin-bottom: 5px;
        }
        
        .stat-number {
            color: #ffffff;
            font-size: 22px;
            font-weight: 600;
        }
        
        .stat-detail {
            color: #6b7280;
            font-size: 11px;
            margin-top: 5px;
        }
        
        /* Activity Tabs */
        .activity-section {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            margin-top: 25px;
        }
        
        .tabs-header {
            display: flex;
            gap: 8px;
            margin-bottom: 25px;
            border-bottom: 1px solid #1e1e1e;
            padding-bottom: 15px;
            flex-wrap: wrap;
        }
        
        .tab-btn {
            padding: 8px 16px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 8px;
            color: #9ca3af;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }
        
        .tab-btn:hover {
            border-color: #44634d;
            color: #ffffff;
        }
        
        .tab-btn.active {
            background: #44634d;
            border-color: #44634d;
            color: white;
        }
        
        .tab-btn i {
            font-size: 12px;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .activity-list {
            list-style: none;
            max-height: 450px;
            overflow-y: auto;
        }
        
        .activity-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px;
            border-bottom: 1px solid #1e1e1e;
            transition: all 0.2s ease;
            border-radius: 8px;
        }
        
        .activity-item:hover {
            background: #1a1e24;
        }
        
        .activity-icon {
            width: 40px;
            height: 40px;
            background: #1a1e24;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .activity-icon i {
            font-size: 18px;
        }
        
        .activity-details {
            flex: 1;
        }
        
        .activity-title {
            color: #ffffff;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 4px;
        }
        
        .activity-description {
            color: #9ca3af;
            font-size: 12px;
            display: flex;
            gap: 15px;
        }
        
        .activity-time {
            color: #6b7280;
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .activity-user {
            display: flex;
            align-items: center;
            gap: 5px;
            color: #44634d;
            font-size: 11px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #6b7280;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }
        
        /* Responsive */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(3, 1fr);
            }
            
            .tabs-header {
                justify-content: center;
            }
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .admin-profile {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <!-- Main Content (No Sidebar) -->
    <div class="main-content" style="margin-left: 0; max-width: 1400px; margin: 0 auto;">
        <div class="header">
            <div style="display: flex; align-items: center; gap: 20px;">
                <h1><i class="fas fa-tachometer-alt"></i> Activity Dashboard</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %>!</span>
            </div>
        </div>
        
        <!-- Stats Cards - Updated with 6 cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-label">Total Users</div>
                <div class="stat-number"><%= totalUsers %></div>
                <div class="stat-detail">
                    <span style="color: #86efac;">● <%= activeNow %> online</span><br>
                    <span style="color: #fbbf24;"><%= activeToday %> today</span>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-question-circle"></i>
                </div>
                <div class="stat-label">Quiz Attempts</div>
                <div class="stat-number"><%= totalQuizAttempts %></div>
                <div class="stat-detail"><%= totalCertificates %> certificates</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-fish"></i>
                </div>
                <div class="stat-label">Phishing Checks</div>
                <div class="stat-number"><%= phishingDetections %></div>
                <div class="stat-detail">Emails analyzed</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-key"></i>
                </div>
                <div class="stat-label">Password Checks</div>
                <div class="stat-number"><%= passwordChecks %></div>
                <div class="stat-detail">Breach checks</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-search"></i>
                </div>
                <div class="stat-label">URL Scans</div>
                <div class="stat-number"><%= urlScans %></div>
                <div class="stat-detail">URLs analyzed</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-lock"></i>
                </div>
                <div class="stat-label">SSL Checks</div>
                <div class="stat-number"><%= sslChecks %></div>
                <div class="stat-detail">Certificates checked</div>
            </div>
        </div>
        
        <!-- Activity Dashboard with Tabs -->
        <div class="activity-section">
            <div class="tabs-header">
                <button class="tab-btn active" onclick="showTab('all')">
                    <i class="fas fa-globe"></i> All Activity
                </button>
                <button class="tab-btn" onclick="showTab('logins')">
                    <i class="fas fa-sign-in-alt"></i> Logins (<%= loginActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('quizzes')">
                    <i class="fas fa-question-circle"></i> Quizzes (<%= quizActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('certificates')">
                    <i class="fas fa-certificate"></i> Certificates (<%= certificateActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('phishing')">
                    <i class="fas fa-fish"></i> Phishing Log(<%= phishingActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('password')">
                    <i class="fas fa-key"></i> Password Log(<%= passwordActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('url')">
                    <i class="fas fa-search"></i> URL Log(<%= urlActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('ssl')">
                    <i class="fas fa-lock"></i> SSL Log(<%= sslActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('content')">
                    <i class="fas fa-eye"></i> Content (<%= contentActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('messages')">
                    <i class="fas fa-envelope"></i> Messages (<%= messageActivities.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('inactive')">
                    <i class="fas fa-user-clock"></i> Inactive (<%= inactiveUsers.size() %>)
                </button>
            </div>
            
            <!-- All Activity Tab -->
            <div id="tab-all" class="tab-content active">
                <div class="activity-list">
                    <% 
                        List<ActivityItem> allActivities = new ArrayList<>();
                        allActivities.addAll(loginActivities);
                        allActivities.addAll(quizActivities);
                        allActivities.addAll(certificateActivities);
                        allActivities.addAll(phishingActivities);
                        allActivities.addAll(passwordActivities);
                        allActivities.addAll(urlActivities);
                        allActivities.addAll(sslActivities);
                        allActivities.addAll(contentActivities);
                        allActivities.addAll(messageActivities);
                        
                        if (allActivities.isEmpty()) {
                    %>
                        <div class="empty-state">
                            <i class="fas fa-history"></i>
                            <h3>No Activity Yet</h3>
                            <p>Waiting for users to interact with the platform</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : allActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Login Activity Tab -->
            <div id="tab-logins" class="tab-content">
                <div class="activity-list">
                    <% if (loginActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-sign-in-alt"></i>
                            <h3>No Login Activity</h3>
                            <p>No users have logged in yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : loginActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Quiz Activity Tab -->
            <div id="tab-quizzes" class="tab-content">
                <div class="activity-list">
                    <% if (quizActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-question-circle"></i>
                            <h3>No Quiz Activity</h3>
                            <p>No quizzes have been attempted yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : quizActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Certificate Activity Tab -->
            <div id="tab-certificates" class="tab-content">
                <div class="activity-list">
                    <% if (certificateActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-certificate"></i>
                            <h3>No Certificates Earned</h3>
                            <p>No users have earned certificates yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : certificateActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Phishing Activity Tab -->
            <div id="tab-phishing" class="tab-content">
                <div class="activity-list">
                    <% if (phishingActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-fish"></i>
                            <h3>No Phishing Detections</h3>
                            <p>No emails have been analyzed yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : phishingActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Password Checker Activity Tab -->
            <div id="tab-password" class="tab-content">
                <div class="activity-list">
                    <% if (passwordActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-key"></i>
                            <h3>No Password Checks</h3>
                            <p>No passwords have been checked yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : passwordActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- URL Scanner Activity Tab -->
            <div id="tab-url" class="tab-content">
                <div class="activity-list">
                    <% if (urlActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-search"></i>
                            <h3>No URL Scans</h3>
                            <p>No URLs have been scanned yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : urlActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- SSL Checker Activity Tab -->
            <div id="tab-ssl" class="tab-content">
                <div class="activity-list">
                    <% if (sslActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-lock"></i>
                            <h3>No SSL Checks</h3>
                            <p>No SSL certificates have been checked yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : sslActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Content Views Tab -->
            <div id="tab-content" class="tab-content">
                <div class="activity-list">
                    <% if (contentActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-eye"></i>
                            <h3>No Content Views</h3>
                            <p>No videos, articles or images have been viewed yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : contentActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-user"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Messages Tab -->
            <div id="tab-messages" class="tab-content">
                <div class="activity-list">
                    <% if (messageActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-envelope"></i>
                            <h3>No Messages</h3>
                            <p>No contact form submissions yet</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : messageActivities) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-envelope"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
            <!-- Inactive Users Tab -->
            <div id="tab-inactive" class="tab-content">
                <div class="activity-list">
                    <% if (inactiveUsers.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-user-check"></i>
                            <h3>All Users Active</h3>
                            <p>All users have been active within the last 7 days</p>
                        </div>
                    <% } else { %>
                        <% for (ActivityItem item : inactiveUsers) { %>
                        <div class="activity-item">
                            <div class="activity-icon" style="color: <%= item.color %>;">
                                <i class="<%= item.icon %>"></i>
                            </div>
                            <div class="activity-details">
                                <div class="activity-title"><%= item.title %></div>
                                <div class="activity-description">
                                    <span><%= item.description %></span>
                                    <span class="activity-user">
                                        <i class="fas fa-envelope"></i> <%= item.user %>
                                    </span>
                                </div>
                            </div>
                            <div class="activity-time">
                                <i class="far fa-clock"></i> <%= item.time %>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function showTab(tabName) {
            // Hide all tabs
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Remove active class from all buttons
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Show selected tab
            document.getElementById('tab-' + tabName).classList.add('active');
            
            // Add active class to clicked button
            event.target.classList.add('active');
        }
    </script>
</body>
</html>