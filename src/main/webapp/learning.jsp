<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> topicsToLearn = (List<String>) request.getAttribute("topicsToLearn");
    Map<String, List<String>> topicResources =
            (Map<String, List<String>>) request.getAttribute("topicResources");

    if (topicsToLearn == null || topicResources == null || topicResources.isEmpty()) {
        response.sendRedirect("QuizServlet");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Learn These Topics | CyberSphere</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CyberSphere dark theme */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0a0c10;  /* Dark charcoal background */
            min-height: 100vh;
            margin: 0;
            color: #e5e7eb;
            position: relative;
        }

        /* Cyber icons background pattern */
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

        .home-btn {
            background: #1a1e24;
            color: #9ca3af;
            border: 1px solid #2a2f3a;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            text-decoration: none;
        }

        .home-btn:hover { 
            background: #44634d;
            color: white;
            border-color: #44634d;
            transform: translateY(-1px);
        }

        .home-btn i {
            font-size: 14px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px 40px;
            position: relative;
            z-index: 1;
        }

        /* Page Title Section */
        .page-title-section {
            text-align: center;
            margin: 20px 0 40px 0;
        }

        .page-title-section h1 {
            font-size: 36px;
            font-weight: 600;
            color: #ffffff;
            letter-spacing: -0.02em;
            margin-bottom: 10px;
        }

        .page-title-section h1 span {
            color: #44634d;
        }

        .page-title-section p {
            color: #9ca3af;
            font-size: 16px;
        }

        .section { 
            margin: 40px 0; 
            background: #0f1115;
            border-radius: 16px;
            padding: 30px;
            border: 1px solid #1e1e1e;
        }

        .topic-bar {
            background: #1a1e24;
            padding: 20px 25px;
            border-radius: 12px;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 25px;
            border-left: 4px solid #44634d;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid #2a2f3a;
        }

        .topic-bar i {
            color: #44634d;
        }

        h3 {
            color: #9ca3af;
            margin: 25px 0 15px 0;
            font-size: 18px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        h3 i {
            color: #44634d;
        }

        .row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        .card {
            background: #1a1e24;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            border: 1px solid #2a2f3a;
            overflow: hidden;
        }

        .card:hover { 
            transform: translateY(-5px); 
            border-color: #44634d;
            box-shadow: 0 20px 30px -10px rgba(68, 99, 77, 0.2);
        }

        .card img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            border-bottom: 1px solid #2a2f3a;
        }

        .card-title { 
            padding: 15px; 
            font-weight: 500; 
            font-size: 14px;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .card-title i {
            color: #44634d;
        }

        .article-box {
            background: #1a1e24;
            padding: 18px 20px;
            border-radius: 12px;
            margin-bottom: 12px;
            cursor: pointer;
            border-left: 4px solid #fbbf24;
            font-weight: 500;
            color: #9ca3af;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid #2a2f3a;
        }

        .article-box:hover { 
            background: #1f242b;
            border-left-color: #44634d;
            transform: translateX(5px);
            color: #ffffff;
        }

        .article-box i {
            color: #fbbf24;
            font-size: 18px;
        }

        .article-box:hover i {
            color: #44634d;
        }

        /* Back Button Container */
        .back-button-container {
            text-align: center;
            margin: 50px 0 30px 0;
        }

        .back-home-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: #44634d;
            color: white;
            border: none;
            padding: 14px 32px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .back-home-btn:hover {
            background: #36523d;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
        }

        .back-home-btn i {
            font-size: 16px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .row {
                grid-template-columns: repeat(2, 1fr);
            }
            
            header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .container {
                padding: 20px;
            }
            
            .page-title-section h1 {
                font-size: 28px;
            }
        }

        @media (max-width: 480px) {
            .row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>


<div class="container">
    
    <!-- Page Title Section -->
    <div class="page-title-section">
        <h1>Topics to <span>Improve</span></h1>
        <p>Based on your quiz results, here are the topics you should focus on</p>
    </div>

<%
for(String topic : topicsToLearn) {

    List<String> links = topicResources.get(topic);
    if(links == null) continue;

    List<String> videos = new ArrayList<>();
    List<String> articles = new ArrayList<>();

    for(String link : links) {
        if(link.contains("youtu.be") || link.contains("youtube.com")) {
            videos.add(link);
        } else {
            articles.add(link);
        }
    }
%>

<div class="section">

    <div class="topic-bar">
        <i class="fas fa-bookmark"></i>
        <%= topic %>
    </div>

    <% if(!videos.isEmpty()) { %>
        <h3>
            <i class="fas fa-video"></i>
            Videos (<%= videos.size() %>)
        </h3>
        <div class="row">
        <% for(String link : videos) {

            String videoId = link.substring(link.lastIndexOf("/") + 1);
            if(videoId.contains("?")) {
                videoId = videoId.substring(0, videoId.indexOf("?"));
            }

            String thumbnail = "https://img.youtube.com/vi/" + videoId + "/0.jpg";
        %>
            <div class="card" onclick="window.open('<%= link %>','_blank')">
                <img src="<%= thumbnail %>" onerror="this.src='https://via.placeholder.com/320x180?text=Video+Thumbnail'">
                <div class="card-title">
                    <i class="fas fa-play-circle"></i>
                    Watch Video
                </div>
            </div>
        <% } %>
        </div>
    <% } %>

    <% if(!articles.isEmpty()) { %>
        <h3 style="margin-top:30px;">
            <i class="fas fa-newspaper"></i>
            Articles (<%= articles.size() %>)
        </h3>
        <% for(String link : articles) { %>
            <div class="article-box" onclick="window.open('<%= link %>','_blank')">
                <i class="fas fa-file-alt"></i>
                 Read Article
            </div>
        <% } %>
    <% } %>

</div>

<%
}
%>

    <!-- Back to Home Button -->
    <div class="back-button-container">
        <a href="home.jsp" class="back-home-btn">
            <i class="fas fa-arrow-left"></i> Back to Home
        </a>
    </div>

</div>

</body>
</html>