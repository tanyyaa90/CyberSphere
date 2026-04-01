<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="model.ContentLearning" %>

<%@ include file="header.jsp" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Map<String, List<ContentLearning>> groupedContent =
        (Map<String, List<ContentLearning>>) request.getAttribute("groupedContent");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Hub | CyberSphere</title>
    <meta http-equiv="Content-Security-Policy" content="frame-src https://www.youtube.com https://www.youtube-nocookie.com;">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: #0a0c10;
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%2344634d" stroke-width="1" opacity="0.04"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><circle cx="12" cy="12" r="3"/></svg>');
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        .page-layout {
            display: flex;
            min-height: calc(100vh - 80px);
            position: relative;
            z-index: 1;
        }

        .sidebar {
            width: 270px;
            flex-shrink: 0;
            background: #0f1115;
            border-right: 1px solid #1e2228;
            padding: 28px 0;
            position: sticky;
            top: 0;
            height: 100vh;
            overflow-y: auto;
        }

        .sidebar::-webkit-scrollbar { width: 4px; }
        .sidebar::-webkit-scrollbar-track { background: transparent; }
        .sidebar::-webkit-scrollbar-thumb { background: #2a2f3a; border-radius: 2px; }

        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid #1e2228;
            margin-bottom: 16px;
        }

        .sidebar-header h2 {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .1em;
            color: #44634d;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .sidebar-filters {
            padding: 0 12px 16px;
            border-bottom: 1px solid #1e2228;
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .filter-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 14px;
            border-radius: 10px;
            border: none;
            background: transparent;
            color: #9ca3af;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all .18s;
            text-align: left;
            width: 100%;
        }
        .filter-btn i { color: #44634d; width: 16px; }
        .filter-btn:hover { background: #13171d; color: #fff; }
        .filter-btn.active { background: #162119; color: #86efac; }
        .filter-btn .count-pill {
            margin-left: auto;
            background: #1e2228;
            color: #6b7280;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 20px;
        }
        .filter-btn.active .count-pill { background: #1e4a28; color: #86efac; }

        .sidebar-section-label {
            padding: 4px 20px 8px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .08em;
            color: #4b5563;
        }

        .sidebar-nav { display: flex; flex-direction: column; gap: 2px; padding: 0 12px; }

        .sidebar-link {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 14px;
            border-radius: 10px;
            text-decoration: none;
            color: #9ca3af;
            font-size: 14px;
            font-weight: 500;
            transition: all .18s;
            cursor: pointer;
            border: none;
            background: transparent;
            text-align: left;
            width: 100%;
        }
        .sidebar-link i { color: #44634d; width: 16px; flex-shrink: 0; }
        .sidebar-link:hover { background: #13171d; color: #fff; }
        .sidebar-link.active { background: #162119; color: #86efac; }
        .sidebar-link .cat-count {
            margin-left: auto;
            background: #1e2228;
            color: #6b7280;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 20px;
            flex-shrink: 0;
        }
        .sidebar-link.active .cat-count { background: #1e4a28; color: #86efac; }

        .main-content {
            flex: 1;
            padding: 32px 36px;
            overflow-y: auto;
            min-width: 0;
        }

        .page-heading {
            margin-bottom: 28px;
        }
        .page-heading h1 {
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            letter-spacing: -.02em;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 6px;
        }
        .page-heading h1 i { color: #44634d; }
        .page-heading p { color: #6b7280; font-size: 14px; }

        .stats-bar {
            display: flex;
            gap: 16px;
            margin-bottom: 32px;
            flex-wrap: wrap;
        }
        .stat-chip {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 10px;
            padding: 10px 18px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #9ca3af;
        }
        .stat-chip i { color: #44634d; }
        .stat-chip strong { color: #fff; }

        .category-section {
            background: #0f1115;
            border: 1px solid #1e2228;
            border-radius: 18px;
            padding: 28px;
            margin-bottom: 32px;
        }

        .category-title {
            color: #fff;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 22px;
            padding-bottom: 14px;
            border-bottom: 1px solid #1e2228;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
        }
        .category-title::after {
            content: '';
            position: absolute;
            bottom: -1px; left: 0;
            width: 60px; height: 2px;
            background: #44634d;
            border-radius: 1px;
        }
        .category-title span i { color: #44634d; margin-right: 8px; }

        .category-count-badge {
            background: #162119;
            color: #86efac;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid #1e4a28;
        }

        .content-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }

        .content-card {
            background: #13171d;
            border: 1px solid #1e2228;
            border-radius: 14px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: all .2s;
        }
        .content-card:hover {
            border-color: #44634d;
            transform: translateY(-4px);
            box-shadow: 0 16px 32px -8px rgba(68,99,77,.2);
        }

        .card-thumb {
            position: relative;
            height: 165px;
            overflow: hidden;
            background: #0a0c10;
            border-bottom: 1px solid #1e2228;
        }
        .card-thumb img {
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform .3s;
        }
        .content-card:hover .card-thumb img { transform: scale(1.05); }

        .type-badge {
            position: absolute;
            top: 10px; right: 10px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .type-badge.video   { background: #2c1515; color: #f87171; border: 1px solid #3f1f1f; }
        .type-badge.article { background: #1a2e1a; color: #86efac; border: 1px solid #2a4a2a; }
        .type-badge.image   { background: #2c2415; color: #fbbf24; border: 1px solid #3f341f; }

        .card-body {
            padding: 16px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .card-title {
            color: #e5e7eb;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.45;
            margin-bottom: 12px;
        }
        .card-footer {
            margin-top: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .cat-tag {
            background: #1e2228;
            color: #6b7280;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
            max-width: 130px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            background: #44634d;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            transition: all .18s;
        }
        .action-btn:hover {
            background: #365340;
            transform: translateX(3px);
        }

        #videoModal {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,.95);
            z-index: 2000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(6px);
        }
        #videoModal > div {
            position: relative;
            width: 90%;
            max-width: 960px;
        }
        #videoModal button {
            position: absolute;
            top: -44px; right: 0;
            background: none; border: none;
            color: #9ca3af;
            font-size: 38px;
            cursor: pointer;
            transition: color .2s;
        }
        #videoModal button:hover { color: #ef4444; }
        .video-container {
            position: relative; width: 100%; height: 0;
            padding-bottom: 56.25%;
            border-radius: 12px;
            overflow: hidden;
        }
        .video-container iframe {
            position: absolute; inset: 0;
            width: 100%; height: 100%;
            border: 0;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #4b5563;
        }
        .empty-state i { font-size: 48px; margin-bottom: 16px; color: #1e2228; }

        .sidebar-toggle {
            display: none;
            position: fixed;
            bottom: 24px; right: 24px;
            width: 52px; height: 52px;
            background: #44634d;
            border: none;
            border-radius: 50%;
            color: #fff;
            font-size: 20px;
            cursor: pointer;
            z-index: 500;
            box-shadow: 0 8px 20px rgba(68,99,77,.4);
        }

        @media (max-width: 900px) {
            .sidebar {
                position: fixed;
                left: -270px;
                top: 0; bottom: 0;
                z-index: 400;
                transition: left .25s ease;
            }
            .sidebar.open { left: 0; }
            .sidebar-toggle { display: flex; align-items: center; justify-content: center; }
            .main-content { padding: 24px 18px; }
        }
    </style>
</head>
<body>

<div class="page-layout">

    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2><i class="fas fa-compass"></i> Browse</h2>
        </div>

        <div class="sidebar-filters">
            <button class="filter-btn active" onclick="filterByType('all', this)">
                <i class="fas fa-globe"></i> All Content
                <span class="count-pill">${totalCount}</span>
            </button>
            <button class="filter-btn" onclick="filterByType('video', this)">
                <i class="fas fa-video"></i> Videos
                <span class="count-pill">${videoCount}</span>
            </button>
            <button class="filter-btn" onclick="filterByType('article', this)">
                <i class="fas fa-newspaper"></i> Articles
                <span class="count-pill">${articleCount}</span>
            </button>
            <button class="filter-btn" onclick="filterByType('image', this)">
                <i class="fas fa-image"></i> Images
                <span class="count-pill">${imageCount}</span>
            </button>
        </div>

        <p class="sidebar-section-label">Categories</p>
        <nav class="sidebar-nav">
            <button class="sidebar-link active" onclick="scrollToSection('all-top', this)">
                <i class="fas fa-layer-group"></i> All Categories
            </button>
            <%
                if (groupedContent != null) {
                    for (Map.Entry<String, List<ContentLearning>> entry : groupedContent.entrySet()) {
                        String cat = entry.getKey();
                        int sz = entry.getValue().size();
                        String anchorId = cat.replaceAll("[^a-zA-Z0-9]", "-");
            %>
            <button class="sidebar-link" onclick="scrollToSection('<%= anchorId %>', this)">
                <i class="fas fa-folder"></i>
                <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1;text-align:left"><%= cat %></span>
                <span class="cat-count"><%= sz %></span>
            </button>
            <%
                    }
                }
            %>
        </nav>
    </aside>

    <main class="main-content">
        <div id="all-top" class="page-heading">
            <h1><i class="fas fa-shield-alt"></i> Learning Hub</h1>
            <p>Explore curated videos, articles and resources on cybersecurity</p>
        </div>

        <div class="stats-bar">
            <div class="stat-chip"><i class="fas fa-layer-group"></i> Total <strong>${totalCount}</strong></div>
            <div class="stat-chip"><i class="fas fa-video"></i> Videos <strong>${videoCount}</strong></div>
            <div class="stat-chip"><i class="fas fa-newspaper"></i> Articles <strong>${articleCount}</strong></div>
            <div class="stat-chip"><i class="fas fa-image"></i> Images <strong>${imageCount}</strong></div>
        </div>

        <%
            if (groupedContent != null && !groupedContent.isEmpty()) {
                for (Map.Entry<String, List<ContentLearning>> entry : groupedContent.entrySet()) {
                    String cat = entry.getKey();
                    List<ContentLearning> list = entry.getValue();
                    String anchorId = cat.replaceAll("[^a-zA-Z0-9]", "-");
        %>
        <section id="<%= anchorId %>" class="category-section">
            <div class="category-title">
                <span><i class="fas fa-bookmark"></i><%= cat %></span>
                <span class="category-count-badge"><%= list.size() %> resources</span>
            </div>

            <div class="content-grid">
                <% for (ContentLearning c : list) {
                       String icon = "video".equals(c.getType()) ? "video"
                                   : "article".equals(c.getType()) ? "newspaper" : "image";
                       String embedUrl = c.getLink();
                %>
                <div class="content-card" data-type="<%= c.getType() %>">
                    <div class="card-thumb">
                        <span class="type-badge <%= c.getType() %>">
                            <i class="fas fa-<%= icon %>"></i> <%= c.getType() %>
                        </span>
                        <img src="<%= c.getThumbnail() %>"
                             alt="<%= c.getTitle() %>"
                             loading="lazy"
                             onerror="this.src='images/default-thumbnail.png'">
                    </div>
                    <div class="card-body">
                        <h3 class="card-title"><%= c.getTitle() %></h3>
                        <div class="card-footer">
                            <span class="cat-tag" title="<%= c.getCategory() %>"><%= c.getCategory() %></span>
                            <% if ("video".equals(c.getType())) { %>
                                <button class="action-btn" onclick="openVideo('<%= embedUrl %>')">
                                    <i class="fas fa-play"></i> Watch
                                </button>
                            <% } else { %>
                                <a href="<%= c.getLink() %>" class="action-btn" target="_blank" rel="noopener noreferrer">
                                    <i class="fas fa-<%= "article".equals(c.getType()) ? "external-link-alt" : "eye" %>"></i>
                                    <%= "article".equals(c.getType()) ? "Read" : "View" %>
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </section>
        <%
                }
            } else {
        %>
        <div class="empty-state">
            <i class="fas fa-inbox"></i>
            <p>No learning content available yet.</p>
        </div>
        <% } %>

    </main>
</div>

<div id="videoModal">
    <div>
        <button onclick="closeVideo()">&times;</button>
        <div id="videoContainer" class="video-container"></div>
    </div>
</div>

<button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()">
    <i class="fas fa-bars"></i>
</button>

<script>
    function openVideo(url) {
        if (!url) {
            console.error("No URL provided");
            return;
        }
        
        let embedUrl = url;
        
        // Handle different YouTube URL formats
        if (url.includes('youtube.com/watch?v=')) {
            embedUrl = url.replace('watch?v=', 'embed/');
        } else if (url.includes('youtu.be/')) {
            let videoId = url.split('/').pop();
            if (videoId.includes('?')) {
                videoId = videoId.split('?')[0];
            }
            embedUrl = 'https://www.youtube.com/embed/' + videoId;
        } else if (url.includes('/embed/')) {
            embedUrl = url;
        } else if (url.includes('youtube.com')) {
            let match = url.match(/(?:v=|v\/|embed\/|youtu.be\/)([a-zA-Z0-9_-]{11})/);
            if (match) {
                embedUrl = 'https://www.youtube.com/embed/' + match[1];
            }
        }
        
        // Add autoplay and other parameters
        if (embedUrl.includes('?')) {
            embedUrl += '&autoplay=1&rel=0&modestbranding=1';
        } else {
            embedUrl += '?autoplay=1&rel=0&modestbranding=1';
        }
        
        const container = document.getElementById('videoContainer');
        if (container) {
            container.innerHTML = '<iframe src="' + embedUrl + '" frameborder="0" allow="autoplay; encrypted-media; fullscreen" allowfullscreen style="width:100%;height:100%"></iframe>';
            document.getElementById('videoModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }
    
    function closeVideo() {
        document.getElementById('videoContainer').innerHTML = '';
        document.getElementById('videoModal').style.display = 'none';
        document.body.style.overflow = '';
    }
    
    document.addEventListener('keydown', function(e) { 
        if (e.key === 'Escape') closeVideo(); 
    });
    
    document.getElementById('videoModal').addEventListener('click', function(e) {
        if (e.target === this) closeVideo();
    });

    function filterByType(type, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        document.querySelectorAll('.content-card').forEach(card => {
            card.style.display = (type === 'all' || card.dataset.type === type) ? 'flex' : 'none';
        });

        document.querySelectorAll('.category-section').forEach(sec => {
            const visible = sec.querySelectorAll('.content-card[style*="flex"]').length;
            sec.style.display = visible === 0 ? 'none' : 'block';
        });
    }

    function scrollToSection(id, btn) {
        document.querySelectorAll('.sidebar-link').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        if (id === 'all-top') {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            const el = document.getElementById(id);
            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        if (window.innerWidth <= 900) {
            document.getElementById('sidebar').classList.remove('open');
        }
    }

    window.addEventListener('scroll', () => {
        const sections = document.querySelectorAll('.category-section');
        let current = '';
        sections.forEach(sec => {
            if (window.scrollY >= sec.offsetTop - 200) current = sec.id;
        });
        document.querySelectorAll('.sidebar-link').forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('onclick') && link.getAttribute('onclick').includes("'" + current + "'")) {
                link.classList.add('active');
            }
        });
    });

    function toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('open');
    }
</script>
</body>
</html>