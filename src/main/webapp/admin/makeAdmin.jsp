<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    Integer currentUserId = (Integer) session.getAttribute("userId");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    
    if (currentUserId == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if current user is MAIN admin
    if (isMainAdmin == null || !isMainAdmin) {
        response.sendRedirect("admin_home.jsp?error=You don't have permission to manage admins");
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
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // Handle form submission to update admin permissions
    String action = request.getParameter("action");
    String message = "";
    String error = "";
    
    // Now handle the permission update
    if ("update_permissions".equals(action)) {
        int targetUserId = Integer.parseInt(request.getParameter("user_id"));
        String newRole = request.getParameter("role");
        boolean canManageQuizzes = "on".equals(request.getParameter("can_manage_quizzes"));
        boolean canManageContent = "on".equals(request.getParameter("can_manage_content"));
        boolean canManageMessages = "on".equals(request.getParameter("can_manage_messages"));
        boolean canViewLogs = "on".equals(request.getParameter("can_view_logs"));
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);
            conn.setAutoCommit(false);
            
            // Update user role in users table
            String updateRoleSql = "UPDATE users SET role = ? WHERE id = ?";
            ps = conn.prepareStatement(updateRoleSql);
            ps.setString(1, newRole);
            ps.setInt(2, targetUserId);
            ps.executeUpdate();
            ps.close();
            
            if ("admin".equals(newRole)) {
                // Check if entry exists
                String checkSql = "SELECT * FROM admin_permissions WHERE user_id = ?";
                ps = conn.prepareStatement(checkSql);
                ps.setInt(1, targetUserId);
                ResultSet checkRs = ps.executeQuery();
                
                if (checkRs.next()) {
                    // Update existing permissions
                    String updatePermSql = "UPDATE admin_permissions SET " +
                        "can_manage_quizzes = ?, can_manage_content = ?, " +
                        "can_manage_messages = ?, can_view_logs = ? " +
                        "WHERE user_id = ?";
                    ps = conn.prepareStatement(updatePermSql);
                    ps.setBoolean(2, canManageQuizzes);
                    ps.setBoolean(3, canManageContent);
                    ps.setBoolean(4, canManageMessages);
                    ps.setBoolean(5, canViewLogs);
                    ps.setInt(6, targetUserId);
                    ps.executeUpdate();
                } else {
                    // Insert new permissions
                    String insertPermSql = "INSERT INTO admin_permissions (user_id, can_manage_users, can_manage_quizzes, can_manage_content, can_manage_messages, can_view_logs) " +
                                           "VALUES (?, ?, ?, ?, ?, ?)";
                    ps = conn.prepareStatement(insertPermSql);
                    ps.setInt(1, targetUserId);
                    ps.setBoolean(3, canManageQuizzes);
                    ps.setBoolean(4, canManageContent);
                    ps.setBoolean(5, canManageMessages);
                    ps.setBoolean(6, canViewLogs);
                    ps.executeUpdate();
                }
                checkRs.close();
            } else {
                // If demoting to user, remove permissions
                String deletePermsSql = "DELETE FROM admin_permissions WHERE user_id = ?";
                ps = conn.prepareStatement(deletePermsSql);
                ps.setInt(1, targetUserId);
                ps.executeUpdate();
            }
            
            conn.commit();
            message = "Permissions updated successfully!";
            
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            error = "Error updating permissions: " + e.getMessage();
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
    
    // Get all users with their admin permissions
    List<Map<String, Object>> users = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        String sql = "SELECT u.id, u.username, u.first_name, u.last_name, u.email, u.role, u.is_main_admin, " +
                     "COALESCE(p.can_manage_users, FALSE) as can_manage_users, " +
                     "COALESCE(p.can_manage_quizzes, FALSE) as can_manage_quizzes, " +
                     "COALESCE(p.can_manage_content, FALSE) as can_manage_content, " +
                     "COALESCE(p.can_manage_messages, FALSE) as can_manage_messages, " +
                     "COALESCE(p.can_view_logs, FALSE) as can_view_logs " +
                     "FROM users u " +
                     "LEFT JOIN admin_permissions p ON u.id = p.user_id " +
                     "ORDER BY u.id";
        
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        
        while (rs.next()) {
            Map<String, Object> user = new HashMap<>();
            user.put("id", rs.getInt("id"));
            user.put("username", rs.getString("username"));
            user.put("first_name", rs.getString("first_name"));
            user.put("last_name", rs.getString("last_name"));
            user.put("email", rs.getString("email"));
            user.put("role", rs.getString("role"));
            user.put("is_main_admin", rs.getBoolean("is_main_admin"));
            user.put("can_manage_users", rs.getBoolean("can_manage_users"));
            user.put("can_manage_quizzes", rs.getBoolean("can_manage_quizzes"));
            user.put("can_manage_content", rs.getBoolean("can_manage_content"));
            user.put("can_manage_messages", rs.getBoolean("can_manage_messages"));
            user.put("can_view_logs", rs.getBoolean("can_view_logs"));
            users.add(user);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        error = "Error loading users: " + e.getMessage();
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
        
        .info-box {
            background: #1a2a1a;
            border: 1px solid #2a4a2a;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .info-box i {
            font-size: 24px;
            color: #86efac;
        }
        
        .info-box p {
            color: #9ca3af;
            line-height: 1.6;
        }
        
        .info-box strong {
            color: #86efac;
        }
        
        .users-table {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            overflow-x: auto;
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .table-header h2 {
            color: #ffffff;
            font-size: 20px;
        }
        
        .permissions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            margin: 10px 0;
        }
        
        .permission-item {
            display: flex;
            align-items: center;
            gap: 8px;
            background: #1a1e24;
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px solid #2a2f3a;
        }
        
        .permission-item input[type="checkbox"] {
            width: 16px;
            height: 16px;
            cursor: pointer;
            accent-color: #44634d;
        }
        
        .permission-item label {
            color: #9ca3af;
            font-size: 13px;
            cursor: pointer;
            flex: 1;
        }
        
        .permission-item i {
            color: #44634d;
            width: 16px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            text-align: left;
            padding: 15px 10px;
            color: #9ca3af;
            font-weight: 500;
            border-bottom: 1px solid #1e1e1e;
        }
        
        td {
            padding: 15px 10px;
            color: #e5e7eb;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .role-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .role-badge.main-admin {
            background: #1a2e1a;
            color: #fbbf24;
            border: 1px solid #fbbf24;
        }
        
        .role-badge.admin {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }
        
        .role-badge.user {
            background: #1e293b;
            color: #94a3b8;
            border: 1px solid #334155;
        }
        
        .permission-tag {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 10px;
            margin: 2px;
            background: #1a2e1a;
            color: #86efac;
        }
        
        .action-link {
            color: #9ca3af;
            text-decoration: none;
            cursor: pointer;
            transition: color 0.2s ease;
        }
        
        .action-link:hover {
            color: #fbbf24;
        }
        
        .edit-form {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 20px;
            margin-top: 10px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            color: #9ca3af;
            font-size: 13px;
            margin-bottom: 5px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 12px;
            background: #0f1115;
            border: 1px solid #2a2f3a;
            border-radius: 6px;
            color: #ffffff;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #44634d;
        }
        
        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: #44634d;
            color: white;
        }
        
        .btn-primary:hover {
            background: #36523d;
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: #1a1e24;
            color: #9ca3af;
            border: 1px solid #2a2f3a;
        }
        
        .btn-secondary:hover {
            background: #1f242b;
            color: #ffffff;
            border-color: #44634d;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .header-left {
                flex-direction: column;
            }
            
            .admin-profile {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-user-shield"></i> Manage Administrators</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <div class="info-box">
            <i class="fas fa-crown"></i>
            <div>
                <p><strong>Main Admin Access</strong> — You have full control to assign admin roles and permissions. 
                Other admins will only have access to the sections you enable for them.</p>
            </div>
        </div>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
        <% } %>
        
        <% if (!error.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>
        
        <div class="users-table">
            <div class="table-header">
                <h2><i class="fas fa-users"></i> All Users</h2>
                <span class="role-badge main-admin">Main Admin (You)</span>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Permissions</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> user : users) { 
                        int userId = (Integer) user.get("id");
                        String userRole = (String) user.get("role");
                        boolean isMainAdminUser = (Boolean) user.get("is_main_admin");
                        boolean isCurrentUser = (userId == currentUserId);
                    %>
                    <tr>
                        <td>#<%= userId %></td>
                        <td><%= user.get("first_name") %> <%= user.get("last_name") %></td>
                        <td><%= user.get("username") %></td>
                        <td><%= user.get("email") %></td>
                        <td>
                            <% if (isCurrentUser) { %>
                                <span class="role-badge main-admin">Main Admin</span>
                            <% } else if (isMainAdminUser) { %>
                                <span class="role-badge main-admin">Main Admin</span>
                            <% } else if ("admin".equals(userRole)) { %>
                                <span class="role-badge admin">Sub-Admin</span>
                            <% } else { %>
                                <span class="role-badge user">User</span>
                            <% } %>
                        </td>
                        <td>
                            <% if ("admin".equals(userRole) && !isCurrentUser && !isMainAdminUser) { %>
                                <div style="display: flex; flex-wrap: wrap; gap: 5px;">
                                    <% if ((Boolean) user.get("can_manage_quizzes")) { %>
                                        <span class="permission-tag">❓ Quizzes</span>
                                    <% } %>
                                    <% if ((Boolean) user.get("can_manage_content")) { %>
                                        <span class="permission-tag">📝 Content</span>
                                    <% } %>
                                    <% if ((Boolean) user.get("can_manage_messages")) { %>
                                        <span class="permission-tag">📧 Messages</span>
                                    <% } %>
                                    <% if ((Boolean) user.get("can_view_logs")) { %>
                                        <span class="permission-tag">📊 Logs</span>
                                    <% } %>
                                </div>
                            <% } else if ("admin".equals(userRole) && isCurrentUser) { %>
                                <span style="color: #fbbf24;">Full Access</span>
                            <% } else { %>
                                <span style="color: #6b7280;">No admin permissions</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (!isCurrentUser && !isMainAdminUser) { %>
                                <a href="#" onclick="toggleEditForm(<%= userId %>)" class="action-link">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                            <% } else if (isCurrentUser) { %>
                                <span style="color: #6b7280;">(You)</span>
                            <% } else if (isMainAdminUser) { %>
                                <span style="color: #6b7280;">Main Admin</span>
                            <% } %>
                        </td>
                    </tr>
                    <% if (!isCurrentUser && !isMainAdminUser) { %>
                    <tr id="edit-form-<%= userId %>" style="display: none;">
                        <td colspan="7">
                            <div class="edit-form">
                                <form method="post" action="makeAdmin.jsp">
                                    <input type="hidden" name="action" value="update_permissions">
                                    <input type="hidden" name="user_id" value="<%= userId %>">
                                    
                                    <div style="margin-bottom: 20px;">
                                        <div class="form-group">
                                            <label>Role</label>
                                            <select name="role" class="form-control" onchange="togglePermissions(this, <%= userId %>)">
                                                <option value="user" <%= "user".equals(userRole) ? "selected" : "" %>>Regular User</option>
                                                <option value="admin" <%= "admin".equals(userRole) ? "selected" : "" %>>Sub-Admin</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div id="permissions-<%= userId %>" style="<%= "admin".equals(userRole) ? "" : "display: none;" %>">
                                        <label style="color: #9ca3af; margin-bottom: 10px; display: block;"> Admin Permissions:</label>
                                        <div class="permissions-grid">
                                            
                                            <div class="permission-item">
                                                <i class="fas fa-question-circle"></i>
                                                <input type="checkbox" name="can_manage_quizzes" id="quizzes_<%= userId %>" <%= (Boolean) user.get("can_manage_quizzes") ? "checked" : "" %>>
                                                <label for="quizzes_<%= userId %>">Manage Quizzes</label>
                                            </div>
                                            
                                            <div class="permission-item">
                                                <i class="fas fa-newspaper"></i>
                                                <input type="checkbox" name="can_manage_content" id="content_<%= userId %>" <%= (Boolean) user.get("can_manage_content") ? "checked" : "" %>>
                                                <label for="content_<%= userId %>">Manage Content</label>
                                            </div>
                                            
                                            <div class="permission-item">
                                                <i class="fas fa-envelope"></i>
                                                <input type="checkbox" name="can_manage_messages" id="messages_<%= userId %>" <%= (Boolean) user.get("can_manage_messages") ? "checked" : "" %>>
                                                <label for="messages_<%= userId %>">Manage Messages</label>
                                            </div>
                                            
                                            <div class="permission-item">
                                                <i class="fas fa-chart-line"></i>
                                                <input type="checkbox" name="can_view_logs" id="logs_<%= userId %>" <%= (Boolean) user.get("can_view_logs") ? "checked" : "" %>>
                                                <label for="logs_<%= userId %>">View Logs</label>
                                            </div>
                                        </div>
                                        <p style="color: #6b7280; font-size: 12px; margin-top: 10px;">
                                            <i class="fas fa-info-circle"></i> Grant specific permissions to control what this admin can do.
                                        </p>
                                    </div>
                                    
                                    <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px;">
                                        <button type="button" class="btn btn-secondary btn-sm" onclick="toggleEditForm(<%= userId %>)">
                                            <i class="fas fa-times"></i> Cancel
                                        </button>
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="fas fa-save"></i> Save Changes
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        function toggleEditForm(userId) {
            const formRow = document.getElementById('edit-form-' + userId);
            if (formRow.style.display === 'none' || formRow.style.display === '') {
                formRow.style.display = 'table-row';
            } else {
                formRow.style.display = 'none';
            }
        }
        
        function togglePermissions(select, userId) {
            const permissionsDiv = document.getElementById('permissions-' + userId);
            if (select.value === 'admin') {
                permissionsDiv.style.display = 'block';
            } else {
                permissionsDiv.style.display = 'none';
            }
        }
    </script>
</body>
</html>