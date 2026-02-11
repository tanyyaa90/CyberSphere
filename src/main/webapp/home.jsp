<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
   if (session.getAttribute("userId") == null) {
       response.sendRedirect("login.jsp");
       return;
   }
%>
<!DOCTYPE html>
<html>
<head>
   <title>CyberSafe Hub | Home</title>
   <style>
       body {
           font-family: Arial, sans-serif;
           margin: 0;
           background-color: #f4f6f8;
       }
       nav {
           background-color: #1e1e2f;
           padding: 15px;
           color: white;
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
           padding: 40px;
       }
       h1 {
           color: #222;
       }
       .about {
           margin-top: 30px;
           background: white;
           padding: 25px;
           border-radius: 8px;
       }
       .btn {
           display: inline-block;
           margin-top: 20px;
           padding: 12px 20px;
           background-color: #2563eb;
           color: white;
           text-decoration: none;
           border-radius: 6px;
       }
       .btn:hover {
           background-color: #1d4ed8;
       }
   </style>
</head>
<body>
<nav>
   <a href="home.jsp">Home</a>
   <a href="QuizServlet">Take Quiz</a>
   <a href="phishing.jsp">Email Detector</a>
   <a href="LogoutServlet">Logout</a>
</nav>
<div class="container">
   <h1>Welcome to CyberSphere</h1>
   <p>Your personalized cybersecurity awareness platform.</p>
   <div class="about">
       <h2>About Us</h2>
       <p>
           CyberSphere is designed to spread awareness about cybersecurity
           threats such as phishing, fake emails, and online scams.
           The platform helps users learn safe online practices through
           interactive learning modules, quizzes, and detection tools.
       </p>
   </div>
   <a href="QuizServlet" class="btn">Start Quiz</a>
</div>
</body>
</html>
