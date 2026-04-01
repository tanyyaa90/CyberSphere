<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    Integer currentUserId = (Integer) session.getAttribute("userId");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    Boolean canManageContent = (Boolean) session.getAttribute("can_manage_content");
    
    if (currentUserId == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if admin has permission to manage content
    if (!isMainAdmin && (canManageContent == null || !canManageContent)) {
        response.sendRedirect("admin_home.jsp?error=You don't have permission to manage content");
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
    
    // Handle form submissions
    String action = request.getParameter("action");
    String successMsg = "";
    String errorMsg = "";
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // Handle Add Content
        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String level = request.getParameter("level");
            String topic = request.getParameter("topic");
            String description = request.getParameter("description");
            String type = request.getParameter("type");
            String duration = request.getParameter("duration");
            String source = request.getParameter("source");
            String contentUrl = request.getParameter("url");
            String thumbnailUrl = request.getParameter("thumbnail_url");
            
            if (title != null && !title.trim().isEmpty()) {
                String insertSql = "INSERT INTO learning_content (title, level, topic, description, type, duration, source, url, thumbnail_url, created_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, title);
                ps.setString(2, level);
                ps.setString(3, topic);
                ps.setString(4, description);
                ps.setString(5, type);
                ps.setString(6, duration);
                ps.setString(7, source);
                ps.setString(8, contentUrl);
                ps.setString(9, thumbnailUrl);
                ps.setInt(10, currentUserId);
                ps.executeUpdate();
                successMsg = "Content added successfully!";
            } else {
                errorMsg = "Title is required";
            }
            if (ps != null) ps.close();
        }
        
        // Handle Delete Content
        if ("delete".equals(action)) {
            String contentId = request.getParameter("id");
            if (contentId != null) {
                String deleteSql = "DELETE FROM learning_content WHERE id = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(contentId));
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    successMsg = "Content deleted successfully";
                }
                ps.close();
            }
        }
        
        // Handle Edit Content
        if ("edit".equals(action)) {
            String contentId = request.getParameter("id");
            String title = request.getParameter("title");
            String level = request.getParameter("level");
            String topic = request.getParameter("topic");
            String description = request.getParameter("description");
            String type = request.getParameter("type");
            String duration = request.getParameter("duration");
            String source = request.getParameter("source");
            String contentUrl = request.getParameter("url");
            String thumbnailUrl = request.getParameter("thumbnail_url");
            
            if (contentId != null && title != null && !title.trim().isEmpty()) {
                String updateSql = "UPDATE learning_content SET title = ?, level = ?, topic = ?, description = ?, type = ?, duration = ?, source = ?, url = ?, thumbnail_url = ? WHERE id = ?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, title);
                ps.setString(2, level);
                ps.setString(3, topic);
                ps.setString(4, description);
                ps.setString(5, type);
                ps.setString(6, duration);
                ps.setString(7, source);
                ps.setString(8, contentUrl);
                ps.setString(9, thumbnailUrl);
                ps.setInt(10, Integer.parseInt(contentId));
                ps.executeUpdate();
                successMsg = "Content updated successfully!";
                ps.close();
            } else {
                errorMsg = "Title is required";
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Database error: " + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Fetch all content
    List<Map<String, Object>> contentList = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // Fetch all content with creator name
        String contentSql = "SELECT lc.*, u.first_name, u.last_name " +
                            "FROM learning_content lc " +
                            "LEFT JOIN users u ON lc.created_by = u.id " +
                            "ORDER BY lc.created_at DESC";
        rs = stmt.executeQuery(contentSql);
        
        while (rs.next()) {
            Map<String, Object> content = new HashMap<>();
            content.put("id", rs.getInt("id"));
            content.put("title", rs.getString("title"));
            content.put("level", rs.getString("level"));
            content.put("topic", rs.getString("topic"));
            content.put("description", rs.getString("description"));
            content.put("type", rs.getString("type"));
            content.put("duration", rs.getString("duration"));
            content.put("source", rs.getString("source"));
            content.put("url", rs.getString("url"));
            content.put("thumbnail_url", rs.getString("thumbnail_url"));
            content.put("views", rs.getInt("views"));
            content.put("created_at", rs.getTimestamp("created_at"));
            content.put("formatted_date", rs.getTimestamp("created_at") != null ? sdf.format(rs.getTimestamp("created_at")) : "Unknown");
            content.put("created_by", rs.getString("first_name") + " " + rs.getString("last_name"));
            contentList.add(content);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Error loading content: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Content | CyberSphere</title>
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
            max-width: 1200px;
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
        
        .card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            margin-bottom: 25px;
            overflow: hidden;
        }
        
        .card-header {
            padding: 20px 25px;
            background: #1a1e24;
            border-bottom: 1px solid #2a2f3a;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .card-header h2 {
            font-size: 20px;
            color: #ffffff;
        }
        
        .card-header h2 i {
            color: #44634d;
            margin-right: 8px;
        }
        
        .card-body {
            padding: 25px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: #9ca3af;
            font-size: 13px;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 8px;
            color: #ffffff;
            font-size: 14px;
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #44634d;
        }
        
        select.form-control {
            cursor: pointer;
        }
        
        textarea.form-control {
            resize: vertical;
            font-family: inherit;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
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
            font-size: 14px;
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
        
        .content-table {
            width: 100%;
            border-collapse: collapse;
            overflow-x: auto;
            display: block;
        }
        
        .content-table thead {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .content-table tbody {
            display: block;
            max-height: 500px;
            overflow-y: auto;
            width: 100%;
        }
        
        .content-table tr {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .content-table th {
            text-align: left;
            padding: 12px;
            color: #9ca3af;
            font-weight: 500;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .content-table td {
            padding: 12px;
            color: #e5e7eb;
            border-bottom: 1px solid #1e1e1e;
            vertical-align: middle;
        }
        
        .type-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 500;
        }
        
        .type-badge.video {
            background: #1a2e4a;
            color: #60a5fa;
        }
        
        .type-badge.article {
            background: #1a2e1a;
            color: #86efac;
        }
        
        .type-badge.infographic {
            background: #332a1a;
            color: #fbbf24;
        }
        
        .level-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            background: #1a1e24;
            color: #9ca3af;
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
        
        .action-icons {
            display: flex;
            gap: 8px;
        }
        
        .action-icon {
            color: #9ca3af;
            text-decoration: none;
            cursor: pointer;
            transition: color 0.2s ease;
        }
        
        .action-icon.edit:hover {
            color: #fbbf24;
        }
        
        .action-icon.delete:hover {
            color: #f87171;
        }
        
        .edit-form {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 20px;
            margin: 10px;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .content-table {
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-newspaper"></i> Manage Content</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
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
        
        <!-- Add New Content Form -->
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-plus-circle"></i> Add New Content</h2>
            </div>
            <div class="card-body">
                <form method="post" action="manageContent.jsp">
                    <input type="hidden" name="action" value="add">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Title *</label>
                            <input type="text" name="title" class="form-control" required placeholder="Enter content title">
                        </div>
                        <div class="form-group">
                            <label>Content Type *</label>
                            <select name="type" class="form-control" required>
                                <option value="video">Video</option>
                                <option value="article">Article</option>
                                <option value="infographic">Infographic / Image</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Level</label>
                            <select name="level" class="form-control">
                                <option value="">-- All Levels --</option>
                                <option value="beginner">Beginner</option>
                                <option value="intermediate">Intermediate</option>
                                <option value="hard">Hard</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Topic</label>
                            <input type="text" name="topic" class="form-control" placeholder="e.g., Phishing, Passwords, SSL">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Duration</label>
                            <input type="text" name="duration" class="form-control" placeholder="e.g., 10 mins, 5 pages">
                        </div>
                        <div class="form-group">
                            <label>Source</label>
                            <input type="text" name="source" class="form-control" placeholder="e.g., YouTube, Blog, Official">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea name="description" class="form-control" rows="3" placeholder="Enter a brief description"></textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>URL / Embed Link *</label>
                            <input type="url" name="url" class="form-control" required placeholder="https://...">
                        </div>
                        <div class="form-group">
                            <label>Thumbnail URL</label>
                            <input type="url" name="thumbnail_url" class="form-control" placeholder="https://...">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Add Content
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Existing Content List -->
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-list"></i> Existing Content</h2>
                <span style="color: #9ca3af;"><i class="fas fa-database"></i> Total: <%= contentList.size() %></span>
            </div>
            <div class="card-body">
                <% if (contentList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-folder-open"></i>
                        <h3>No Content Yet</h3>
                        <p>Add your first learning content using the form above</p>
                    </div>
                <% } else { %>
                    <table class="content-table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Title</th>
                                <th>Level</th>
                                <th>Topic</th>
                                <th>Views</th>
                                <th>Added By</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> content : contentList) { 
                                String contentType = (String) content.get("type");
                                int contentId = (Integer) content.get("id");
                            %>
                            <tr id="row-<%= contentId %>">
                                <td>
                                    <span class="type-badge <%= contentType %>">
                                        <i class="fas <%= contentType.equals("video") ? "fa-video" : contentType.equals("article") ? "fa-newspaper" : "fa-image" %>"></i>
                                        <%= contentType != null ? contentType.toUpperCase() : "N/A" %>
                                    </span>
                                </td>
                                <td>
                                    <a href="<%= content.get("url") %>" target="_blank" style="color: #86efac; text-decoration: none;">
                                        <%= content.get("title") != null ? content.get("title") : "Untitled" %>
                                    </a>
                                </td>
                                <td>
                                    <span class="level-badge">
                                        <%= content.get("level") != null ? content.get("level") : "All Levels" %>
                                    </span>
                                </td>
                                <td><%= content.get("topic") != null ? content.get("topic") : "General" %></td>
                                <td><%= content.get("views") != null ? content.get("views") : 0 %> views</td>
                                <td><%= content.get("created_by") != null ? content.get("created_by") : "Unknown" %></td>
                                <td><%= content.get("formatted_date") %></td>
                                <td class="action-icons">
                                    <a href="#" onclick="showEditForm(<%= contentId %>)" class="action-icon edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="manageContent.jsp?action=delete&id=<%= contentId %>" class="action-icon delete" 
                                       onclick="return confirm('Are you sure you want to delete this content?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <tr id="edit-form-<%= contentId %>" style="display: none;">
                                <td colspan="8">
                                    <div class="edit-form">
                                        <form method="post" action="manageContent.jsp">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= contentId %>">
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Title *</label>
                                                    <input type="text" name="title" class="form-control" value="<%= content.get("title") != null ? content.get("title") : "" %>" required>
                                                </div>
                                                <div class="form-group">
                                                    <label>Content Type</label>
                                                    <select name="type" class="form-control">
                                                        <option value="video" <%= "video".equals(contentType) ? "selected" : "" %>>Video</option>
                                                        <option value="article" <%= "article".equals(contentType) ? "selected" : "" %>>Article</option>
                                                        <option value="infographic" <%= "infographic".equals(contentType) ? "selected" : "" %>>Infographic / Image</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Level</label>
                                                    <select name="level" class="form-control">
                                                        <option value="">-- All Levels --</option>
                                                        <option value="beginner" <%= "beginner".equals(content.get("level")) ? "selected" : "" %>>Beginner</option>
                                                        <option value="intermediate" <%= "intermediate".equals(content.get("level")) ? "selected" : "" %>>Intermediate</option>
                                                        <option value="hard" <%= "hard".equals(content.get("level")) ? "selected" : "" %>>Hard</option>
                                                    </select>
                                                </div>
                                                <div class="form-group">
                                                    <label>Topic</label>
                                                    <input type="text" name="topic" class="form-control" value="<%= content.get("topic") != null ? content.get("topic") : "" %>">
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Duration</label>
                                                    <input type="text" name="duration" class="form-control" value="<%= content.get("duration") != null ? content.get("duration") : "" %>">
                                                </div>
                                                <div class="form-group">
                                                    <label>Source</label>
                                                    <input type="text" name="source" class="form-control" value="<%= content.get("source") != null ? content.get("source") : "" %>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label>Description</label>
                                                <textarea name="description" class="form-control" rows="2"><%= content.get("description") != null ? content.get("description") : "" %></textarea>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>URL</label>
                                                    <input type="url" name="url" class="form-control" value="<%= content.get("url") != null ? content.get("url") : "" %>">
                                                </div>
                                                <div class="form-group">
                                                    <label>Thumbnail URL</label>
                                                    <input type="url" name="thumbnail_url" class="form-control" value="<%= content.get("thumbnail_url") != null ? content.get("thumbnail_url") : "" %>">
                                                </div>
                                            </div>
                                            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                                                <button type="button" class="btn btn-secondary btn-sm" onclick="hideEditForm(<%= contentId %>)">
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
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        function showEditForm(contentId) {
            const editForm = document.getElementById('edit-form-' + contentId);
            if (editForm.style.display === 'none') {
                editForm.style.display = 'table-row';
            } else {
                editForm.style.display = 'none';
            }
        }
        
        function hideEditForm(contentId) {
            document.getElementById('edit-form-' + contentId).style.display = 'none';
        }
    </script>
</body>
</html>