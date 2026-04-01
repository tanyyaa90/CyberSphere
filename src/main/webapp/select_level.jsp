<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="header.jsp" %>
<%
Integer userId = (Integer) session.getAttribute("userId");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

/* Get clicked level */
String level = request.getParameter("level");

/* If user clicked a level */
if(level != null){
    session.setAttribute("quizLevel", level);

    // FIX: pass level also in URL
    response.sendRedirect("select_sublevel.jsp?level=" + level);
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Select Quiz Level | CyberSphere</title>
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
            display: flex;
            flex-direction: column;
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


        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
            position: relative;
            z-index: 1;
        }

        .quiz-card {
            background: #0f1115;
            border-radius: 24px;
            border: 1px solid #1e1e1e;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            max-width: 900px;
            width: 100%;
            padding: 50px 40px;
            text-align: center;
        }

        h1 {
            font-size: 36px;
            margin-bottom: 15px;
            color: #ffffff;
            font-weight: 600;
            letter-spacing: -0.02em;
        }

        .subtitle {
            font-size: 18px;
            color: #9ca3af;
            margin-bottom: 40px;
            line-height: 1.6;
        }

        h2 {
            color: #44634d;
            font-size: 24px;
            font-weight: 500;
            margin-bottom: 30px;
            border-left: 3px solid #44634d;
            padding-left: 12px;
            display: inline-block;
        }

        .level-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
            margin-top: 20px;
        }

        .level-card {
            background: #1a1e24;
            border-radius: 16px;
            padding: 35px 20px;
            transition: all 0.2s ease;
            text-decoration: none;
            color: inherit;
            border: 1px solid #2a2f3a;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }

        .level-card:hover {
            transform: translateY(-5px);
            border-color: #44634d;
            background: #1f242b;
            box-shadow: 0 20px 30px -10px rgba(68, 99, 77, 0.2);
        }

        .level-icon {
            font-size: 48px;
            margin-bottom: 5px;
        }

        .level-title {
            font-size: 24px;
            font-weight: 700;
            margin-top: 5px;
        }

        .level-description {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.5;
        }

        /* Level-specific colors */
        .beginner .level-title { 
            color: #86efac; 
        }
        .beginner:hover .level-title { 
            color: #86efac; 
        }

        .intermediate .level-title { 
            color: #fbbf24; 
        }
        .intermediate:hover .level-title { 
            color: #fbbf24; 
        }

        .hard .level-title { 
            color: #f87171; 
        }
        .hard:hover .level-title { 
            color: #f87171; 
        }


        /* Responsive */
        @media (max-width: 768px) {
            .level-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .quiz-card {
                padding: 30px 20px;
            }
            
            h1 {
                font-size: 28px;
            }
        }
    </style>
</head>

<body>


<div class="container">
    <div class="quiz-card">

        <h1>Cybersecurity Knowledge Quiz</h1>
        <p class="subtitle">
            Test your cybersecurity knowledge and see how well you can protect yourself online!
        </p>

        <h2>Choose Your Difficulty Level</h2>

        <div class="level-grid">

            <!-- Beginner -->
            <a href="select_level.jsp?level=beginner" class="level-card beginner">
                <div class="level-icon">🟢</div>
                <div class="level-title">Beginner</div>
                <div class="level-description">Basic cybersecurity concepts</div>
            </a>

            <!-- Intermediate -->
            <a href="select_level.jsp?level=intermediate" class="level-card intermediate">
                <div class="level-icon">🟡</div>
                <div class="level-title">Intermediate</div>
                <div class="level-description">Moderate security knowledge</div>
            </a>

            <!-- Hard -->
            <a href="select_level.jsp?level=hard" class="level-card hard">
                <div class="level-icon">🔴</div>
                <div class="level-title">Hard</div>
                <div class="level-description">Expert-level challenges</div>
            </a>

        </div>

    </div>
</div>

</body>
</html>