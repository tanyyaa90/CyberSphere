<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in AND is admin
    String role = (String) session.getAttribute("role");
    Integer currentUserId = (Integer) session.getAttribute("userId");
    Boolean isMainAdmin = (Boolean) session.getAttribute("isMainAdmin");
    Boolean canManageQuizzes = (Boolean) session.getAttribute("can_manage_quizzes");
    
    if (currentUserId == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if admin has permission to manage quizzes
    if (!isMainAdmin && (canManageQuizzes == null || !canManageQuizzes)) {
        response.sendRedirect("admin_home.jsp?error=You don't have permission to manage quizzes");
        return;
    }
    
    String firstName = (String) session.getAttribute("firstName");
    String profileImage = (String) session.getAttribute("profileImage");
    if (profileImage == null) profileImage = "https://i.ibb.co/6RfWN4zJ/buddy-10158022.png";
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere?zeroDateTimeBehavior=convertToNull";
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
        
        // Handle Add Question
        if ("add".equals(action)) {
            String level = request.getParameter("level");
            String subLevel = request.getParameter("sub_level");
            String questionText = request.getParameter("question_text");
            String optionA = request.getParameter("option_a");
            String optionB = request.getParameter("option_b");
            String optionC = request.getParameter("option_c");
            String optionD = request.getParameter("option_d");
            String correctAnswer = request.getParameter("correct_answer");
            String explanation = request.getParameter("explanation");
            String topic = request.getParameter("topic");
            
            if (questionText != null && !questionText.trim().isEmpty()) {
                String insertSql = "INSERT INTO questions_new (level, sub_level, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, topic, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, level);
                ps.setInt(2, Integer.parseInt(subLevel));
                ps.setString(3, questionText);
                ps.setString(4, optionA);
                ps.setString(5, optionB);
                ps.setString(6, optionC);
                ps.setString(7, optionD);
                ps.setString(8, correctAnswer);
                ps.setString(9, explanation);
                ps.setString(10, topic);
                ps.executeUpdate();
                successMsg = "Question added successfully!";
            } else {
                errorMsg = "Question text is required";
            }
            if (ps != null) ps.close();
        }
        
        // Handle Delete Question
        if ("delete".equals(action)) {
            String questionId = request.getParameter("id");
            if (questionId != null) {
                String deleteSql = "DELETE FROM questions_new WHERE id = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(questionId));
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    successMsg = "Question deleted successfully";
                }
                ps.close();
            }
        }
        
        // Handle Edit Question
        if ("edit".equals(action)) {
            String questionId = request.getParameter("id");
            String level = request.getParameter("level");
            String subLevel = request.getParameter("sub_level");
            String questionText = request.getParameter("question_text");
            String optionA = request.getParameter("option_a");
            String optionB = request.getParameter("option_b");
            String optionC = request.getParameter("option_c");
            String optionD = request.getParameter("option_d");
            String correctAnswer = request.getParameter("correct_answer");
            String explanation = request.getParameter("explanation");
            String topic = request.getParameter("topic");
            
            if (questionId != null && questionText != null && !questionText.trim().isEmpty()) {
                String updateSql = "UPDATE questions_new SET level = ?, sub_level = ?, question_text = ?, option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_answer = ?, explanation = ?, topic = ? WHERE id = ?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, level);
                ps.setInt(2, Integer.parseInt(subLevel));
                ps.setString(3, questionText);
                ps.setString(4, optionA);
                ps.setString(5, optionB);
                ps.setString(6, optionC);
                ps.setString(7, optionD);
                ps.setString(8, correctAnswer);
                ps.setString(9, explanation);
                ps.setString(10, topic);
                ps.setInt(11, Integer.parseInt(questionId));
                ps.executeUpdate();
                successMsg = "Question updated successfully!";
                ps.close();
            } else {
                errorMsg = "Question text is required";
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Database error: " + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Fetch all questions
    List<Map<String, Object>> questionsList = new ArrayList<>();
    Map<String, Integer> questionCounts = new HashMap<>();
    questionCounts.put("beginner", 0);
    questionCounts.put("intermediate", 0);
    questionCounts.put("hard", 0);
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        String questionsSql = "SELECT * FROM questions_new ORDER BY level, sub_level, id";
        rs = stmt.executeQuery(questionsSql);
        
        while (rs.next()) {
            Map<String, Object> question = new HashMap<>();
            question.put("id", rs.getInt("id"));
            question.put("level", rs.getString("level"));
            question.put("sub_level", rs.getInt("sub_level"));
            question.put("question_text", rs.getString("question_text"));
            question.put("option_a", rs.getString("option_a"));
            question.put("option_b", rs.getString("option_b"));
            question.put("option_c", rs.getString("option_c"));
            question.put("option_d", rs.getString("option_d"));
            question.put("correct_answer", rs.getString("correct_answer"));
            question.put("explanation", rs.getString("explanation"));
            question.put("topic", rs.getString("topic"));
            
            String level = rs.getString("level");
            if (level != null) {
                questionCounts.put(level, questionCounts.getOrDefault(level, 0) + 1);
            }
            
            questionsList.add(question);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Error loading questions: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Quizzes | CyberSphere</title>
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-card i {
            font-size: 28px;
            color: #44634d;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 28px;
            font-weight: 600;
            color: #ffffff;
        }
        
        .stat-label {
            color: #9ca3af;
            font-size: 12px;
            margin-top: 5px;
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
        
        .questions-table {
            width: 100%;
            border-collapse: collapse;
            overflow-x: auto;
            display: block;
        }
        
        .questions-table thead {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .questions-table tbody {
            display: block;
            max-height: 500px;
            overflow-y: auto;
            width: 100%;
        }
        
        .questions-table tr {
            display: table;
            width: 100%;
            table-layout: fixed;
        }
        
        .questions-table th {
            text-align: left;
            padding: 12px;
            color: #9ca3af;
            font-weight: 500;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .questions-table td {
            padding: 12px;
            color: #e5e7eb;
            border-bottom: 1px solid #1e1e1e;
            vertical-align: middle;
        }
        
        .level-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 500;
        }
        
        .level-badge.beginner {
            background: #1a2e1a;
            color: #86efac;
        }
        
        .level-badge.intermediate {
            background: #332a1a;
            color: #fbbf24;
        }
        
        .level-badge.hard {
            background: #2c1515;
            color: #f87171;
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
        
        .correct-answer-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            background: #1a2e1a;
            color: #86efac;
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
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="header">
            <div class="header-left">
                <h1><i class="fas fa-question-circle"></i> Manage Quizzes</h1>
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
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <i class="fas fa-layer-group"></i>
                <div class="stat-number"><%= questionCounts.getOrDefault("beginner", 0) %></div>
                <div class="stat-label">Beginner Questions</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-chart-line"></i>
                <div class="stat-number"><%= questionCounts.getOrDefault("intermediate", 0) %></div>
                <div class="stat-label">Intermediate Questions</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-tachometer-alt"></i>
                <div class="stat-number"><%= questionCounts.getOrDefault("hard", 0) %></div>
                <div class="stat-label">Hard Questions</div>
            </div>
        </div>
        
        <!-- Add New Question Form -->
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-plus-circle"></i> Add New Question</h2>
            </div>
            <div class="card-body">
                <form method="post" action="manageQuizzes.jsp">
                    <input type="hidden" name="action" value="add">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Difficulty Level *</label>
                            <select name="level" class="form-control" required>
                                <option value="beginner">Beginner</option>
                                <option value="intermediate">Intermediate</option>
                                <option value="hard">Hard</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Sub Level (1-5) *</label>
                            <select name="sub_level" class="form-control" required>
                                <option value="1">Level 1</option>
                                <option value="2">Level 2</option>
                                <option value="3">Level 3</option>
                                <option value="4">Level 4</option>
                                <option value="5">Level 5</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Question Text *</label>
                        <textarea name="question_text" class="form-control" rows="3" required placeholder="Enter the question"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Topic</label>
                        <input type="text" name="topic" class="form-control" placeholder="e.g., Phishing, Passwords, Malware">
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Option A *</label>
                            <input type="text" name="option_a" class="form-control" required placeholder="Option A">
                        </div>
                        <div class="form-group">
                            <label>Option B *</label>
                            <input type="text" name="option_b" class="form-control" required placeholder="Option B">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Option C</label>
                            <input type="text" name="option_c" class="form-control" placeholder="Option C">
                        </div>
                        <div class="form-group">
                            <label>Option D</label>
                            <input type="text" name="option_d" class="form-control" placeholder="Option D">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Correct Answer *</label>
                            <select name="correct_answer" class="form-control" required>
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Explanation (Optional)</label>
                            <textarea name="explanation" class="form-control" rows="2" placeholder="Explain why this answer is correct"></textarea>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Add Question
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Existing Questions List -->
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-list"></i> Existing Questions</h2>
                <span style="color: #9ca3af;"><i class="fas fa-database"></i> Total: <%= questionsList.size() %></span>
            </div>
            <div class="card-body">
                <% if (questionsList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-folder-open"></i>
                        <h3>No Questions Yet</h3>
                        <p>Add your first quiz question using the form above</p>
                    </div>
                <% } else { %>
                    <table class="questions-table">
                        <thead>
                            <tr>
                                <th>Level</th>
                                <th>Q#</th>
                                <th>Question</th>
                                <th>Topic</th>
                                <th>Correct</th>
                                <th>Actions</th>
                            </thead>
                        <tbody>
                            <% for (Map<String, Object> question : questionsList) { 
                                String level = (String) question.get("level");
                                int questionId = (Integer) question.get("id");
                                int subLevel = (Integer) question.get("sub_level");
                                String questionText = (String) question.get("question_text");
                                if (questionText.length() > 60) {
                                    questionText = questionText.substring(0, 60) + "...";
                                }
                            %>
                            <tr id="row-<%= questionId %>">
                                <td>
                                    <span class="level-badge <%= level %>">
                                        <%= level != null ? level.toUpperCase() : "N/A" %>
                                    </span>
                                </td>
                                <td>L<%= subLevel %></td>
                                <td title="<%= question.get("question_text") %>"><%= questionText %></td>
                                <td><%= question.get("topic") != null ? question.get("topic") : "General" %></td>
                                <td><span class="correct-answer-badge">Option <%= question.get("correct_answer") %></span></td>
                                <td class="action-icons">
                                    <a href="#" onclick="showEditForm(<%= questionId %>)" class="action-icon edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="manageQuizzes.jsp?action=delete&id=<%= questionId %>" class="action-icon delete" 
                                       onclick="return confirm('Are you sure you want to delete this question?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <tr id="edit-form-<%= questionId %>" style="display: none;">
                                <td colspan="6">
                                    <div class="edit-form">
                                        <form method="post" action="manageQuizzes.jsp">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= questionId %>">
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Difficulty Level</label>
                                                    <select name="level" class="form-control">
                                                        <option value="beginner" <%= "beginner".equals(level) ? "selected" : "" %>>Beginner</option>
                                                        <option value="intermediate" <%= "intermediate".equals(level) ? "selected" : "" %>>Intermediate</option>
                                                        <option value="hard" <%= "hard".equals(level) ? "selected" : "" %>>Hard</option>
                                                    </select>
                                                </div>
                                                <div class="form-group">
                                                    <label>Sub Level</label>
                                                    <select name="sub_level" class="form-control">
                                                        <option value="1" <%= subLevel == 1 ? "selected" : "" %>>Level 1</option>
                                                        <option value="2" <%= subLevel == 2 ? "selected" : "" %>>Level 2</option>
                                                        <option value="3" <%= subLevel == 3 ? "selected" : "" %>>Level 3</option>
                                                        <option value="4" <%= subLevel == 4 ? "selected" : "" %>>Level 4</option>
                                                        <option value="5" <%= subLevel == 5 ? "selected" : "" %>>Level 5</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label>Question Text</label>
                                                <textarea name="question_text" class="form-control" rows="3" required><%= question.get("question_text") %></textarea>
                                            </div>
                                            <div class="form-group">
                                                <label>Topic</label>
                                                <input type="text" name="topic" class="form-control" value="<%= question.get("topic") != null ? question.get("topic") : "" %>">
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Option A</label>
                                                    <input type="text" name="option_a" class="form-control" value="<%= question.get("option_a") != null ? question.get("option_a") : "" %>" required>
                                                </div>
                                                <div class="form-group">
                                                    <label>Option B</label>
                                                    <input type="text" name="option_b" class="form-control" value="<%= question.get("option_b") != null ? question.get("option_b") : "" %>" required>
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Option C</label>
                                                    <input type="text" name="option_c" class="form-control" value="<%= question.get("option_c") != null ? question.get("option_c") : "" %>">
                                                </div>
                                                <div class="form-group">
                                                    <label>Option D</label>
                                                    <input type="text" name="option_d" class="form-control" value="<%= question.get("option_d") != null ? question.get("option_d") : "" %>">
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Correct Answer</label>
                                                    <select name="correct_answer" class="form-control">
                                                        <option value="A" <%= "A".equals(question.get("correct_answer")) ? "selected" : "" %>>A</option>
                                                        <option value="B" <%= "B".equals(question.get("correct_answer")) ? "selected" : "" %>>B</option>
                                                        <option value="C" <%= "C".equals(question.get("correct_answer")) ? "selected" : "" %>>C</option>
                                                        <option value="D" <%= "D".equals(question.get("correct_answer")) ? "selected" : "" %>>D</option>
                                                    </select>
                                                </div>
                                                <div class="form-group">
                                                    <label>Explanation</label>
                                                    <textarea name="explanation" class="form-control" rows="2"><%= question.get("explanation") != null ? question.get("explanation") : "" %></textarea>
                                                </div>
                                            </div>
                                            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                                                <button type="button" class="btn btn-secondary btn-sm" onclick="hideEditForm(<%= questionId %>)">
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
        function showEditForm(questionId) {
            const editForm = document.getElementById('edit-form-' + questionId);
            if (editForm.style.display === 'none') {
                editForm.style.display = 'table-row';
            } else {
                editForm.style.display = 'none';
            }
        }
        
        function hideEditForm(questionId) {
            document.getElementById('edit-form-' + questionId).style.display = 'none';
        }
    </script>
</body>
</html>