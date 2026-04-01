<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String firstName = (String) session.getAttribute("firstName");
    String profileImage = (String) session.getAttribute("profileImage");
    if (profileImage == null) profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";
    
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Users | CyberSphere Admin</title>
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
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 2px solid #44634d;
            object-fit: cover;
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
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            display: inline-block;
        }
        
        .role-badge.admin {
            background: #1a2e1a;
            color: #86efac;
        }
        
        .role-badge.user {
            background: #1e293b;
            color: #94a3b8;
        }
        
        .action-link {
            color: #9ca3af;
            margin: 0 8px;
            text-decoration: none;
        }
        
        .action-link:hover {
            color: #44634d;
        }
        
        .action-link.delete:hover {
            color: #ef4444;
        }
        
        .search-box {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .search-input {
            flex: 1;
            padding: 12px 16px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 8px;
            color: #ffffff;
        }
        
        .search-input:focus {
            outline: none;
            border-color: #44634d;
        }
        
        /* Responsive */
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
            
            .search-box {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <!-- Main Content (No Sidebar) -->
    <div class="main-content" style="max-width: 1400px; margin: 0 auto;">
        <div class="header">
            <div class="header-left">
                <h1>Manage Users</h1>

            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %>!</span>
            </div>
        </div>
        
        <div class="users-table">
            <div class="table-header">
                <h2>All Users</h2>
            </div>
            
            <!-- Search Box -->
            <div class="search-box">
                <input type="text" class="search-input" id="searchInput" placeholder="Search by name, email or username..." onkeyup="searchUsers()">
                <button class="btn btn-primary" onclick="searchUsers()">
                    <i class="fas fa-search"></i> Search
                </button>
            </div>
            
            <table id="usersTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection(url, dbUser, dbPass);
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT id, username, first_name, last_name, email, phone, role FROM users ORDER BY id DESC");
                            
                            while (rs.next()) {
                                String userRole = rs.getString("role");
                                if (userRole == null) userRole = "user";
                    %>
                    <tr>
                        <td>#<%= rs.getInt("id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") %></td>
                        <td>
                            <span class="role-badge <%= userRole %>">
                                <%= userRole %>
                            </span>
                        </td>
                        <td>
                            <a href="makeAdmin.jsp?id=<%= rs.getInt("id") %>" class="action-link">
                                <i class="fas fa-edit"></i>
                            </a>
                            <a href="#" onclick="deleteUser(<%= rs.getInt("id") %>)" class="action-link delete">
                                <i class="fas fa-trash"></i>
                            </a>
                            <% if (!"admin".equals(userRole)) { %>
                                <a href="makeAdmin.jsp?id=<%= rs.getInt("id") %>" class="action-link" style="color: #44634d;">
                                    <i class="fas fa-user-shield"></i>
                                </a>
                            <% } %>
                        </td>
                    </tr>
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
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        function deleteUser(id) {
            if (confirm('⚠️ Are you sure you want to delete this user?\n\nThis action cannot be undone!')) {
                window.location.href = 'deleteUser.jsp?id=' + id;
            }
        }
        
        function searchUsers() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            const table = document.getElementById('usersTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                const text = row.textContent.toLowerCase();
                if (text.includes(input)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        }
    </script>
</body>
</html>