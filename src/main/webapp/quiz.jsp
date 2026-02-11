<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Question" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    String level = (String) request.getAttribute("level");
    if (level == null) level = "Beginner";
    
    if (questions == null) {
        response.sendRedirect("QuizServlet");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title><%= level %> Quiz | CyberSphere</title>
    <style>
        :root {
            --bg: #f5f7fb;
            --card: #ffffff;
            --text: #0f172a;
            --btn: #2563eb;
            --grey: #94a3b8;
            --green: #22c55e;
            --red: #ef4444;
        }
        
        body.dark {
            --bg: #020617;
            --card: #0f172a;
            --text: #e5e7eb;
            --btn: #38bdf8;
        }
        
        body {
            margin: 0;
            background: var(--bg);
            color: var(--text);
            font-family: Arial, sans-serif;
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
        
        .wrapper {
            max-width: 1100px;
            margin: 40px auto;
            display: flex;
            justify-content: center;
            gap: 40px;
        }
        
        .main {
            flex: 1;
            max-width: 700px;
        }
        
        .sidebar {
            display: flex;
            flex-direction: column;
            gap: 12px;
            align-items: center;
        }
        
        .circle {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: var(--grey);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .circle.green { background: var(--green); }
        .circle.red { background: var(--red); }
        
        .top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .quiz-title {
            font-size: 26px;
            font-weight: bold;
        }
        
        .theme-btn {
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid var(--text);
            background: none;
            cursor: pointer;
            color: var(--text);
        }
        
        .card {
            background: var(--card);
            padding: 35px;
            border-radius: 14px;
            min-height: 320px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .question {
            display: none;
        }
        
        .question.active {
            display: block;
        }
        
        .options label {
            display: block;
            margin: 12px 0;
            padding: 12px;
            border-radius: 6px;
            cursor: pointer;
            border: 1px solid #e2e8f0;
        }
        
        .options label:hover {
            background: rgba(37, 99, 235, 0.1);
            border-color: #2563eb;
        }
        
        .options input[type="radio"] {
            margin-right: 10px;
        }
        
        .nav {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 25px;
        }
        
        button {
            padding: 10px 18px;
            border: none;
            border-radius: 6px;
            background: var(--btn);
            color: white;
            cursor: pointer;
            font-size: 14px;
        }
        
        button:hover {
            opacity: 0.9;
        }
        
        .bottom {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        
        .clear {
            background: #64748b;
        }
        
        .submit {
            background: #22c55e;
        }
        
        .level-selector {
            text-align: center;
            margin: 20px 0;
        }
        
        .level-btn {
            padding: 8px 16px;
            margin: 0 5px;
            background: #e2e8f0;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .level-btn.active {
            background: #2563eb;
            color: white;
        }
    </style>
</head>
<body>
    <nav>
        <a href="home.jsp">Home</a>
        <a href="QuizServlet?level=Beginner">Beginner Quiz</a>
        <a href="QuizServlet?level=Intermediate">Intermediate Quiz</a>
        <a href="QuizServlet?level=Hard">Hard Quiz</a>
        <a href="LogoutServlet">Logout</a>
    </nav>
    
    <div class="level-selector">
        <button class="level-btn <%= "Beginner".equals(level) ? "active" : "" %>" 
                onclick="window.location.href='QuizServlet?level=Beginner'">Beginner</button>
        <button class="level-btn <%= "Intermediate".equals(level) ? "active" : "" %>" 
                onclick="window.location.href='QuizServlet?level=Intermediate'">Intermediate</button>
        <button class="level-btn <%= "Advanced".equals(level) ? "active" : "" %>" 
                onclick="window.location.href='QuizServlet?level=Hard'">Hard</button>
    </div>

    <div class="wrapper">
        <div class="main">
            <div class="top">
                <div class="quiz-title"><%= level %> Level Quiz</div>
                <button type="button" class="theme-btn" onclick="toggleTheme()">🌓 Toggle Theme</button>
            </div>
            
            <form action="ResultServlet" method="post" id="quizForm">
                <input type="hidden" name="level" value="<%= level %>">
                
                <div class="card">
                    <% 
                    for(int i = 0; i < questions.size(); i++) { 
                        Question q = questions.get(i);
                    %>
                    <div class="question <%= i == 0 ? "active" : "" %>" id="q<%= i %>">
                        <h3>Q<%= i+1 %>. <%= q.getQuestionText() %></h3>
                        <div class="options">
                            <label>
                                <input type="radio" name="q<%= q.getId() %>" value="A" required>
                                <%= q.getOptionA() %>
                            </label>
                            <label>
                                <input type="radio" name="q<%= q.getId() %>" value="B">
                                <%= q.getOptionB() %>
                            </label>
                            <label>
                                <input type="radio" name="q<%= q.getId() %>" value="C">
                                <%= q.getOptionC() %>
                            </label>
                            <label>
                                <input type="radio" name="q<%= q.getId() %>" value="D">
                                <%= q.getOptionD() %>
                            </label>
                        </div>
                    </div>
                    <% } %>
                    
                    <div class="nav">
                        <button type="button" onclick="prevQuestion()">Previous</button>
                        <button type="button" onclick="nextQuestion()">Next</button>
                    </div>
                </div>
                
                <div class="bottom">
                    <button type="button" class="clear" onclick="clearAll()">Clear All Answers</button>
                    <button type="submit" class="submit" onclick="return validateSubmit()">Submit Quiz</button>
                </div>
            </form>
        </div>
        
        <div class="sidebar">
            <% for(int i = 0; i < questions.size(); i++) { %>
                <div class="circle" id="indicator<%= i %>"><%= i+1 %></div>
            <% } %>
        </div>
    </div>

    <script>
        let currentQuestion = 0;
        const questions = document.querySelectorAll('.question');
        const indicators = document.querySelectorAll('.circle');
        
        function showQuestion(index) {
            questions.forEach(q => q.classList.remove('active'));
            questions[index].classList.add('active');
            currentQuestion = index;
            updateIndicators();
        }
        
        function nextQuestion() {
            if (currentQuestion < questions.length - 1) {
                showQuestion(currentQuestion + 1);
            }
        }
        
        function prevQuestion() {
            if (currentQuestion > 0) {
                showQuestion(currentQuestion - 1);
            }
        }
        
        function updateIndicators() {
            indicators.forEach((indicator, index) => {
                const questionDiv = document.getElementById('q' + index);
                const radios = questionDiv.querySelectorAll('input[type="radio"]');
                const isAnswered = Array.from(radios).some(radio => radio.checked);
                
                if (isAnswered) {
                    indicator.className = 'circle green';
                } else {
                    indicator.className = 'circle';
                }
                
                if (index === currentQuestion) {
                    indicator.style.border = '2px solid #2563eb';
                } else {
                    indicator.style.border = 'none';
                }
            });
        }
        
        function clearAll() {
            if (confirm('Are you sure you want to clear all answers?')) {
                document.querySelectorAll('input[type="radio"]').forEach(radio => {
                    radio.checked = false;
                });
                updateIndicators();
            }
        }
        
        function validateSubmit() {
            let allAnswered = true;
            const unanswered = [];
            
            questions.forEach((question, index) => {
                const radios = question.querySelectorAll('input[type="radio"]');
                const isAnswered = Array.from(radios).some(radio => radio.checked);
                
                if (!isAnswered) {
                    indicators[index].className = 'circle red';
                    unanswered.push(index + 1);
                    allAnswered = false;
                }
            });
            
            if (!allAnswered) {
                alert('Please answer all questions before submitting!\n\nUnanswered questions: ' + unanswered.join(', '));
                return false;
            }
            
            return confirm('Are you sure you want to submit the quiz? You cannot change answers after submitting.');
        }
        
        function toggleTheme() {
            document.body.classList.toggle('dark');
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        
        document.querySelectorAll('input[type="radio"]').forEach(radio => {
            radio.addEventListener('change', updateIndicators);
        });
        
        document.addEventListener('DOMContentLoaded', function() {
            const savedTheme = localStorage.getItem('theme');
            if (savedTheme === 'dark') {
                document.body.classList.add('dark');
            }
            showQuestion(0);
        });
    </script>
</body>
</html>