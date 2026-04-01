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
    
    // Database connection for topics
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Content | CyberSphere Admin</title>
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
            min-height: 100vh;
            position: relative;
        }
        
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.05"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-repeat: repeat;
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }
        
        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: linear-gradient(135deg, #0f1115 0%, #0a0c10 100%);
            padding: 20px 30px;
            border-radius: 20px;
            border: 1px solid #1e1e1e;
            backdrop-filter: blur(10px);
            position: relative;
            z-index: 1;
        }
        
        .header h1 {
            font-size: 28px;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .header h1 i {
            color: #44634d;
            font-size: 32px;
        }
        
        .admin-profile {
            display: flex;
            align-items: center;
            gap: 15px;
            background: #1a1e24;
            padding: 8px 20px;
            border-radius: 40px;
            border: 1px solid #2a2f3a;
            transition: all 0.2s ease;
        }
        
        .admin-profile:hover {
            border-color: #44634d;
            transform: translateY(-2px);
        }
        
        .admin-profile img {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: 2px solid #44634d;
            object-fit: cover;
        }
        
        /* Main content wrapper */
        .main-content {
            max-width: 1000px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }
        
        /* Form Container */
        .form-container {
            background: linear-gradient(135deg, #0f1115 0%, #0a0c10 100%);
            border: 1px solid #1e1e1e;
            border-radius: 24px;
            padding: 35px;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .form-container:hover {
            border-color: #44634d;
            box-shadow: 0 10px 30px rgba(68, 99, 77, 0.1);
        }
        
        .form-title {
            color: #ffffff;
            font-size: 24px;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #44634d;
            display: inline-block;
        }
        
        .form-title i {
            color: #44634d;
            margin-right: 10px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            color: #9ca3af;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }
        
        .form-group label i {
            color: #44634d;
            margin-right: 8px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 16px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            color: #ffffff;
            font-size: 14px;
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.2);
        }
        
        .form-control option {
            background: #1a1e24;
            color: #ffffff;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .help-text {
            color: #6b7280;
            font-size: 12px;
            margin-top: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .help-text i {
            color: #44634d;
        }
        
        /* URL Examples */
        .url-examples {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 15px;
            margin: 15px 0;
            transition: all 0.2s ease;
        }
        
        .url-examples:hover {
            border-color: #44634d;
        }
        
        .url-examples p {
            color: #9ca3af;
            font-size: 13px;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .url-examples ul {
            list-style: none;
            padding-left: 0;
        }
        
        .url-examples li {
            color: #6b7280;
            font-size: 12px;
            margin: 5px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .url-examples li i {
            color: #44634d;
            width: 16px;
        }
        
        /* Buttons */
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            justify-content: flex-end;
        }
        
        .btn {
            padding: 12px 28px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #44634d 0%, #36523d 100%);
            color: white;
            box-shadow: 0 5px 15px rgba(68, 99, 77, 0.2);
        }
        
        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(68, 99, 77, 0.3);
        }
        
        .btn-primary:active:not(:disabled) {
            transform: translateY(0);
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
            transform: translateY(-2px);
        }
        
        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideDown 0.3s ease;
            backdrop-filter: blur(10px);
        }
        
        .alert-success {
            background: rgba(26, 46, 26, 0.95);
            color: #86efac;
            border: 1px solid #2a4a2a;
        }
        
        .alert-error {
            background: rgba(44, 21, 21, 0.95);
            color: #f87171;
            border: 1px solid #3f1f1f;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        /* Loading Spinner */
        .loading-spinner {
            display: inline-block;
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 0.6s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .btn-primary:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }
        
        /* Auto-hide message */
        .alert-success.hide-message {
            animation: fadeOut 0.5s ease forwards;
        }
        
        @keyframes fadeOut {
            to {
                opacity: 0;
                visibility: hidden;
            }
        }
        
        /* Required field indicator */
        .required:after {
            content: " *";
            color: #f87171;
        }
        
        /* Scrollbar Styling */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }
        
        ::-webkit-scrollbar-track {
            background: #0f1115;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #44634d;
            border-radius: 5px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #5a7f66;
        }
        
        /* Selection Color */
        ::selection {
            background: #44634d;
            color: #ffffff;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding: 15px;
            }
            
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
                padding: 20px;
            }
            
            .admin-profile {
                width: 100%;
                justify-content: center;
            }
            
            .form-container {
                padding: 25px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
            
            .form-title {
                font-size: 20px;
            }
        }
        
        @media (max-width: 480px) {
            .form-container {
                padding: 20px;
            }
            
            .url-examples {
                padding: 12px;
            }
            
            .url-examples li {
                font-size: 11px;
            }
        }
    </style>
</head>
<body>
    <!-- Main Content (No Sidebar) -->
    <div class="main-content">
        <div class="header">
            <h1>
                <i class="fas fa-plus-circle"></i>
                Add New Content
            </h1>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
                <i class="fas fa-chevron-down" style="font-size: 12px; color: #9ca3af;"></i>
            </div>
        </div>
        
        <!-- Success/Error Messages Container -->
        <div id="messageContainer"></div>
        
        <!-- Add Content Form -->
        <!-- Add Content Form -->
<div class="form-container">
    <h2 class="form-title"><i class="fas fa-newspaper"></i> Content Details</h2>
    
    <form id="contentForm">
        <!-- Make sure this input is present and has the correct name -->
        <input type="hidden" name="action" value="add">
        <input type="hidden" name="createdBy" value="<%= session.getAttribute("userId") %>">
        
        <!-- Content Type -->
        <div class="form-group">
            <label class="required"><i class="fas fa-tag"></i> Content Type</label>
            <select class="form-control" name="type" id="contentType" required onchange="toggleFields()">
                <option value="">Select Type</option>
                <option value="video">Video</option>
                <option value="article">Article</option>
                <option value="image">Image</option>
            </select>
        </div>
        
        <!-- Title -->
        <div class="form-group">
            <label class="required"><i class="fas fa-heading"></i> Title</label>
            <input type="text" class="form-control" name="title" id="title" required 
                   placeholder="e.g., Phishing Attacks Explained">
        </div>
        
        <!-- Topic -->
        <div class="form-group">
            <label class="required"><i class="fas fa-folder"></i> Topic</label>
            <select class="form-control" name="topic" id="topic" required>
                <option value="">Select Topic</option>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, dbUser, dbPass);
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT name FROM topics ORDER BY name");
                        while (rs.next()) {
                %>
                <option value="<%= rs.getString("name") %>"><%= rs.getString("name") %></option>
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
            </select>
        </div>
        
        <!-- Level -->
        <div class="form-group">
            <label><i class="fas fa-chart-line"></i> Difficulty Level</label>
            <select class="form-control" name="level">
                <option value="">All Levels</option>
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="hard">Hard</option>
            </select>
        </div>
        
        <!-- URL - Dynamic based on type -->
        <div class="form-group" id="urlGroup">
            <label class="required"><i class="fas fa-link"></i> <span id="urlLabel">URL</span></label>
            <input type="url" class="form-control" name="url" id="url" required 
                   placeholder="">
            <div class="help-text" id="urlHelp">
                <i class="fas fa-info-circle"></i>
                <span id="helpText">Enter the URL for your content</span>
            </div>
        </div>
        
        <!-- URL Examples (hidden by default) -->
        <div class="url-examples" id="videoExamples" style="display: none;">
            <p><i class="fas fa-video" style="color: #f87171;"></i> <strong>Video URL Examples:</strong></p>
            <ul>
                <li><i class="fas fa-check-circle"></i> https://www.youtube.com/embed/VIDEO_ID</li>
                <li><i class="fas fa-check-circle"></i> https://youtu.be/VIDEO_ID</li>
                <li><i class="fas fa-check-circle"></i> https://www.youtube.com/watch?v=VIDEO_ID</li>
            </ul>
            <p style="color: #f87171; font-size: 12px; margin-top: 8px;">
                <i class="fas fa-lightbulb"></i> For best results, use embed links: https://www.youtube.com/embed/VIDEO_ID
            </p>
        </div>
        
        <div class="url-examples" id="articleExamples" style="display: none;">
            <p><i class="fas fa-newspaper" style="color: #86efac;"></i> <strong>Article URL Examples:</strong></p>
            <ul>
                <li><i class="fas fa-check-circle"></i> https://example.com/article</li>
                <li><i class="fas fa-check-circle"></i> https://www.website.com/blog/post</li>
            </ul>
        </div>
        
        <div class="url-examples" id="imageExamples" style="display: none;">
            <p><i class="fas fa-image" style="color: #fbbf24;"></i> <strong>Image URL Examples:</strong></p>
            <ul>
                <li><i class="fas fa-check-circle"></i> https://example.com/image.jpg</li>
                <li><i class="fas fa-check-circle"></i> https://www.website.com/photo.png</li>
            </ul>
        </div>
        
        <!-- Thumbnail URL (Optional) -->
        <div class="form-group">
            <label><i class="fas fa-image"></i> Thumbnail URL</label>
            <input type="url" class="form-control" name="thumbnail" id="thumbnail" 
                   placeholder="Leave empty for auto-generated thumbnail">
            <div class="help-text">
                <i class="fas fa-info-circle"></i>
                <span>If left empty, thumbnail will be auto-generated based on content type</span>
            </div>
        </div>
        
        <!-- Description -->
        <div class="form-group">
            <label><i class="fas fa-align-left"></i> Description</label>
            <textarea class="form-control" name="description" rows="4" 
                      placeholder="Brief description of the content (optional)"></textarea>
        </div>
        
        <!-- Source (Optional) -->
        <div class="form-row">
            <div class="form-group">
                <label><i class="fas fa-globe"></i> Source</label>
                <input type="text" class="form-control" name="source" 
                       placeholder="e.g., YouTube, Wikipedia, etc.">
            </div>
            
            <div class="form-group" id="durationGroup">
                <label><i class="fas fa-clock"></i> Duration</label>
                <input type="text" class="form-control" name="duration" 
                       placeholder="e.g., 10:30 for videos">
            </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="content.jsp" class="btn btn-secondary">
                <i class="fas fa-times"></i> Cancel
            </a>
            <button type="button" class="btn btn-primary" id="submitBtn" onclick="submitForm(event)">
    <i class="fas fa-save"></i> Add Content
</button>
        </div>
    </form>
</div>
    </div>
    
    <script>
        function showMessage(message, type) {
            const messageContainer = document.getElementById('messageContainer');
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-${type}`;
            const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
            alertDiv.innerHTML = `<i class="fas ${icon}"></i> ${message}`;
            messageContainer.innerHTML = '';
            messageContainer.appendChild(alertDiv);
            
            // Auto-hide success message after 3 seconds
            if (type === 'success') {
                setTimeout(() => {
                    alertDiv.classList.add('hide-message');
                    setTimeout(() => {
                        if (alertDiv.parentNode) {
                            alertDiv.remove();
                        }
                    }, 500);
                }, 3000);
            }
        }
        
        let isSubmitting = false; // Guard flag at top level

        async function submitForm(event) {
            // Prevent any double-firing
            if (event) {
                event.preventDefault();
                event.stopPropagation();
                event.stopImmediatePropagation();
            }
            
            // Guard against multiple simultaneous submissions
            if (isSubmitting) {
                console.log("Already submitting, ignoring duplicate call");
                return false;
            }
            
            // Validate form
            const type = document.getElementById('contentType').value;
            const title = document.getElementById('title').value.trim();
            const topic = document.getElementById('topic').value;
            const url = document.getElementById('url').value.trim();
            
            if (!type) { showMessage('Please select a content type', 'error'); return false; }
            if (!title) { showMessage('Please enter a title', 'error'); return false; }
            if (!topic) { showMessage('Please select a topic', 'error'); return false; }
            if (!url) { showMessage('Please enter a URL', 'error'); return false; }
            
            try {
                new URL(url);
            } catch (e) {
                showMessage('Please enter a valid URL (include http:// or https://)', 'error');
                return false;
            }
            
            // Set submitting flag
            isSubmitting = true;
            
            const submitBtn = document.getElementById('submitBtn');
            const originalBtnText = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="loading-spinner"></span> Adding Content...';
            
            try {
                const params = new URLSearchParams();
                params.append('action', 'add');
                params.append('type', type);
                params.append('title', title);
                params.append('topic', topic);
                params.append('url', url);
                params.append('createdBy', document.querySelector('[name="createdBy"]').value);
                params.append('level', document.querySelector('[name="level"]').value || '');
                params.append('thumbnail', document.querySelector('[name="thumbnail"]').value || '');
                params.append('description', document.querySelector('[name="description"]').value || '');
                params.append('source', document.querySelector('[name="source"]').value || '');
                params.append('duration', document.querySelector('[name="duration"]')?.value || '');
                
                const response = await fetch('../ContentServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: params
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showMessage('Content added successfully!', 'success');
                    document.getElementById('contentForm').reset();
                    toggleFields();
                    // Hide all URL examples after reset
                    document.getElementById('videoExamples').style.display = 'none';
                    document.getElementById('articleExamples').style.display = 'none';
                    document.getElementById('imageExamples').style.display = 'none';
                } else {
                    showMessage(result.message || 'Failed to add content.', 'error');
                }
                
            } catch (error) {
                console.error('Error:', error);
                showMessage('An error occurred: ' + error.message, 'error');
            } finally {
                // Always reset state
                isSubmitting = false;
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalBtnText;
            }
            
            return false;
        }
        
        function toggleFields() {
            const type = document.getElementById('contentType').value;
            const urlLabel = document.getElementById('urlLabel');
            const helpText = document.getElementById('helpText');
            const urlInput = document.getElementById('url');
            const durationGroup = document.getElementById('durationGroup');
            
            // Hide all examples first
            const videoExamples = document.getElementById('videoExamples');
            const articleExamples = document.getElementById('articleExamples');
            const imageExamples = document.getElementById('imageExamples');
            
            if (videoExamples) videoExamples.style.display = 'none';
            if (articleExamples) articleExamples.style.display = 'none';
            if (imageExamples) imageExamples.style.display = 'none';
            
            // Show/hide duration field
            if (durationGroup) {
                durationGroup.style.display = (type === 'video') ? 'block' : 'none';
            }
            
            // Update based on type
            if (type === 'video') {
                urlLabel.innerHTML = 'Video URL';
                helpText.innerHTML = 'Enter YouTube video URL (embed, watch, or youtu.be link)';
                urlInput.placeholder = 'https://www.youtube.com/embed/VIDEO_ID';
                if (videoExamples) videoExamples.style.display = 'block';
                
            } else if (type === 'article') {
                urlLabel.innerHTML = 'Article URL';
                helpText.innerHTML = 'Enter the URL of the article';
                urlInput.placeholder = 'https://example.com/article';
                if (articleExamples) articleExamples.style.display = 'block';
                
            } else if (type === 'image') {
                urlLabel.innerHTML = 'Image URL';
                helpText.innerHTML = 'Enter direct link to the image';
                urlInput.placeholder = 'https://example.com/image.jpg';
                if (imageExamples) imageExamples.style.display = 'block';
            }
        }
    </script>
</body>
</html>