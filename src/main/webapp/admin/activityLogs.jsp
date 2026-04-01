<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is admin (main or sub-admin)
    String role = (String) session.getAttribute("role");
    Integer currentUserId = (Integer) session.getAttribute("userId");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    Boolean canViewLogs = (Boolean) session.getAttribute("can_view_logs");
    
    if (currentUserId == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if admin has permission to view logs (main admin or sub-admin with view logs permission)
    if (!isMainAdmin && (canViewLogs == null || !canViewLogs)) {
        response.sendRedirect("admin_home.jsp?error=You don't have permission to view logs");
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
    
    // Lists for different activity types
    List<Map<String, Object>> loginActivities = new ArrayList<>();
    List<Map<String, Object>> quizActivities = new ArrayList<>();
    List<Map<String, Object>> certificateActivities = new ArrayList<>();
    List<Map<String, Object>> phishingActivities = new ArrayList<>();
    List<Map<String, Object>> passwordActivities = new ArrayList<>();
    List<Map<String, Object>> urlActivities = new ArrayList<>();
    List<Map<String, Object>> sslActivities = new ArrayList<>();
    List<Map<String, Object>> contentActivities = new ArrayList<>();
    List<Map<String, Object>> messageActivities = new ArrayList<>();
    
    // Stats variables
    int totalLogins = 0;
    int totalQuizzes = 0;
    int totalCertificates = 0;
    int totalPhishing = 0;
    int totalPassword = 0;
    int totalUrl = 0;
    int totalSsl = 0;
    int totalContent = 0;
    int totalMessages = 0;
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // ========== LOGIN ACTIVITIES ==========
        String loginSql = "SELECT u.id, u.first_name, u.username, u.email, s.login_time, s.ip_address " +
                          "FROM user_sessions s " +
                          "JOIN users u ON s.user_id = u.id " +
                          "ORDER BY s.login_time DESC LIMIT 50";
        rs = stmt.executeQuery(loginSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("userEmail", rs.getString("email"));
            activity.put("ipAddress", rs.getString("ip_address"));
            activity.put("timestamp", rs.getTimestamp("login_time"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("login_time")));
            loginActivities.add(activity);
        }
        totalLogins = loginActivities.size();
        rs.close();
        
        // ========== QUIZ ACTIVITIES ==========
        String quizSql = "SELECT u.first_name, u.username, qa.level, qa.sub_level, qa.percentage, qa.completed_at " +
                         "FROM quiz_attempts qa " +
                         "JOIN users u ON qa.user_id = u.id " +
                         "ORDER BY qa.completed_at DESC LIMIT 50";
        rs = stmt.executeQuery(quizSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("level", rs.getString("level") + " Level " + rs.getInt("sub_level"));
            activity.put("score", rs.getInt("percentage") + "%");
            activity.put("status", rs.getInt("percentage") >= 35 ? "Passed" : "Failed");
            activity.put("timestamp", rs.getTimestamp("completed_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("completed_at")));
            quizActivities.add(activity);
        }
        totalQuizzes = quizActivities.size();
        rs.close();
        
        // ========== CERTIFICATE ACTIVITIES ==========
        String certSql = "SELECT u.first_name, u.username, c.level, c.earned_at " +
                         "FROM certificates c " +
                         "JOIN users u ON c.user_id = u.id " +
                         "ORDER BY c.earned_at DESC LIMIT 50";
        rs = stmt.executeQuery(certSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("level", rs.getString("level"));
            activity.put("timestamp", rs.getTimestamp("earned_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("earned_at")));
            certificateActivities.add(activity);
        }
        totalCertificates = certificateActivities.size();
        rs.close();
        
        // ========== PHISHING DETECTOR ACTIVITIES ==========
        String phishingSql = "SELECT u.first_name, u.username, p.risk_percentage, p.risk_label, p.analyzed_at " +
                             "FROM phishing_log p " +
                             "JOIN users u ON p.user_id = u.id " +
                             "ORDER BY p.analyzed_at DESC LIMIT 50";
        rs = stmt.executeQuery(phishingSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("riskScore", rs.getInt("risk_percentage") + "%");
            activity.put("riskLevel", rs.getString("risk_label"));
            activity.put("timestamp", rs.getTimestamp("analyzed_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("analyzed_at")));
            phishingActivities.add(activity);
        }
        totalPhishing = phishingActivities.size();
        rs.close();
        
        // ========== PASSWORD CHECKER ACTIVITIES ==========
        String passwordSql = "SELECT u.first_name, u.username, p.breach_count, p.risk_level, p.checked_at " +
                             "FROM password_checker_log p " +
                             "JOIN users u ON p.user_id = u.id " +
                             "ORDER BY p.checked_at DESC LIMIT 50";
        rs = stmt.executeQuery(passwordSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("breachCount", rs.getInt("breach_count"));
            activity.put("riskLevel", rs.getString("risk_level"));
            activity.put("timestamp", rs.getTimestamp("checked_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("checked_at")));
            passwordActivities.add(activity);
        }
        totalPassword = passwordActivities.size();
        rs.close();
        
        // ========== URL SCANNER ACTIVITIES ==========
        String urlSql = "SELECT u.first_name, u.username, ua.domain, ua.risk_score, ua.risk_level, ua.scanned_at " +
                        "FROM url_scanner_log ua " +
                        "JOIN users u ON ua.user_id = u.id " +
                        "ORDER BY ua.scanned_at DESC LIMIT 50";
        rs = stmt.executeQuery(urlSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("domain", rs.getString("domain") != null ? rs.getString("domain") : "Unknown");
            activity.put("riskScore", rs.getInt("risk_score"));
            activity.put("riskLevel", rs.getString("risk_level"));
            activity.put("timestamp", rs.getTimestamp("scanned_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("scanned_at")));
            urlActivities.add(activity);
        }
        totalUrl = urlActivities.size();
        rs.close();
        
        // ========== SSL CHECKER ACTIVITIES ==========
        String sslSql = "SELECT u.first_name, u.username, s.domain, s.days_left, s.is_expired, s.expiring_soon, s.checked_at " +
                        "FROM ssl_checker_log s " +
                        "JOIN users u ON s.user_id = u.id " +
                        "ORDER BY s.checked_at DESC LIMIT 50";
        rs = stmt.executeQuery(sslSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("domain", rs.getString("domain") != null ? rs.getString("domain") : "Unknown");
            String status = "";
            if (rs.getBoolean("is_expired")) {
                status = "Expired";
            } else if (rs.getBoolean("expiring_soon")) {
                status = "Expiring soon (" + rs.getInt("days_left") + " days)";
            } else {
                status = rs.getInt("days_left") + " days left";
            }
            activity.put("status", status);
            activity.put("timestamp", rs.getTimestamp("checked_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("checked_at")));
            sslActivities.add(activity);
        }
        totalSsl = sslActivities.size();
        rs.close();
        
        // ========== CONTENT VIEW ACTIVITIES ==========
        String contentSql = "SELECT u.first_name, u.username, c.content_type, c.content_title, c.viewed_at " +
                            "FROM content_views c " +
                            "JOIN users u ON c.user_id = u.id " +
                            "ORDER BY c.viewed_at DESC LIMIT 50";
        rs = stmt.executeQuery(contentSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("first_name") + " " + rs.getString("username"));
            activity.put("contentType", rs.getString("content_type"));
            activity.put("contentTitle", rs.getString("content_title"));
            activity.put("timestamp", rs.getTimestamp("viewed_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("viewed_at")));
            contentActivities.add(activity);
        }
        totalContent = contentActivities.size();
        rs.close();
        
        // ========== CONTACT MESSAGE ACTIVITIES ==========
        String messageSql = "SELECT name, email, subject, submitted_at, status FROM contact_messages ORDER BY submitted_at DESC LIMIT 50";
        rs = stmt.executeQuery(messageSql);
        while (rs.next()) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("userName", rs.getString("name"));
            activity.put("userEmail", rs.getString("email"));
            activity.put("subject", rs.getString("subject"));
            activity.put("status", rs.getString("status"));
            activity.put("timestamp", rs.getTimestamp("submitted_at"));
            activity.put("formattedTime", sdf.format(rs.getTimestamp("submitted_at")));
            messageActivities.add(activity);
        }
        totalMessages = messageActivities.size();
        rs.close();
        
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
    <title>Activity Logs | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }
        
        body {
            background: #0a0c10;
            color: #e5e7eb;
            padding: 20px;
        }
        
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
        
        .header-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .back-link {
            color: #9ca3af;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .back-link:hover {
            color: #44634d;
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
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: 2px solid #44634d;
            object-fit: cover;
        }
        
        .main-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-card i {
            font-size: 28px;
            color: #44634d;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 28px;
            font-weight: 600;
            color: #ffffff;
        }
        
        .stat-label {
            color: #9ca3af;
            font-size: 12px;
            margin-top: 5px;
        }
        
        .tabs-header {
            display: flex;
            gap: 8px;
            margin-bottom: 25px;
            background: #0f1115;
            padding: 15px;
            border-radius: 16px;
            border: 1px solid #1e1e1e;
            flex-wrap: wrap;
        }
        
        .tab-btn {
            padding: 10px 20px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 8px;
            color: #9ca3af;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
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
        
        .tab-content {
            display: none;
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .activity-table {
            width: 100%;
            border-collapse: collapse;
            overflow-x: auto;
            display: block;
        }
        
        .activity-table thead {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .activity-table tbody {
            display: block;
            max-height: 500px;
            overflow-y: auto;
            width: 100%;
        }
        
        .activity-table tr {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .activity-table th {
            text-align: left;
            padding: 12px;
            color: #9ca3af;
            font-weight: 500;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .activity-table td {
            padding: 12px;
            color: #e5e7eb;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .badge-passed {
            background: #1a2e1a;
            color: #86efac;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .badge-failed {
            background: #2c1515;
            color: #f87171;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .risk-low {
            background: #1a2e1a;
            color: #86efac;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .risk-medium {
            background: #332a1a;
            color: #fbbf24;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .risk-high {
            background: #2c1515;
            color: #f87171;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px;
            color: #6b7280;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-chart-line"></i> Activity Logs</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <i class="fas fa-sign-in-alt"></i>
                <div class="stat-number"><%= totalLogins %></div>
                <div class="stat-label">Logins</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-question-circle"></i>
                <div class="stat-number"><%= totalQuizzes %></div>
                <div class="stat-label">Quiz Attempts</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-certificate"></i>
                <div class="stat-number"><%= totalCertificates %></div>
                <div class="stat-label">Certificates</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-fish"></i>
                <div class="stat-number"><%= totalPhishing %></div>
                <div class="stat-label">Phishing Checks</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-key"></i>
                <div class="stat-number"><%= totalPassword %></div>
                <div class="stat-label">Password Checks</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-search"></i>
                <div class="stat-number"><%= totalUrl %></div>
                <div class="stat-label">URL Scans</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-lock"></i>
                <div class="stat-number"><%= totalSsl %></div>
                <div class="stat-label">SSL Checks</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-eye"></i>
                <div class="stat-number"><%= totalContent %></div>
                <div class="stat-label">Content Views</div>
            </div>
        </div>
        
        <div class="tabs-header">
            <button class="tab-btn active" onclick="showTab('logins')">
                <i class="fas fa-sign-in-alt"></i> Logins (<%= totalLogins %>)
            </button>
            <button class="tab-btn" onclick="showTab('quizzes')">
                <i class="fas fa-question-circle"></i> Quizzes (<%= totalQuizzes %>)
            </button>
            <button class="tab-btn" onclick="showTab('certificates')">
                <i class="fas fa-certificate"></i> Certificates (<%= totalCertificates %>)
            </button>
            <button class="tab-btn" onclick="showTab('phishing')">
                <i class="fas fa-fish"></i> Phishing (<%= totalPhishing %>)
            </button>
            <button class="tab-btn" onclick="showTab('password')">
                <i class="fas fa-key"></i> Password (<%= totalPassword %>)
            </button>
            <button class="tab-btn" onclick="showTab('url')">
                <i class="fas fa-search"></i> URL (<%= totalUrl %>)
            </button>
            <button class="tab-btn" onclick="showTab('ssl')">
                <i class="fas fa-lock"></i> SSL (<%= totalSsl %>)
            </button>
            <button class="tab-btn" onclick="showTab('content')">
                <i class="fas fa-eye"></i> Content (<%= totalContent %>)
            </button>
            <button class="tab-btn" onclick="showTab('messages')">
                <i class="fas fa-envelope"></i> Messages (<%= totalMessages %>)
            </button>
        </div>
        
        <!-- Login Activity Tab -->
        <div id="tab-logins" class="tab-content active">
            <% if (loginActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-history"></i>
                    <h3>No Login Activity</h3>
                    <p>No users have logged in yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Email</th><th>IP Address</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : loginActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("userEmail") %></td>
                            <td><%= activity.get("ipAddress") %></td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Quiz Activity Tab -->
        <div id="tab-quizzes" class="tab-content">
            <% if (quizActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-question-circle"></i>
                    <h3>No Quiz Activity</h3>
                    <p>No quizzes have been attempted yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Level</th><th>Score</th><th>Result</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : quizActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("level") %></td>
                            <td><%= activity.get("score") %></td>
                            <td>
                                <% if ("Passed".equals(activity.get("status"))) { %>
                                    <span class="badge-passed">Passed</span>
                                <% } else { %>
                                    <span class="badge-failed">Failed</span>
                                <% } %>
                            </td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Certificate Activity Tab -->
        <div id="tab-certificates" class="tab-content">
            <% if (certificateActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-certificate"></i>
                    <h3>No Certificates</h3>
                    <p>No certificates have been earned yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Level</th><th>Earned Date</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : certificateActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("level") %></td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Phishing Activity Tab -->
        <div id="tab-phishing" class="tab-content">
            <% if (phishingActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-fish"></i>
                    <h3>No Phishing Checks</h3>
                    <p>No emails have been analyzed yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Risk Score</th><th>Risk Level</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : phishingActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("riskScore") %></td>
                            <td>
                                <% String risk = (String) activity.get("riskLevel"); %>
                                <span class="<%= risk.equals("low") ? "risk-low" : risk.equals("medium") ? "risk-medium" : "risk-high" %>">
                                    <%= risk.toUpperCase() %>
                                </span>
                            </td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Password Checker Tab -->
        <div id="tab-password" class="tab-content">
            <% if (passwordActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-key"></i>
                    <h3>No Password Checks</h3>
                    <p>No passwords have been checked yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Breach Count</th><th>Risk Level</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : passwordActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("breachCount") %></td>
                            <td>
                                <% String risk = (String) activity.get("riskLevel"); %>
                                <span class="<%= risk.equals("low") ? "risk-low" : risk.equals("medium") ? "risk-medium" : "risk-high" %>">
                                    <%= risk.toUpperCase() %>
                                </span>
                            </td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- URL Scanner Tab -->
        <div id="tab-url" class="tab-content">
            <% if (urlActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-search"></i>
                    <h3>No URL Scans</h3>
                    <p>No URLs have been scanned yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Domain</th><th>Risk Score</th><th>Risk Level</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : urlActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("domain") %></td>
                            <td><%= activity.get("riskScore") %>/100</td>
                            <td>
                                <% String risk = (String) activity.get("riskLevel"); %>
                                <span class="<%= risk.equals("safe") ? "risk-low" : risk.equals("medium") ? "risk-medium" : "risk-high" %>">
                                    <%= risk.toUpperCase() %>
                                </span>
                            </td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- SSL Checker Tab -->
        <div id="tab-ssl" class="tab-content">
            <% if (sslActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-lock"></i>
                    <h3>No SSL Checks</h3>
                    <p>No SSL certificates have been checked yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Domain</th><th>Status</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : sslActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("domain") %></td>
                            <td><%= activity.get("status") %></td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Content Views Tab -->
        <div id="tab-content" class="tab-content">
            <% if (contentActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-eye"></i>
                    <h3>No Content Views</h3>
                    <p>No content has been viewed yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>User</th><th>Type</th><th>Title</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : contentActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("contentType") %></td>
                            <td><%= activity.get("contentTitle") %></td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Messages Tab -->
        <div id="tab-messages" class="tab-content">
            <% if (messageActivities.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-envelope"></i>
                    <h3>No Messages</h3>
                    <p>No contact messages have been submitted yet</p>
                </div>
            <% } else { %>
                <table class="activity-table">
                    <thead>
                        <tr><th>Name</th><th>Email</th><th>Subject</th><th>Status</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> activity : messageActivities) { %>
                        <tr>
                            <td><%= activity.get("userName") %></td>
                            <td><%= activity.get("userEmail") %></td>
                            <td><%= activity.get("subject") %></td>
                            <td>
                                <span class="<%= "read".equals(activity.get("status")) ? "risk-low" : "risk-medium" %>">
                                    <%= activity.get("status") %>
                                </span>
                            </td>
                            <td><%= activity.get("formattedTime") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
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