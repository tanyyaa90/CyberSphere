<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is main admin
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    if (session.getAttribute("userId") == null || isMainAdmin == null || !isMainAdmin) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String firstName = (String) session.getAttribute("firstName");
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    List<Map<String, Object>> users = new ArrayList<>();
    List<Map<String, Object>> admins = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // Get all regular users (not main admin)
        rs = stmt.executeQuery("SELECT id, first_name, last_name, username, email, role FROM users WHERE role = 'user' ORDER BY first_name");
        while (rs.next()) {
            Map<String, Object> user = new HashMap<>();
            user.put("id", rs.getInt("id"));
            user.put("first_name", rs.getString("first_name"));
            user.put("last_name", rs.getString("last_name"));
            user.put("username", rs.getString("username"));
            user.put("email", rs.getString("email"));
            users.add(user);
        }
        rs.close();
        
        // Get all admins (excluding main admin)
        rs = stmt.executeQuery(
            "SELECT u.id, u.first_name, u.last_name, u.username, u.email, " +
            "ap.can_manage_users, ap.can_manage_quizzes, ap.can_manage_content, ap.can_manage_messages, ap.can_view_logs, ap.is_main_admin " +
            "FROM users u " +
            "LEFT JOIN admin_permissions ap ON u.id = ap.admin_id " +
            "WHERE u.role = 'admin' AND u.is_main_admin = 0 " +
            "ORDER BY u.first_name");
        while (rs.next()) {
            Map<String, Object> admin = new HashMap<>();
            admin.put("id", rs.getInt("id"));
            admin.put("first_name", rs.getString("first_name"));
            admin.put("last_name", rs.getString("last_name"));
            admin.put("username", rs.getString("username"));
            admin.put("email", rs.getString("email"));
            admin.put("can_manage_users", rs.getBoolean("can_manage_users"));
            admin.put("can_manage_quizzes", rs.getBoolean("can_manage_quizzes"));
            admin.put("can_manage_content", rs.getBoolean("can_manage_content"));
            admin.put("can_manage_messages", rs.getBoolean("can_manage_messages"));
            admin.put("can_view_logs", rs.getBoolean("can_view_logs"));
            admins.add(admin);
        }
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
    <title>Manage Admins | CyberSphere</title>
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
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
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
        
        .back-link {
            color: #9ca3af;
            text-decoration: none;
            padding: 8px 16px;
            background: #1a1e24;
            border-radius: 8px;
            transition: all 0.2s ease;
        }
        
        .back-link:hover {
            color: #44634d;
        }
        
        .section {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .section h2 {
            margin-bottom: 20px;
            font-size: 20px;
            color: #ffffff;
        }
        
        .section h2 i {
            color: #44634d;
            margin-right: 10px;
        }
        
        .user-list, .admin-list {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #1e1e1e;
        }
        
        th {
            color: #9ca3af;
            font-weight: 500;
            font-size: 13px;
        }
        
        td {
            color: #e5e7eb;
            font-size: 14px;
        }
        
        .btn {
            padding: 6px 12px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.2s ease;
        }
        
        .btn-primary {
            background: #44634d;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5a7f66;
        }
        
        .btn-danger {
            background: #f87171;
            color: white;
        }
        
        .btn-danger:hover {
            background: #ef4444;
        }
        
        .btn-warning {
            background: #fbbf24;
            color: #0a0c10;
        }
        
        .checkbox-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .checkbox-item input {
            cursor: pointer;
        }
        
        .checkbox-item label {
            font-size: 12px;
            cursor: pointer;
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
        
        .permission-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            margin: 2px;
        }
        
        .badge-user {
            background: #3b82f6;
            color: white;
        }
        
        .badge-quiz {
            background: #8b5cf6;
            color: white;
        }
        
        .badge-content {
            background: #ec489a;
            color: white;
        }
        
        .badge-message {
            background: #f59e0b;
            color: white;
        }
        
        .badge-log {
            background: #10b981;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-user-shield"></i> Manage Administrators</h1>
            <a href="admin_dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
        </div>
        
        <!-- Add New Admin Section -->
        <div class="section">
            <h2><i class="fas fa-user-plus"></i> Add New Administrator</h2>
            <div class="user-list">
                <table>
                    <thead>
                        <tr><th>Name</th><th>Username</th><th>Email</th><th>Permissions</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% if (users.isEmpty()) { %>
                            <tr><td colspan="5" class="empty-state"><i class="fas fa-users"></i> No users available to promote</td></tr>
                        <% } else { %>
                            <% for (Map<String, Object> user : users) { %>
                                <tr>
                                    <td><%= user.get("first_name") %> <%= user.get("last_name") %></td>
                                    <td><%= user.get("username") %></td>
                                    <td><%= user.get("email") %></td>
                                    <td>
                                        <form action="AddAdminServlet" method="post" style="display: flex; gap: 10px; flex-wrap: wrap;">
                                            <input type="hidden" name="userId" value="<%= user.get("id") %>">
                                            <div class="checkbox-group">
                                                <div class="checkbox-item">
                                                    <input type="checkbox" name="can_manage_users" id="users_<%= user.get("id") %>">
                                                    <label for="users_<%= user.get("id") %>">Manage Users</label>
                                                </div>
                                                <div class="checkbox-item">
                                                    <input type="checkbox" name="can_manage_quizzes" id="quizzes_<%= user.get("id") %>">
                                                    <label for="quizzes_<%= user.get("id") %>">Manage Quizzes</label>
                                                </div>
                                                <div class="checkbox-item">
                                                    <input type="checkbox" name="can_manage_content" id="content_<%= user.get("id") %>">
                                                    <label for="content_<%= user.get("id") %>">Manage Content</label>
                                                </div>
                                                <div class="checkbox-item">
                                                    <input type="checkbox" name="can_manage_messages" id="messages_<%= user.get("id") %>">
                                                    <label for="messages_<%= user.get("id") %>">Manage Messages</label>
                                                </div>
                                                <div class="checkbox-item">
                                                    <input type="checkbox" name="can_view_logs" id="logs_<%= user.get("id") %>">
                                                    <label for="logs_<%= user.get("id") %>">View Logs</label>
                                                </div>
                                            </div>
                                            <button type="submit" class="btn btn-primary"><i class="fas fa-user-plus"></i> Make Admin</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Existing Admins Section -->
        <div class="section">
            <h2><i class="fas fa-users"></i> Current Administrators</h2>
            <div class="admin-list">
                <table>
                    <thead>
                        <tr><th>Name</th><th>Username</th><th>Email</th><th>Permissions</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% if (admins.isEmpty()) { %>
                            <tr><td colspan="5" class="empty-state"><i class="fas fa-user-slash"></i> No other administrators</td></tr>
                        <% } else { %>
                            <% for (Map<String, Object> admin : admins) { %>
                                <tr>
                                    <td><%= admin.get("first_name") %> <%= admin.get("last_name") %></td>
                                    <td><%= admin.get("username") %></td>
                                    <td><%= admin.get("email") %></td>
                                    <td>
                                        <% if ((Boolean) admin.get("can_manage_users")) { %>
                                            <span class="permission-badge badge-user">Users</span>
                                        <% } %>
                                        <% if ((Boolean) admin.get("can_manage_quizzes")) { %>
                                            <span class="permission-badge badge-quiz">Quizzes</span>
                                        <% } %>
                                        <% if ((Boolean) admin.get("can_manage_content")) { %>
                                            <span class="permission-badge badge-content">Content</span>
                                        <% } %>
                                        <% if ((Boolean) admin.get("can_manage_messages")) { %>
                                            <span class="permission-badge badge-message">Messages</span>
                                        <% } %>
                                        <% if ((Boolean) admin.get("can_view_logs")) { %>
                                            <span class="permission-badge badge-log">Logs</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <form action="RemoveAdminServlet" method="post" style="display: inline;">
                                            <input type="hidden" name="adminId" value="<%= admin.get("id") %>">
                                            <button type="submit" class="btn btn-danger" onclick="return confirm('Remove this administrator?')"><i class="fas fa-trash"></i> Remove</button>
                                        </form>
                                        <button class="btn btn-warning" onclick="showEditPermissions(<%= admin.get("id") %>)"><i class="fas fa-edit"></i> Edit</button>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>