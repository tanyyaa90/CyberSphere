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
    
    // Database connection
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
    <title>Learning Content | CyberSphere Admin</title>
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
            background: #0f1115;
            padding: 20px 30px;
            border-radius: 16px;
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
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #0f1115 0%, #0a0c10 100%);
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 24px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #44634d, #5a7f66);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            border-color: #44634d;
            box-shadow: 0 10px 30px rgba(68, 99, 77, 0.2);
        }
        
        .stat-card:hover::before {
            transform: scaleX(1);
        }
        
        .stat-card h3 {
            color: #9ca3af;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        
        .stat-card .number {
            color: #ffffff;
            font-size: 32px;
            font-weight: 700;
            display: flex;
            align-items: baseline;
            gap: 5px;
        }
        
        .stat-card .number i {
            color: #44634d;
            font-size: 24px;
            margin-right: 8px;
        }
        
        /* Filter Bar */
        .filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            flex-wrap: wrap;
            background: #0f1115;
            padding: 15px;
            border-radius: 50px;
            border: 1px solid #1e1e1e;
        }
        
        .filter-btn {
            background: transparent;
            border: 1px solid #2a2f3a;
            padding: 10px 24px;
            border-radius: 40px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s ease;
            color: #9ca3af;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
        }
        
        .filter-btn i {
            font-size: 14px;
        }
        
        .filter-btn:hover {
            background: #1a1e24;
            color: #ffffff;
            transform: translateY(-2px);
            border-color: #44634d;
        }
        
        .filter-btn.active {
            background: #44634d;
            color: white;
            border-color: #44634d;
            box-shadow: 0 5px 15px rgba(68, 99, 77, 0.3);
        }
        
        /* Add Content Button */
        .add-content-btn {
            background: linear-gradient(135deg, #44634d 0%, #36523d 100%);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 30px;
            font-size: 15px;
            box-shadow: 0 5px 15px rgba(68, 99, 77, 0.2);
        }
        
        .add-content-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(68, 99, 77, 0.3);
        }
        
        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 30px;
            margin-top: 20px;
        }
        
        .content-card {
            background: #0f1115;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #1e1e1e;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        .content-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(180deg, transparent 0%, rgba(0,0,0,0.5) 100%);
            opacity: 0;
            transition: opacity 0.3s ease;
            pointer-events: none;
            border-radius: 20px;
        }
        
        .content-card:hover {
            transform: translateY(-8px);
            border-color: #44634d;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
        }
        
        .content-card:hover::before {
            opacity: 1;
        }
        
        .card-thumbnail {
            position: relative;
            width: 100%;
            height: 200px;
            overflow: hidden;
            background: linear-gradient(135deg, #1a1e24 0%, #0f1115 100%);
        }
        
        .card-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }
        
        .content-card:hover .card-thumbnail img {
            transform: scale(1.1);
        }
        
        .type-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 6px 14px;
            border-radius: 30px;
            font-size: 0.75em;
            font-weight: 600;
            color: white;
            text-transform: uppercase;
            z-index: 1;
            backdrop-filter: blur(5px);
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .type-badge.video { 
            background: rgba(44, 21, 21, 0.95);
            color: #f87171;
            border: 1px solid #f87171;
        }
        .type-badge.article { 
            background: rgba(26, 46, 26, 0.95);
            color: #86efac;
            border: 1px solid #86efac;
        }
        .type-badge.image { 
            background: rgba(44, 36, 21, 0.95);
            color: #fbbf24;
            border: 1px solid #fbbf24;
        }
        
        .card-content {
            padding: 20px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #0f1115;
        }
        
        .card-title {
            color: #ffffff;
            font-size: 1.15em;
            font-weight: 600;
            margin-bottom: 12px;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .card-description {
            color: #9ca3af;
            font-size: 0.85em;
            line-height: 1.5;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .card-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 15px;
            border-top: 1px solid #1e1e1e;
        }
        
        .topic-tag {
            background: #1a1e24;
            color: #9ca3af;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75em;
            font-weight: 500;
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            border: 1px solid #2a2f3a;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
        }
        
        .topic-tag:hover {
            border-color: #44634d;
            color: #ffffff;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .view-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: #1a1e24;
            color: #ffffff;
            text-decoration: none;
            border-radius: 10px;
            font-size: 0.85em;
            font-weight: 500;
            transition: all 0.2s ease;
            border: 1px solid #2a2f3a;
            cursor: pointer;
        }
        
        .view-btn:hover {
            background: #44634d;
            border-color: #44634d;
            transform: translateX(3px);
        }
        
        .delete-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: rgba(220, 38, 38, 0.1);
            color: #f87171;
            text-decoration: none;
            border-radius: 10px;
            font-size: 0.85em;
            font-weight: 500;
            transition: all 0.2s ease;
            border: 1px solid rgba(220, 38, 38, 0.3);
            cursor: pointer;
        }
        
        .delete-btn:hover {
            background: #dc2626;
            color: white;
            border-color: #dc2626;
            transform: translateX(3px);
        }
        
        /* Video Modal */
        #videoModal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.98);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(10px);
        }

        #videoModal > div {
            position: relative;
            width: 90%;
            max-width: 1000px;
            animation: modalSlideIn 0.3s ease;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        #videoModal button {
            position: absolute;
            top: -50px;
            right: 0;
            background: rgba(26, 30, 36, 0.95);
            border: 1px solid #2a2f3a;
            color: #9ca3af;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            font-size: 24px;
            cursor: pointer;
            z-index: 1001;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #videoModal button:hover {
            background: #dc2626;
            color: white;
            border-color: #dc2626;
            transform: rotate(90deg);
        }

        .video-container {
            position: relative;
            width: 100%;
            height: 0;
            padding-bottom: 56.25%;
            overflow: hidden;
            border-radius: 16px;
            background: #000;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
        }

        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: 0;
        }
        
        /* Empty State */
        .empty-state {
            grid-column: 1/-1;
            text-align: center;
            padding: 80px 40px;
            background: linear-gradient(135deg, #0f1115 0%, #0a0c10 100%);
            border-radius: 24px;
            border: 1px solid #1e1e1e;
        }
        
        .empty-state i {
            font-size: 80px;
            color: #44634d;
            opacity: 0.5;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            color: #ffffff;
            margin-bottom: 10px;
            font-size: 24px;
        }
        
        .empty-state p {
            color: #9ca3af;
            font-size: 16px;
        }
        
        /* Loading Animation */
        @keyframes shimmer {
            0% {
                background-position: -1000px 0;
            }
            100% {
                background-position: 1000px 0;
            }
        }
        
        .loading {
            background: linear-gradient(90deg, #1a1e24 25%, #2a2f3a 50%, #1a1e24 75%);
            background-size: 1000px 100%;
            animation: shimmer 2s infinite;
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
        @media (max-width: 1024px) {
            .stats-grid {
                gap: 15px;
            }
            
            .stat-card {
                padding: 20px;
            }
        }
        
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
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 12px;
            }
            
            .filter-bar {
                border-radius: 20px;
                justify-content: center;
                padding: 12px;
                gap: 10px;
            }
            
            .filter-btn {
                padding: 8px 16px;
                font-size: 13px;
            }
            
            .add-content-btn {
                width: 100%;
                justify-content: center;
                margin-bottom: 20px;
            }
            
            .content-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .stat-card .number {
                font-size: 28px;
            }
            
            .empty-state {
                padding: 60px 20px;
            }
            
            .empty-state i {
                font-size: 60px;
            }
            
            .empty-state h3 {
                font-size: 20px;
            }
        }
        
        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-bar {
                flex-direction: column;
                border-radius: 16px;
            }
            
            .filter-btn {
                width: 100%;
                justify-content: center;
            }
            
            .action-buttons {
                flex-direction: column;
                width: 100%;
            }
            
            .view-btn, .delete-btn {
                width: 100%;
                justify-content: center;
            }
        }
        
        /* Tooltip */
        [data-tooltip] {
            position: relative;
            cursor: pointer;
        }
        
        [data-tooltip]:before {
            content: attr(data-tooltip);
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            padding: 5px 10px;
            background: #1a1e24;
            color: #ffffff;
            font-size: 12px;
            white-space: nowrap;
            border-radius: 6px;
            display: none;
            z-index: 10;
            border: 1px solid #44634d;
        }
        
        [data-tooltip]:hover:before {
            display: block;
        }
    </style>
</head>
<body>
    <!-- Main Content (No Sidebar) -->
    <div class="main-content">
        <div class="header">
            <h1>
                <i class="fas fa-graduation-cap"></i>
                Learning Content Management
            </h1>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
                <i class="fas fa-chevron-down" style="font-size: 12px; color: #9ca3af;"></i>
            </div>
        </div>
        
        <!-- Stats Cards -->
        <%
            int totalVideos = 0;
            int totalArticles = 0;
            int totalImages = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUser, dbPass);
                stmt = conn.createStatement();
                
                rs = stmt.executeQuery("SELECT COUNT(*) as count FROM learning_content WHERE type = 'video'");
                if (rs.next()) totalVideos = rs.getInt("count");
                rs.close();
                
                rs = stmt.executeQuery("SELECT COUNT(*) as count FROM learning_content WHERE type = 'article'");
                if (rs.next()) totalArticles = rs.getInt("count");
                rs.close();
                
                rs = stmt.executeQuery("SELECT COUNT(*) as count FROM learning_content WHERE type = 'image'");
                if (rs.next()) totalImages = rs.getInt("count");
                rs.close();
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <h3><i class="fas fa-video"></i> Videos</h3>
                <div class="number">
                    <i class="fas fa-play-circle"></i>
                    <%= totalVideos %>
                </div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-newspaper"></i> Articles</h3>
                <div class="number">
                    <i class="fas fa-file-alt"></i>
                    <%= totalArticles %>
                </div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-image"></i> Images</h3>
                <div class="number">
                    <i class="fas fa-images"></i>
                    <%= totalImages %>
                </div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-database"></i> Total Content</h3>
                <div class="number">
                    <i class="fas fa-layer-group"></i>
                    <%= totalVideos + totalArticles + totalImages %>
                </div>
            </div>
        </div>
        
        <!-- Filter Bar -->
        <div class="filter-bar">
    <button class="filter-btn active" onclick="filterByType('all', event)">
        <i class="fas fa-globe"></i> All Content
    </button>
    <button class="filter-btn" onclick="filterByType('video', event)">
        <i class="fas fa-video"></i> Videos
        <span style="background: #2c1515; padding: 2px 8px; border-radius: 20px; font-size: 11px;"><%= totalVideos %></span>
    </button>
    <button class="filter-btn" onclick="filterByType('article', event)">
        <i class="fas fa-newspaper"></i> Articles
        <span style="background: #1a2e1a; padding: 2px 8px; border-radius: 20px; font-size: 11px;"><%= totalArticles %></span>
    </button>
    <button class="filter-btn" onclick="filterByType('image', event)">
        <i class="fas fa-image"></i> Images
        <span style="background: #2c2415; padding: 2px 8px; border-radius: 20px; font-size: 11px;"><%= totalImages %></span>
    </button>
</div>
        
        <!-- Add Content Button -->
        <button class="add-content-btn" onclick="window.location.href='addContent.jsp'">
            <i class="fas fa-plus-circle"></i> Create New Content
        </button>
        
        <!-- Content Grid -->
        <div class="content-grid" id="contentGrid">
            <%
                try {
                    conn = DriverManager.getConnection(url, dbUser, dbPass);
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT * FROM learning_content ORDER BY id DESC");
                    
                    boolean hasContent = false;
                    while (rs.next()) {
                        hasContent = true;
                        int id = rs.getInt("id");
                        String type = rs.getString("type");
                        String topic = rs.getString("topic");
                        String level = rs.getString("level");
                        String contentUrl = rs.getString("url");
                        String thumbnailUrl = rs.getString("thumbnail_url");
                        String title = rs.getString("title");
                        String description = rs.getString("description");
                        
                        // If title is null, create one from topic and type
                        if (title == null || title.isEmpty()) {
                            if ("video".equals(type)) {
                                title = topic + " - Video Tutorial";
                            } else if ("article".equals(type)) {
                                title = topic + " - Article";
                            } else if ("image".equals(type)) {
                                title = topic + " - Infographic";
                            }
                        }
                        
                     // Generate thumbnail if not available
                        if (thumbnailUrl == null || thumbnailUrl.isEmpty()) {
                            if ("video".equals(type)) {
                                String videoId = "";
                                if (contentUrl != null) {
                                    if (contentUrl.contains("youtube.com/embed/")) {
                                        videoId = contentUrl.substring(contentUrl.lastIndexOf("/") + 1);
                                        // Strip any query params after video ID
                                        if (videoId.contains("?")) videoId = videoId.substring(0, videoId.indexOf("?"));
                                        
                                    } else if (contentUrl.contains("youtube.com/watch?v=")) {
                                        videoId = contentUrl.substring(contentUrl.indexOf("v=") + 2);
                                        // Strip additional params
                                        if (videoId.contains("&")) videoId = videoId.substring(0, videoId.indexOf("&"));
                                        
                                    } else if (contentUrl.contains("youtu.be/")) {
                                        videoId = contentUrl.substring(contentUrl.lastIndexOf("/") + 1);
                                        // Strip any query params
                                        if (videoId.contains("?")) videoId = videoId.substring(0, videoId.indexOf("?"));
                                    }
                                }
                                
                                if (!videoId.isEmpty()) {
                                    // hqdefault always exists, maxresdefault sometimes doesn't
                                    thumbnailUrl = "https://img.youtube.com/vi/" + videoId + "/hqdefault.jpg";
                                } else {
                                    thumbnailUrl = "https://via.placeholder.com/400x225/1a1e24/44634d?text=Video";
                                }
                                
                            } else if ("article".equals(type)) {
                                String topicText = topic != null ? topic : "Article";
                                thumbnailUrl = "https://via.placeholder.com/400x225/1a1e24/44634d?text=" + topicText.replace(" ", "+");
                            } else if ("image".equals(type)) {
                                thumbnailUrl = contentUrl;
                            }
                        }
            %>
            <div class="content-card" data-type="<%= type %>">
                <div class="card-thumbnail">
                    <span class="type-badge <%= type %>">
                        <i class="fas fa-<%= "video".equals(type) ? "video" : "article".equals(type) ? "newspaper" : "image" %>"></i> 
                        <%= type.toUpperCase() %>
                    </span>
                    <img src="<%= thumbnailUrl %>" alt="<%= title %>" loading="lazy"
                         onerror="this.src='https://via.placeholder.com/400x225/1a1e24/44634d?text=No+Thumbnail'">
                </div>
                
                <div class="card-content">
                    <h3 class="card-title"><%= title %></h3>
                    <% if (description != null && !description.isEmpty()) { %>
                        <p class="card-description"><%= description.length() > 100 ? description.substring(0, 100) + "..." : description %></p>
                    <% } %>
                    
                    <div class="card-meta">
                        <span class="topic-tag" title="<%= topic != null ? topic : "Uncategorized" %>">
                            <i class="fas fa-tag"></i> 
                            <%= topic != null && topic.length() > 20 ? topic.substring(0, 20) + "..." : (topic != null ? topic : "Uncategorized") %>
                        </span>
                        
                        <div class="action-buttons">
                            <%
                                if ("video".equals(type)) {
                            %>
                                <button class="view-btn" onclick="openVideoModal('<%= contentUrl %>')" data-tooltip="Watch Video">
                                    <i class="fas fa-play"></i> Watch
                                </button>
                            <%
                                } else if ("article".equals(type)) {
                            %>
                                <a href="<%= contentUrl %>" class="view-btn" target="_blank" rel="noopener noreferrer" data-tooltip="Read Article">
                                    <i class="fas fa-external-link-alt"></i> Read
                                </a>
                            <%
                                } else {
                            %>
                                <a href="<%= contentUrl %>" class="view-btn" target="_blank" rel="noopener noreferrer" data-tooltip="View Image">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            <%
                                }
                            %>
                            <button class="delete-btn" onclick="deleteContent(<%= id %>)" data-tooltip="Delete Content">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                    
                    if (!hasContent) {
            %>
            <div class="empty-state">
                <i class="fas fa-folder-open"></i>
                <h3>No Content Found</h3>
                <p>Get started by adding your first learning resource</p>
                <button class="add-content-btn" onclick="window.location.href='addContent.jsp'" style="margin-top: 20px;">
                    <i class="fas fa-plus-circle"></i> Add Your First Content
                </button>
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
        </div>
    </div>
    
    <!-- Video Modal -->
    <div id="videoModal">
        <div>
            <button onclick="closeVideoModal()">&times;</button>
            <div id="videoContainer" class="video-container"></div>
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
    
    async function submitForm() {
        console.log("Submit button clicked - Starting form submission");
        
        // Validate form
        const type = document.getElementById('contentType').value;
        const title = document.getElementById('title').value.trim();
        const topic = document.getElementById('topic').value;
        const url = document.getElementById('url').value.trim();
        
        console.log("Form data:", { type, title, topic, url });
        
        if (!type) {
            showMessage('Please select a content type', 'error');
            return false;
        }
        
        if (!title) {
            showMessage('Please enter a title', 'error');
            return false;
        }
        
        if (!topic) {
            showMessage('Please select a topic', 'error');
            return false;
        }
        
        if (!url) {
            showMessage('Please enter a URL', 'error');
            return false;
        }
        
        // Basic URL validation
        try {
            new URL(url);
        } catch (e) {
            showMessage('Please enter a valid URL (include http:// or https://)', 'error');
            return false;
        }
        
        // Get form data
        const form = document.getElementById('contentForm');
        const formData = new FormData(form);
        
        // Log form data for debugging
        console.log("FormData entries:");
        for (let pair of formData.entries()) {
            console.log(pair[0] + ': ' + pair[1]);
        }
        
        // Disable submit button and show loading
        const submitBtn = document.getElementById('submitBtn');
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="loading-spinner"></span> Adding Content...';
        
        try {
            console.log("Sending request to ContentServlet...");
            
            const response = await fetch('../ContentServlet', {
                method: 'POST',
                body: formData
            });
            
            console.log("Response status:", response.status);
            console.log("Response headers:", response.headers);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const responseText = await response.text();
            console.log("Raw response:", responseText);
            
            let result;
            try {
                result = JSON.parse(responseText);
            } catch (e) {
                console.error("Failed to parse JSON:", responseText);
                throw new Error("Server returned invalid response: " + responseText);
            }
            
            console.log("Parsed response:", result);
            
            if (result.success) {
                showMessage('Content added successfully!', 'success');
                // Reset the form
                form.reset();
                document.getElementById('contentType').value = '';
                toggleFields();
            } else {
                showMessage(result.message || 'Failed to add content. Please try again.', 'error');
            }
        } catch (error) {
            console.error('Error details:', error);
            showMessage('An error occurred: ' + error.message, 'error');
        } finally {
            // Re-enable submit button
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
    
    function filterByType(type, event) {
        document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
        event.currentTarget.classList.add('active');

        const cards = document.querySelectorAll('.content-card');
        cards.forEach(card => {
            if (type === 'all' || card.dataset.type === type) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    }
    
    function openVideoModal(videoUrl) {
        // Convert watch URL to embed URL if needed
        let embedUrl = videoUrl;
        if (videoUrl.includes('youtube.com/watch?v=')) {
            const videoId = videoUrl.split('v=')[1].split('&')[0];
            embedUrl = 'https://www.youtube.com/embed/' + videoId;
        } else if (videoUrl.includes('youtu.be/')) {
            const videoId = videoUrl.split('youtu.be/')[1].split('?')[0];
            embedUrl = 'https://www.youtube.com/embed/' + videoId;
        }

        const modal = document.getElementById('videoModal');
        const container = document.getElementById('videoContainer');
        container.innerHTML = `<iframe src="${embedUrl}?autoplay=1" allowfullscreen allow="autoplay"></iframe>`;
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeVideoModal() {
        const modal = document.getElementById('videoModal');
        const container = document.getElementById('videoContainer');
        modal.style.display = 'none';
        container.innerHTML = ''; // Stop video playback
        document.body.style.overflow = '';
    }

    // Close modal on backdrop click
    document.getElementById('videoModal').addEventListener('click', function(e) {
        if (e.target === this) closeVideoModal();
    });
    
    async function deleteContent(id) {
        if (!confirm('Are you sure you want to delete this content?')) return;

        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', id);

        try {
            const response = await fetch('../ContentServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            });

            const result = await response.json();
            if (result.success) {
                // Remove card from DOM without page reload
                const card = document.querySelector(`.delete-btn[onclick="deleteContent(${id})"]`)
                                      .closest('.content-card');
                card.style.transition = 'all 0.3s ease';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.8)';
                setTimeout(() => card.remove(), 300);
            } else {
                alert('Failed to delete: ' + result.message);
            }
        } catch (error) {
            alert('Error deleting content: ' + error.message);
        }
    }
    
</script>
</body>
</html>