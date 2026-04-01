<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
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
%>
<!DOCTYPE html>
<html>
<head>
    <title>Contact Messages | Admin Panel</title>
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
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: 2px solid #44634d;
            object-fit: cover;
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 12px;
            padding: 20px;
        }
        
        .stat-card h3 {
            color: #9ca3af;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .stat-card .number {
            color: #ffffff;
            font-size: 32px;
            font-weight: 600;
        }
        
        .stat-card .number span {
            color: #44634d;
            font-size: 14px;
            margin-left: 5px;
        }
        
        /* Filter Bar */
        .filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            color: #9ca3af;
            padding: 10px 20px;
            border-radius: 30px;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .filter-btn:hover {
            border-color: #44634d;
            color: #ffffff;
        }
        
        .filter-btn.active {
            background: #44634d;
            color: white;
            border-color: #44634d;
        }
        
        .filter-btn i {
            font-size: 14px;
        }
        
        /* Messages Grid - RECTANGULAR CARDS */
        .messages-grid {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .message-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.2s ease;
            width: 100%;
        }
        
        .message-card:hover {
            border-color: #44634d;
            box-shadow: 0 5px 15px -5px rgba(68, 99, 77, 0.3);
        }
        
        .message-card.unread {
            border-left: 4px solid #ef4444;
        }
        
        .message-card.read {
            border-left: 4px solid #44634d;
        }
        
        .message-header {
            padding: 20px 25px;
            border-bottom: 1px solid #1e1e1e;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1e24;
        }
        
        .sender-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .sender-avatar {
            width: 50px;
            height: 50px;
            background: #0f1115;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #44634d;
        }
        
        .sender-avatar i {
            font-size: 24px;
            color: #44634d;
        }
        
        .sender-details h4 {
            color: #ffffff;
            font-size: 18px;
            margin-bottom: 5px;
        }
        
        .sender-details .email {
            color: #9ca3af;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-badge.unread {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }
        
        .status-badge.read {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }
        
        .message-body {
            padding: 25px;
        }
        
        .subject-line {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
            color: #e5e7eb;
            font-weight: 600;
            font-size: 16px;
        }
        
        .subject-line i {
            color: #44634d;
            font-size: 16px;
        }
        
        .message-content {
            color: #9ca3af;
            font-size: 15px;
            line-height: 1.8;
            margin-bottom: 20px;
            white-space: pre-wrap;
            word-break: break-word;
        }
        
        .phone-number {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #1a1e24;
            padding: 8px 16px;
            border-radius: 30px;
            font-size: 14px;
            color: #9ca3af;
            margin-top: 10px;
            border: 1px solid #2a2f3a;
        }
        
        .phone-number i {
            color: #44634d;
            font-size: 14px;
        }
        
        .message-footer {
            padding: 15px 25px;
            border-top: 1px solid #1e1e1e;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1e24;
        }
        
        .time-info {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #6b7280;
            font-size: 14px;
        }
        
        .time-info i {
            font-size: 14px;
        }
        
        .card-actions {
            display: flex;
            gap: 10px;
        }
        
        .card-action-btn {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #0f1115;
            border: 1px solid #2a2f3a;
            color: #9ca3af;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }
        
        .card-action-btn:hover {
            background: #44634d;
            color: white;
            border-color: #44634d;
            transform: scale(1.1);
        }
        
        .card-action-btn.delete:hover {
            background: #ef4444;
            border-color: #ef4444;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px;
            background: #0f1115;
            border-radius: 16px;
            border: 1px solid #1e1e1e;
        }
        
        .empty-state i {
            font-size: 60px;
            color: #44634d;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .empty-state h3 {
            color: #ffffff;
            font-size: 22px;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #9ca3af;
        }
        
        /* Main content wrapper */
        .main-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .admin-profile {
                width: 100%;
                justify-content: center;
            }
            
            .message-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .sender-info {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- Main Content (No Sidebar, No Back Link) -->
    <div class="main-content">
        <div class="header">
            <h1>Contact Messages</h1>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <!-- Stats Cards -->
        <%
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            int totalMessages = 0;
            int unreadMessages = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/cybersphere", "root", "root");
                stmt = conn.createStatement();
                
                rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages");
                if (rs.next()) totalMessages = rs.getInt("count");
                rs.close();
                
                rs = stmt.executeQuery("SELECT COUNT(*) as count FROM contact_messages WHERE status = 'unread'");
                if (rs.next()) unreadMessages = rs.getInt("count");
                rs.close();
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Messages</h3>
                <div class="number"><%= totalMessages %></div>
            </div>
            <div class="stat-card">
                <h3>Unread Messages</h3>
                <div class="number"><%= unreadMessages %></div>
            </div>
            <div class="stat-card">
                <h3>Read Messages</h3>
                <div class="number"><%= totalMessages - unreadMessages %></div>
            </div>
        </div>
        
        <!-- Filter Bar -->
        <div class="filter-bar">
            <button class="filter-btn active" onclick="filterMessages('all')">
                <i class="fas fa-envelope"></i> All Messages
            </button>
            <button class="filter-btn" onclick="filterMessages('unread')">
                <i class="fas fa-envelope-open"></i> Unread (<%= unreadMessages %>)
            </button>
            <button class="filter-btn" onclick="filterMessages('read')">
                <i class="fas fa-envelope-open-text"></i> Read (<%= totalMessages - unreadMessages %>)
            </button>
        </div>
        
        <!-- Messages Grid - RECTANGULAR CARDS -->
        <div class="messages-grid" id="messagesGrid">
        <%
            try {
                rs = stmt.executeQuery("SELECT * FROM contact_messages ORDER BY submitted_at DESC");
                
                boolean hasMessages = false;
                while (rs.next()) {
                    hasMessages = true;
                    String status = rs.getString("status");
                    if (status == null) status = "unread";
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    String email = rs.getString("email");
                    String phone = rs.getString("phone");
                    String subject = rs.getString("subject");
                    String message = rs.getString("message");
                    Timestamp submittedAt = rs.getTimestamp("submitted_at");
                    
                    // Format date
                    String displayDate = "Unknown";
                    if (submittedAt != null) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy • hh:mm a");
                        displayDate = sdf.format(submittedAt);
                    }
                    
                    // Handle phone for display
                    String displayPhone = (phone != null && !phone.isEmpty() && !"null".equals(phone)) ? phone : "";
        %>
            <div class="message-card <%= status %>" data-status="<%= status %>" data-id="<%= id %>">
                <div class="message-header">
                    <div class="sender-info">
                        <div class="sender-avatar">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="sender-details">
                            <h4><%= name %></h4>
                            <div class="email">
                                <i class="fas fa-envelope"></i> <%= email %>
                            </div>
                        </div>
                    </div>
                    <span class="status-badge <%= status %>">
                        <%= status %>
                    </span>
                </div>
                
                <div class="message-body">
                    <div class="subject-line">
                        <i class="fas fa-tag"></i>
                        <span><%= subject %></span>
                    </div>
                    
                    <div class="message-content">
                        <%= message.replace("\n", "<br>") %>
                    </div>
                    
                    <% if (phone != null && !phone.isEmpty() && !"null".equals(phone)) { %>
                        <div class="phone-number">
                            <i class="fas fa-phone-alt"></i> <%= phone %>
                        </div>
                    <% } %>
                </div>
                
                <div class="message-footer">
                    <div class="time-info">
                        <i class="far fa-clock"></i> <%= displayDate %>
                    </div>
                    
                    <div class="card-actions">
                        <% if ("unread".equals(status)) { %>
                            <a href="markRead.jsp?id=<%= id %>" class="card-action-btn" title="Mark as Read">
                                <i class="fas fa-check"></i>
                            </a>
                        <% } %>
                        
                        <a href="#" onclick="deleteMessage(<%= id %>)" class="card-action-btn delete" title="Delete">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </div>
            </div>
        <%
                }
                
                if (!hasMessages) {
        %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <h3>No Messages Yet</h3>
                <p>When users contact you through the contact form, their messages will appear here.</p>
            </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception e) {}
                if (stmt != null) try { stmt.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        %>
        </div> <!-- Close messages-grid -->
    </div> <!-- Close main-content -->
    
    <script>
        function filterMessages(type) {
            // Update active button
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
            
            // Filter cards
            const cards = document.querySelectorAll('.message-card');
            cards.forEach(card => {
                if (type === 'all' || card.dataset.status === type) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            });
        }
        
        function deleteMessage(id) {
            if (confirm('Are you sure you want to delete this message? This action cannot be undone.')) {
                window.location.href = 'deleteMessage.jsp?id=' + id;
            }
        }
    </script>
</body>
</html>