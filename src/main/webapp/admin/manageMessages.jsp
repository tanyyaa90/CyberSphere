<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    Integer currentUserId = (Integer) session.getAttribute("userId");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    Boolean canManageMessages = (Boolean) session.getAttribute("can_manage_messages");
    
    if (currentUserId == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if admin has permission to manage messages
    if (!isMainAdmin && (canManageMessages == null || !canManageMessages)) {
        response.sendRedirect("admin_home.jsp?error=You don't have permission to manage messages");
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
    PreparedStatement ps = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    // Handle actions
    String action = request.getParameter("action");
    String messageId = request.getParameter("id");
    String successMsg = "";
    String errorMsg = "";
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // Handle marking as read
        if ("read".equals(action) && messageId != null) {
            String updateSql = "UPDATE contact_messages SET status = 'read' WHERE id = ?";
            ps = conn.prepareStatement(updateSql);
            ps.setInt(1, Integer.parseInt(messageId));
            int updated = ps.executeUpdate();
            if (updated > 0) {
                successMsg = "Message marked as read";
            }
            ps.close();
        }
        
        // Handle delete
        if ("delete".equals(action) && messageId != null) {
            String deleteSql = "DELETE FROM contact_messages WHERE id = ?";
            ps = conn.prepareStatement(deleteSql);
            ps.setInt(1, Integer.parseInt(messageId));
            int deleted = ps.executeUpdate();
            if (deleted > 0) {
                successMsg = "Message deleted successfully";
            }
            ps.close();
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Database error: " + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Fetch messages
    List<Map<String, Object>> messages = new ArrayList<>();
    int unreadCount = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // Only fetch existing columns
        String sql = "SELECT id, name, email, phone, subject, message, status, submitted_at " +
                     "FROM contact_messages ORDER BY submitted_at DESC";
        rs = stmt.executeQuery(sql);
        
        while (rs.next()) {
            Map<String, Object> msg = new HashMap<>();
            msg.put("id", rs.getInt("id"));
            msg.put("name", rs.getString("name"));
            msg.put("email", rs.getString("email"));
            msg.put("phone", rs.getString("phone"));
            msg.put("subject", rs.getString("subject"));
            msg.put("message", rs.getString("message"));
            msg.put("status", rs.getString("status"));
            msg.put("submitted_at", rs.getTimestamp("submitted_at"));
            msg.put("formatted_date", sdf.format(rs.getTimestamp("submitted_at")));
            
            if ("unread".equals(rs.getString("status"))) {
                unreadCount++;
            }
            messages.add(msg);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Error loading messages: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Messages | CyberSphere</title>
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
            max-width: 1000px;
            margin: 0 auto;
        }
        
        .stats-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-around;
            align-items: center;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: 600;
            color: #ffffff;
        }
        
        .stat-label {
            color: #9ca3af;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .stat-number.unread {
            color: #fbbf24;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
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
        
        .messages-container {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
        }
        
        .messages-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #1e1e1e;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .messages-header h2 {
            font-size: 20px;
            color: #ffffff;
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            padding: 6px 12px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 6px;
            color: #9ca3af;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.2s ease;
        }
        
        .filter-btn:hover {
            border-color: #44634d;
            color: #ffffff;
        }
        
        .filter-btn.active {
            background: #44634d;
            border-color: #44634d;
            color: white;
        }
        
        .message-list {
            list-style: none;
        }
        
        .message-item {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            margin-bottom: 15px;
            overflow: hidden;
            transition: all 0.2s ease;
        }
        
        .message-item:hover {
            border-color: #44634d;
        }
        
        .message-item.unread {
            border-left: 3px solid #fbbf24;
        }
        
        .message-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background: #0f1115;
            cursor: pointer;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .message-info {
            flex: 1;
        }
        
        .message-sender {
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 5px;
        }
        
        .message-subject {
            color: #9ca3af;
            font-size: 13px;
        }
        
        .message-meta {
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .message-date {
            color: #6b7280;
            font-size: 12px;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 500;
        }
        
        .status-badge.unread {
            background: #332a1a;
            color: #fbbf24;
        }
        
        .status-badge.read {
            background: #1a2e1a;
            color: #86efac;
        }
        
        .message-body {
            padding: 0 20px 20px 20px;
            display: none;
            border-top: 1px solid #2a2f3a;
        }
        
        .message-body.show {
            display: block;
        }
        
        .message-content {
            background: #0f1115;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            line-height: 1.6;
            color: #e5e7eb;
            white-space: pre-wrap;
        }
        
        .contact-details {
            background: #0f1115;
            padding: 10px 15px;
            border-radius: 8px;
            margin-top: 10px;
            font-size: 13px;
            color: #9ca3af;
        }
        
        .contact-details i {
            width: 20px;
            color: #44634d;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-primary {
            background: #44634d;
            color: white;
        }
        
        .btn-primary:hover {
            background: #36523d;
        }
        
        .btn-secondary {
            background: #1a1e24;
            color: #9ca3af;
            border: 1px solid #2a2f3a;
        }
        
        .btn-secondary:hover {
            background: #1f242b;
            color: #ffffff;
        }
        
        .btn-danger {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }
        
        .btn-danger:hover {
            background: #3f1f1f;
            color: #ffa0a0;
        }
        
        .btn-sm {
            padding: 6px 12px;
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
            
            .stats-card {
                flex-direction: column;
                gap: 15px;
            }
            
            .message-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-envelope"></i> Manage Messages</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <div class="stats-card">
            <div class="stat-item">
                <div class="stat-number"><%= messages.size() %></div>
                <div class="stat-label">Total Messages</div>
            </div>
            <div class="stat-item">
                <div class="stat-number unread"><%= unreadCount %></div>
                <div class="stat-label">Unread</div>
            </div>
            <div class="stat-item">
                <div class="stat-number"><%= messages.size() - unreadCount %></div>
                <div class="stat-label">Read</div>
            </div>
        </div>
        
        <% if (!successMsg.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= successMsg %>
            </div>
        <% } %>
        
        <% if (!errorMsg.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
            </div>
        <% } %>
        
        <div class="messages-container">
            <div class="messages-header">
                <h2><i class="fas fa-inbox"></i> Contact Messages</h2>
                <div class="filter-buttons">
                    <button class="filter-btn active" onclick="filterMessages('all')">All</button>
                    <button class="filter-btn" onclick="filterMessages('unread')">Unread</button>
                    <button class="filter-btn" onclick="filterMessages('read')">Read</button>
                </div>
            </div>
            
            <div class="message-list">
                <% if (messages.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-envelope-open-text"></i>
                        <h3>No Messages</h3>
                        <p>No contact messages have been submitted yet</p>
                    </div>
                <% } else { %>
                    <% for (Map<String, Object> msg : messages) { 
                        String status = (String) msg.get("status");
                        int msgId = (Integer) msg.get("id");
                    %>
                    <div class="message-item <%= status %>" data-status="<%= status %>">
                        <div class="message-header" onclick="toggleMessage(<%= msgId %>)">
                            <div class="message-info">
                                <div class="message-sender">
                                    <i class="fas fa-user-circle"></i> <%= msg.get("name") %>
                                    <span style="color: #6b7280; font-size: 12px;">&lt;<%= msg.get("email") %>&gt;</span>
                                </div>
                                <div class="message-subject">
                                    <strong>Subject:</strong> <%= msg.get("subject") %>
                                </div>
                            </div>
                            <div class="message-meta">
                                <div class="message-date">
                                    <i class="far fa-clock"></i> <%= msg.get("formatted_date") %>
                                </div>
                                <div class="status-badge <%= status %>">
                                    <%= status.toUpperCase() %>
                                </div>
                            </div>
                        </div>
                        <div class="message-body" id="message-<%= msgId %>">
                            <div class="contact-details">
                                <i class="fas fa-envelope"></i> Email: <%= msg.get("email") %><br>
                                <% if (msg.get("phone") != null && !((String)msg.get("phone")).isEmpty()) { %>
                                    <i class="fas fa-phone"></i> Phone: <%= msg.get("phone") %><br>
                                <% } %>
                            </div>
                            <div class="message-content">
                                <%= msg.get("message").toString().replace("\n", "<br>") %>
                            </div>
                            <div class="action-buttons">
                                <a href="mailto:<%= msg.get("email") %>?subject=Re: <%= msg.get("subject") %>" class="btn btn-primary btn-sm" target="_blank">
                                    <i class="fas fa-reply"></i> Reply via Email
                                </a>
                                <a href="manageMessages.jsp?action=read&id=<%= msgId %>" class="btn btn-secondary btn-sm">
                                    <i class="fas fa-check"></i> Mark as Read
                                </a>
                                <a href="manageMessages.jsp?action=delete&id=<%= msgId %>" class="btn btn-danger btn-sm" 
                                   onclick="return confirm('Are you sure you want to delete this message?')">
                                    <i class="fas fa-trash"></i> Delete
                                </a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        function toggleMessage(id) {
            const messageBody = document.getElementById('message-' + id);
            messageBody.classList.toggle('show');
        }
        
        function filterMessages(filter) {
            const messages = document.querySelectorAll('.message-item');
            const buttons = document.querySelectorAll('.filter-btn');
            
            buttons.forEach(btn => {
                btn.classList.remove('active');
            });
            
            event.target.classList.add('active');
            
            messages.forEach(msg => {
                if (filter === 'all') {
                    msg.style.display = 'block';
                } else {
                    const status = msg.getAttribute('data-status');
                    if (status === filter) {
                        msg.style.display = 'block';
                    } else {
                        msg.style.display = 'none';
                    }
                }
            });
        }
        
        // Auto-expand unread messages
        document.querySelectorAll('.message-item.unread .message-header').forEach(header => {
            header.click();
        });
    </script>
</body>
</html>