<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Set" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Integer score = (Integer) request.getAttribute("score");
    Integer total = (Integer) request.getAttribute("total");
    Set<String> weakTopics = (Set<String>) request.getAttribute("weakTopics");
    String level = (String) request.getAttribute("level");
    
    if (score == null || total == null) {
        response.sendRedirect("QuizServlet");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Results | CyberSphere</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f4f6f8;
        }
        
        nav {
            background-color: #1e1e2f;
            padding: 15px;
        }
        
        nav a {
            color: white;
            margin-right: 20px;
            text-decoration: none;
            font-weight: bold;
        }
        
        nav a:hover {
            text-decoration: underline;
        }
        
        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        h1 {
            color: #2563eb;
            text-align: center;
        }
        
        .score-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 10px;
            text-align: center;
            margin: 30px 0;
        }
        
        .score-number {
            font-size: 72px;
            font-weight: bold;
            margin: 20px 0;
        }
        
        .score-fraction {
            font-size: 24px;
            opacity: 0.9;
        }
        
        .percentage {
            font-size: 32px;
            font-weight: bold;
            margin-top: 10px;
        }
        
        .weak-topics {
            background: #fef2f2;
            padding: 25px;
            border-radius: 8px;
            margin: 30px 0;
        }
        
        .weak-topics h3 {
            color: #dc2626;
            margin-top: 0;
        }
        
        .topic-list {
            list-style: none;
            padding: 0;
        }
        
        .topic-list li {
            padding: 10px 15px;
            margin: 8px 0;
            background: white;
            border-radius: 6px;
            border-left: 4px solid #dc2626;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: #2563eb;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin: 10px 5px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        
        .btn:hover {
            background-color: #1d4ed8;
        }
        
        .btn-success {
            background-color: #22c55e;
        }
        
        .btn-success:hover {
            background-color: #16a34a;
        }
        
        .btn-group {
            text-align: center;
            margin-top: 30px;
        }
        
        .message {
            text-align: center;
            font-size: 18px;
            margin: 20px 0;
            padding: 20px;
            border-radius: 8px;
        }
        
        .excellent {
            background: #d1fae5;
            color: #065f46;
        }
        
        .good {
            background: #fef3c7;
            color: #92400e;
        }
        
        .needs-improvement {
            background: #fee2e2;
            color: #991b1b;
        }
    </style>
</head>
<body>
    <nav>
        <a href="home.jsp">Home</a>
        <a href="QuizServlet">Take Another Quiz</a>
        <a href="LogoutServlet">Logout</a>
    </nav>
    
    <div class="container">
        <h1>Quiz Results - <%= level != null ? level : "General" %> Level</h1>
        
        <div class="score-card">
            <h2>Your Score</h2>
            <div class="score-number"><%= score %></div>
            <div class="score-fraction">out of <%= total %> questions</div>
            <div class="percentage">
                <% 
                double percentage = (score * 100.0) / total;
                out.print(String.format("%.1f", percentage) + "%");
                %>
            </div>
        </div>
        
        <%
        String message = "";
        String messageClass = "";
        
        if (percentage >= 80) {
            message = "Excellent! You're a cybersecurity pro!";
            messageClass = "excellent";
        } else if (percentage >= 60) {
            message = "Good job! Keep learning and improving!";
            messageClass = "good";
        } else {
            message = "Keep practicing! Review the topics below to improve.";
            messageClass = "needs-improvement";
        }
        %>
        
        <div class="message <%= messageClass %>">
            <%= message %>
        </div>
        
        <%
        if (weakTopics != null && !weakTopics.isEmpty()) {
        %>
        <div class="weak-topics">
            <h3>Topics to Improve</h3>
            <p>Based on your answers, you might want to review these topics:</p>
            
            <ul class="topic-list">
            <%
                for (String topic : weakTopics) {
            %>
                <li><strong><%= topic %></strong></li>
            <%
                }
            %>
            </ul>
            
            <form action="learn.jsp" method="get" style="margin-top: 20px;">
            <%
                for (String topic : weakTopics) {
            %>
                <input type="hidden" name="topic" value="<%= topic %>">
            <%
                }
            %>
                <button type="submit" class="btn btn-success">Learn These Topics</button>
            </form>
        </div>
        <%
        } else {
        %>
        <div style="text-align: center; padding: 30px; background: #d1fae5; border-radius: 8px;">
            <h3 style="color: #065f46;">Perfect Score!</h3>
            <p style="font-size: 16px; color: #065f46;">
                You answered all questions correctly! No weak topics detected.
            </p>
        </div>
        <%
        }
        %>
        
        <div class="btn-group">
            <a href="QuizServlet?level=<%= level %>" class="btn">Retry <%= level %> Quiz</a>
            <a href="QuizServlet" class="btn">Try Another Quiz</a>
            <a href="home.jsp" class="btn">Return to Home</a>
        </div>
    </div>
</body>
</html>