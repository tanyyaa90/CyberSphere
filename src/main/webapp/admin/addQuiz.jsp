<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    
    // Get all topics for dropdown
    List<String> topics = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT name FROM topics ORDER BY name");
        while (rs.next()) {
            topics.add(rs.getString("name"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Get next available sublevel for selected level
    String selectedLevel = request.getParameter("level");
    int nextSubLevel = 1;
    
    if (selectedLevel != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT COALESCE(MAX(sub_level), 0) + 1 as next FROM questions WHERE level = '" + selectedLevel + "'");
            if (rs.next()) {
                nextSubLevel = rs.getInt("next");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (stmt != null) try { stmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Quiz | CyberSphere Admin</title>
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
        }
        
        /* Form Container */
        .form-container {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 30px;
        }
        
        .form-title {
            color: #ffffff;
            font-size: 24px;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .quiz-info {
            background: #1a2a1a;
            border: 1px solid #2a4a2a;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .quiz-info i {
            font-size: 24px;
            color: #86efac;
        }
        
        .quiz-info p {
            color: #9ca3af;
        }
        
        .quiz-info strong {
            color: #86efac;
        }
        
        .form-group {
            margin-bottom: 20px;
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
            border-radius: 8px;
            color: #ffffff;
            font-size: 14px;
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #44634d;
            box-shadow: 0 0 0 3px rgba(68, 99, 77, 0.1);
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
        
        .question-card {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            position: relative;
        }
        
        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #2a2f3a;
        }
        
        .question-header h3 {
            color: #ffffff;
            font-size: 18px;
        }
        
        .question-header h3 i {
            color: #44634d;
            margin-right: 8px;
        }
        
        .remove-question {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
            width: 32px;
            height: 32px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .remove-question:hover {
            background: #ef4444;
            color: white;
            border-color: #ef4444;
        }
        
        .options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin: 15px 0;
        }
        
        .option-item {
            background: #0f1115;
            border: 1px solid #2a2f3a;
            border-radius: 8px;
            padding: 12px;
        }
        
        .option-item label {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #9ca3af;
            margin-bottom: 8px;
        }
        
        .option-item input[type="radio"] {
            width: 16px;
            height: 16px;
            cursor: pointer;
            accent-color: #44634d;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            justify-content: flex-end;
        }
        
        .btn {
            padding: 12px 24px;
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
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.3);
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
        }
        
        .btn-success {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }
        
        .btn-success:hover {
            background: #1f3a1f;
        }
        
        .btn-danger {
            background: #2c1515;
            color: #f87171;
            border: 1px solid #3f1f1f;
        }
        
        .btn-danger:hover {
            background: #ef4444;
            color: white;
        }
        
        .add-question-btn {
            width: 100%;
            padding: 15px;
            background: #1a1e24;
            border: 2px dashed #2a2f3a;
            border-radius: 12px;
            color: #9ca3af;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            margin: 20px 0;
        }
        
        .add-question-btn:hover {
            border-color: #44634d;
            color: #ffffff;
            background: #1f242b;
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
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .options-grid {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-plus-circle"></i> Add New Quiz</h1>
                <a href="quizzes.jsp" class="back-link">
                    <i class="fas fa-arrow-left"></i> Back to Quizzes
                </a>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <div class="form-container">
            <h2 class="form-title"><i class="fas fa-question-circle"></i> Quiz Details</h2>
            
            <% if (selectedLevel != null) { %>
            <div class="quiz-info">
                <i class="fas fa-info-circle"></i>
                <p>You are adding questions for <strong><%= selectedLevel %> level</strong>. 
                This will be <strong>Level <%= nextSubLevel %></strong> (Quiz #<%= nextSubLevel %>) for this difficulty.</p>
            </div>
            <% } %>
            
            <form action="AddQuizServlet" method="post" id="quizForm" onsubmit="return validateForm()">
                <!-- Quiz Level Selection -->
                <div class="form-group">
                    <label><i class="fas fa-layer-group"></i> Quiz Level *</label>
                    <select class="form-control" name="level" id="levelSelect" required onchange="updateSubLevel()">
                        <option value="">Select Level</option>
                        <option value="beginner" <%= "beginner".equals(selectedLevel) ? "selected" : "" %>>Beginner</option>
                        <option value="intermediate" <%= "intermediate".equals(selectedLevel) ? "selected" : "" %>>Intermediate</option>
                        <option value="hard" <%= "hard".equals(selectedLevel) ? "selected" : "" %>>Hard</option>
                    </select>
                </div>
                
                <!-- Sub Level (auto-calculated) -->
                <div class="form-group">
                    <label><i class="fas fa-hashtag"></i> Sub Level (Quiz Number)</label>
                    <input type="number" class="form-control" name="sub_level" id="subLevel" value="<%= nextSubLevel %>" readonly>
                    <div class="help-text" style="color: #6b7280; font-size: 12px; margin-top: 5px;">
                        <i class="fas fa-info-circle"></i> This is automatically calculated based on existing quizzes
                    </div>
                </div>
                
                <!-- Questions Container -->
                <div id="questions-container">
                    <!-- Question 1 (default) -->
                    <div class="question-card" id="question-1">
                        <div class="question-header">
                            <h3><i class="fas fa-question"></i> Question #1</h3>
                            <button type="button" class="remove-question" onclick="removeQuestion(1)" style="display: none;">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        
                        <div class="form-group">
                            <label>Question Text</label>
                            <textarea class="form-control" name="question_1" rows="3" required placeholder="Enter your question"></textarea>
                        </div>
                        
                        <div class="options-grid">
                            <div class="option-item">
                                <label>
                                    <input type="radio" name="correct_1" value="A" required>
                                    <span>Correct Answer</span>
                                </label>
                                <input type="text" class="form-control" name="option_a_1" required placeholder="Option A">
                            </div>
                            
                            <div class="option-item">
                                <label>
                                    <input type="radio" name="correct_1" value="B" required>
                                    <span>Correct Answer</span>
                                </label>
                                <input type="text" class="form-control" name="option_b_1" required placeholder="Option B">
                            </div>
                            
                            <div class="option-item">
                                <label>
                                    <input type="radio" name="correct_1" value="C" required>
                                    <span>Correct Answer</span>
                                </label>
                                <input type="text" class="form-control" name="option_c_1" required placeholder="Option C">
                            </div>
                            
                            <div class="option-item">
                                <label>
                                    <input type="radio" name="correct_1" value="D" required>
                                    <span>Correct Answer</span>
                                </label>
                                <input type="text" class="form-control" name="option_d_1" required placeholder="Option D">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label>Explanation (Optional)</label>
                                <textarea class="form-control" name="explanation_1" rows="2" placeholder="Explain why this answer is correct"></textarea>
                            </div>
                            
                            <div class="form-group">
                                <label>Topic</label>
                                <select class="form-control" name="topic_1">
                                    <option value="">Select Topic (Optional)</option>
                                    <% for (String topic : topics) { %>
                                        <option value="<%= topic %>"><%= topic %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Add Question Button -->
                <button type="button" class="add-question-btn" onclick="addQuestion()">
                    <i class="fas fa-plus"></i> Add Another Question
                </button>
                
                <!-- Action Buttons -->
                <div class="action-buttons">
                    <a href="quizzes.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Create Quiz
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        let questionCount = 1;
        
        function addQuestion() {
            questionCount++;
            const container = document.getElementById('questions-container');
            const newQuestion = document.createElement('div');
            newQuestion.className = 'question-card';
            newQuestion.id = 'question-' + questionCount;
            
            newQuestion.innerHTML = `
                <div class="question-header">
                    <h3><i class="fas fa-question"></i> Question #${questionCount}</h3>
                    <button type="button" class="remove-question" onclick="removeQuestion(${questionCount})">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <div class="form-group">
                    <label>Question Text</label>
                    <textarea class="form-control" name="question_${questionCount}" rows="3" required placeholder="Enter your question"></textarea>
                </div>
                
                <div class="options-grid">
                    <div class="option-item">
                        <label>
                            <input type="radio" name="correct_${questionCount}" value="A" required>
                            <span>Correct Answer</span>
                        </label>
                        <input type="text" class="form-control" name="option_a_${questionCount}" required placeholder="Option A">
                    </div>
                    
                    <div class="option-item">
                        <label>
                            <input type="radio" name="correct_${questionCount}" value="B" required>
                            <span>Correct Answer</span>
                        </label>
                        <input type="text" class="form-control" name="option_b_${questionCount}" required placeholder="Option B">
                    </div>
                    
                    <div class="option-item">
                        <label>
                            <input type="radio" name="correct_${questionCount}" value="C" required>
                            <span>Correct Answer</span>
                        </label>
                        <input type="text" class="form-control" name="option_c_${questionCount}" required placeholder="Option C">
                    </div>
                    
                    <div class="option-item">
                        <label>
                            <input type="radio" name="correct_${questionCount}" value="D" required>
                            <span>Correct Answer</span>
                        </label>
                        <input type="text" class="form-control" name="option_d_${questionCount}" required placeholder="Option D">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Explanation (Optional)</label>
                        <textarea class="form-control" name="explanation_${questionCount}" rows="2" placeholder="Explain why this answer is correct"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Topic</label>
                        <select class="form-control" name="topic_${questionCount}">
                            <option value="">Select Topic (Optional)</option>
                            <% for (String topic : topics) { %>
                                <option value="<%= topic %>"><%= topic %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
            `;
            
            container.appendChild(newQuestion);
            
            // Show remove button on first question if multiple questions exist
            if (questionCount > 1) {
                document.querySelector('#question-1 .remove-question').style.display = 'flex';
            }
        }
        
        function removeQuestion(id) {
            if (questionCount > 1) {
                const element = document.getElementById('question-' + id);
                element.remove();
                questionCount--;
                
                // Hide remove button on first question if only one remains
                if (questionCount === 1) {
                    document.querySelector('#question-1 .remove-question').style.display = 'none';
                }
            }
        }
        
        function updateSubLevel() {
            const level = document.getElementById('levelSelect').value;
            if (level) {
                window.location.href = 'addQuiz.jsp?level=' + level;
            }
        }
        
        function validateForm() {
            const level = document.getElementById('levelSelect').value;
            if (!level) {
                alert('Please select a quiz level');
                return false;
            }
            
            // Check if at least one question exists
            if (questionCount < 1) {
                alert('Please add at least one question');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>