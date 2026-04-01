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
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // Handle delete action
    String action = request.getParameter("action");
    String message = "";
    String error = "";
    
    if ("delete".equals(action)) {
        String questionId = request.getParameter("id");
        if (questionId != null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUser, dbPass);
                
                String deleteSql = "DELETE FROM questions_new WHERE question_id = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(questionId));
                int deleted = ps.executeUpdate();
                
                if (deleted > 0) {
                    message = "Question deleted successfully!";
                } else {
                    error = "Question not found!";
                }
                
            } catch (Exception e) {
                e.printStackTrace();
                error = "Error deleting question: " + e.getMessage();
            } finally {
                if (ps != null) try { ps.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        }
    }
    
    // Get all quiz statistics
    int totalQuestions = 0;
    int beginnerCount = 0;
    int intermediateCount = 0;
    int hardCount = 0;
    int totalQuizzes = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM questions_new");
        if (rs.next()) totalQuestions = rs.getInt("count");
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM questions_new WHERE level = 'Beginner'");
        if (rs.next()) beginnerCount = rs.getInt("count");
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM questions_new WHERE level = 'Intermediate'");
        if (rs.next()) intermediateCount = rs.getInt("count");
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM questions_new WHERE level = 'Hard'");
        if (rs.next()) hardCount = rs.getInt("count");
        rs.close();
        
        // Count distinct sublevels (quizzes)
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT CONCAT(level, '_', sub_level)) as count FROM questions_new");
        if (rs.next()) totalQuizzes = rs.getInt("count");
        rs.close();
        
    } catch (Exception e) {
        e.printStackTrace();
        error = "Error loading stats: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Get all questions grouped by level and sublevel
    Map<String, Map<String, List<Map<String, Object>>>> quizzesByLevel = new LinkedHashMap<>();
    quizzesByLevel.put("Beginner", new LinkedHashMap<>());
    quizzesByLevel.put("Intermediate", new LinkedHashMap<>());
    quizzesByLevel.put("Hard", new LinkedHashMap<>());
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        rs = stmt.executeQuery("SELECT * FROM questions_new ORDER BY level, sub_level, question_id");
        
        while (rs.next()) {
            Map<String, Object> question = new HashMap<>();
            question.put("question_id", rs.getInt("question_id"));
            question.put("question_text", rs.getString("question_text"));
            question.put("option1", rs.getString("option1"));
            question.put("option2", rs.getString("option2"));
            question.put("option3", rs.getString("option3"));
            question.put("option4", rs.getString("option4"));
            question.put("correct_option", rs.getString("correct_option"));
            question.put("explanation", rs.getString("explanation"));
            question.put("topic", rs.getString("topic"));
            
            String level = rs.getString("level");
            String subLevel = rs.getString("sub_level");
            
            if (!quizzesByLevel.get(level).containsKey(subLevel)) {
                quizzesByLevel.get(level).put(subLevel, new ArrayList<>());
            }
            
            quizzesByLevel.get(level).get(subLevel).add(question);
        }
        rs.close();
        
    } catch (Exception e) {
        e.printStackTrace();
        error = "Error loading quizzes: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Quizzes | CyberSphere Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Copy all the styles from the previous quizzes.jsp */
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
            max-width: 1400px;
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
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.2s ease;
        }
        
        .stat-card:hover {
            border-color: #44634d;
            transform: translateY(-2px);
        }
        
        .stat-icon {
            width: 40px;
            height: 40px;
            background: #1a1e24;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 15px;
        }
        
        .stat-icon i {
            font-size: 20px;
            color: #44634d;
        }
        
        .stat-label {
            color: #9ca3af;
            font-size: 13px;
            margin-bottom: 5px;
        }
        
        .stat-number {
            color: #ffffff;
            font-size: 24px;
            font-weight: 600;
        }
        
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
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
        
        .level-section {
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 25px;
        }
        
        .level-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .level-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        
        .level-icon.beginner {
            background: #1a2e1a;
            color: #86efac;
        }
        
        .level-icon.intermediate {
            background: #2c2415;
            color: #fbbf24;
        }
        
        .level-icon.hard {
            background: #2c1515;
            color: #f87171;
        }
        
        .level-title {
            flex: 1;
        }
        
        .level-title h2 {
            color: #ffffff;
            font-size: 24px;
            margin-bottom: 5px;
        }
        
        .level-title p {
            color: #9ca3af;
            font-size: 14px;
        }
        
        .quizzes-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .quiz-card {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.2s ease;
        }
        
        .quiz-card:hover {
            transform: translateY(-3px);
            border-color: #44634d;
            box-shadow: 0 10px 20px -10px rgba(68, 99, 77, 0.2);
        }
        
        .quiz-header {
            background: #1f242b;
            padding: 15px 20px;
            border-bottom: 1px solid #2a2f3a;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .quiz-header h3 {
            color: #ffffff;
            font-size: 16px;
        }
        
        .quiz-badge {
            background: #44634d;
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .quiz-body {
            padding: 20px;
        }
        
        .question-count {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #9ca3af;
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        .question-count i {
            color: #44634d;
        }
        
        .topic-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 15px;
        }
        
        .topic-tag {
            background: #1f242b;
            color: #9ca3af;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            border: 1px solid #2a2f3a;
        }
        
        .quiz-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        
        .quiz-action-btn {
            flex: 1;
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #2a2f3a;
            background: #1f242b;
            color: #9ca3af;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            font-size: 12px;
        }
        
        .quiz-action-btn:hover {
            background: #44634d;
            color: white;
            border-color: #44634d;
        }
        
        .quiz-action-btn.delete:hover {
            background: #ef4444;
            border-color: #ef4444;
        }
        
        .questions-table {
            margin-top: 20px;
            background: #0f1115;
            border: 1px solid #1e1e1e;
            border-radius: 12px;
            overflow: hidden;
            display: none;
        }
        
        .questions-table.visible {
            display: block;
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background: #1a1e24;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .table-header h4 {
            color: #ffffff;
            font-size: 16px;
        }
        
        .close-table {
            color: #9ca3af;
            cursor: pointer;
            transition: color 0.2s ease;
        }
        
        .close-table:hover {
            color: #ef4444;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            text-align: left;
            padding: 15px 10px;
            color: #9ca3af;
            font-weight: 500;
            border-bottom: 1px solid #1e1e1e;
            background: #1a1e24;
        }
        
        td {
            padding: 15px 10px;
            color: #e5e7eb;
            border-bottom: 1px solid #1e1e1e;
        }
        
        .question-text {
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .options-preview {
            display: flex;
            gap: 5px;
            font-size: 12px;
        }
        
        .option {
            background: #1f242b;
            padding: 3px 8px;
            border-radius: 4px;
            color: #9ca3af;
        }
        
        .option.correct {
            background: #1a2e1a;
            color: #86efac;
            border: 1px solid #2a4a2a;
        }
        
        .table-actions {
            display: flex;
            gap: 8px;
        }
        
        .table-action-btn {
            color: #9ca3af;
            text-decoration: none;
            transition: color 0.2s ease;
        }
        
        .table-action-btn:hover {
            color: #44634d;
        }
        
        .table-action-btn.delete:hover {
            color: #ef4444;
        }
        
        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        
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
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .quizzes-grid {
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
        
        <!-- Alert Messages -->
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
        <% } %>
        
        <% if (!error.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>
        
        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-layer-group"></i>
                </div>
                <div class="stat-label">Total Quizzes</div>
                <div class="stat-number"><%= totalQuizzes %></div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-question"></i>
                </div>
                <div class="stat-label">Total Questions</div>
                <div class="stat-number"><%= totalQuestions %></div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-seedling"></i>
                </div>
                <div class="stat-label">Beginner</div>
                <div class="stat-number"><%= beginnerCount %></div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-label">Intermediate</div>
                <div class="stat-number"><%= intermediateCount %></div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-skull"></i>
                </div>
                <div class="stat-label">Hard</div>
                <div class="stat-number"><%= hardCount %></div>
            </div>
        </div>
        
        <!-- Action Bar -->
        <div class="action-bar">
            <div>
                <span style="color: #9ca3af;">Manage all quiz questions and levels</span>
            </div>
            <a href="addQuiz.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add New Quiz
            </a>
        </div>
        
        <!-- Quiz Levels -->
        <%
            String[] levels = {"Beginner", "Intermediate", "Hard"};
            String[] levelNames = {"Beginner", "Intermediate", "Hard"};
            String[] levelIcons = {"fa-seedling", "fa-chart-line", "fa-skull"};
            String[] levelColors = {"beginner", "intermediate", "hard"};
            
            for (int l = 0; l < levels.length; l++) {
                String level = levels[l];
                String levelName = levelNames[l];
                String levelIcon = levelIcons[l];
                String levelColor = levelColors[l];
                
                Map<String, List<Map<String, Object>>> levelQuizzes = quizzesByLevel.get(level);
                if (levelQuizzes != null && !levelQuizzes.isEmpty()) {
        %>
        <div class="level-section">
            <div class="level-header">
                <div class="level-icon <%= levelColor %>">
                    <i class="fas <%= levelIcon %>"></i>
                </div>
                <div class="level-title">
                    <h2><%= levelName %> Level</h2>
                    <p><%= levelQuizzes.size() %> quizzes • 
                    <% if ("Beginner".equals(level)) { %><%= beginnerCount %><% } 
                       else if ("Intermediate".equals(level)) { %><%= intermediateCount %><% } 
                       else { %><%= hardCount %><% } %> questions</p>
                </div>
            </div>
            
            <div class="quizzes-grid">
                <%
                    for (Map.Entry<String, List<Map<String, Object>>> entry : levelQuizzes.entrySet()) {
                        String subLevel = entry.getKey();
                        List<Map<String, Object>> questions = entry.getValue();
                        
                        // Get unique topics
                        Set<String> topics = new HashSet<>();
                        for (Map<String, Object> q : questions) {
                            if (q.get("topic") != null && !((String)q.get("topic")).isEmpty()) {
                                topics.add((String) q.get("topic"));
                            }
                        }
                        
                        // Extract sublevel number for display
                        String subLevelDisplay = subLevel.replace("Level_", "");
                %>
                <div class="quiz-card">
                    <div class="quiz-header">
                        <h3>Level <%= subLevelDisplay %></h3>
                        <span class="quiz-badge"><%= questions.size() %> questions</span>
                    </div>
                    <div class="quiz-body">
                        <div class="question-count">
                            <i class="fas fa-question-circle"></i>
                            <span><%= questions.size() %> questions</span>
                        </div>
                        
                        <% if (!topics.isEmpty()) { %>
                        <div class="topic-list">
                            <% for (String topic : topics) { %>
                                <span class="topic-tag"><%= topic %></span>
                            <% } %>
                        </div>
                        <% } %>
                        
                        <div class="quiz-actions">
                            <a href="#" class="quiz-action-btn" onclick="viewQuestions('<%= level %>', '<%= subLevel %>'); return false;">
                                <i class="fas fa-eye"></i> View
                            </a>
                            <a href="editQuiz.jsp?level=<%= level %>&sublevel=<%= subLevel %>" class="quiz-action-btn">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <a href="#" class="quiz-action-btn delete" onclick="deleteQuiz('<%= level %>', '<%= subLevel %>'); return false;">
                                <i class="fas fa-trash"></i> Delete
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Questions Table (hidden) -->
                <div id="questions-<%= level %>-<%= subLevel %>" class="questions-table">
                    <div class="table-header">
                        <h4><i class="fas fa-list"></i> <%= levelName %> Level <%= subLevelDisplay %> - Questions</h4>
                        <span class="close-table" onclick="hideQuestions('<%= level %>', '<%= subLevel %>')">&times;</span>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Question</th>
                                <th>Options</th>
                                <th>Correct</th>
                                <th>Topic</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> q : questions) { 
                                String correct = (String) q.get("correct_option");
                            %>
                            <tr>
                                <td>#<%= q.get("question_id") %></td>
                                <td class="question-text"><%= q.get("question_text") %></td>
                                <td>
                                    <div class="options-preview">
                                        <span class="option <%= "1".equals(correct) || "option1".equals(correct) ? "correct" : "" %>">1</span>
                                        <span class="option <%= "2".equals(correct) || "option2".equals(correct) ? "correct" : "" %>">2</span>
                                        <span class="option <%= "3".equals(correct) || "option3".equals(correct) ? "correct" : "" %>">3</span>
                                        <span class="option <%= "4".equals(correct) || "option4".equals(correct) ? "correct" : "" %>">4</span>
                                    </div>
                                </td>
                                <td><span style="color: #86efac;"><%= correct %></span></td>
                                <td><%= q.get("topic") != null ? q.get("topic") : "General" %></td>
                                <td class="table-actions">
                                    <a href="editQuestion.jsp?id=<%= q.get("question_id") %>" class="table-action-btn">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="quizzes.jsp?action=delete&id=<%= q.get("question_id") %>" class="table-action-btn delete" onclick="return confirm('Delete this question?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>
        <%
                }
            }
            
            if (totalQuestions == 0) {
        %>
        <div style="text-align: center; padding: 60px; background: #0f1115; border-radius: 16px; border: 1px solid #1e1e1e;">
            <i class="fas fa-question-circle" style="font-size: 60px; color: #44634d; opacity: 0.5; margin-bottom: 20px;"></i>
            <h3 style="color: #ffffff; margin-bottom: 10px;">No Quizzes Found</h3>
            <p style="color: #9ca3af; margin-bottom: 20px;">Get started by creating your first quiz.</p>
            <a href="addQuiz.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add New Quiz
            </a>
        </div>
        <% } %>
    </div>
    
    <script>
        function viewQuestions(level, subLevel) {
            // Hide all question tables first
            document.querySelectorAll('.questions-table').forEach(table => {
                table.classList.remove('visible');
            });
            
            // Show the selected table
            const tableId = 'questions-' + level + '-' + subLevel;
            document.getElementById(tableId).classList.add('visible');
            
            // Scroll to the table
            document.getElementById(tableId).scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        function hideQuestions(level, subLevel) {
            const tableId = 'questions-' + level + '-' + subLevel;
            document.getElementById(tableId).classList.remove('visible');
        }
        
        function deleteQuiz(level, subLevel) {
            if (confirm('Are you sure you want to delete all questions in this quiz? This action cannot be undone!')) {
                window.location.href = 'deleteQuiz.jsp?level=' + level + '&sublevel=' + subLevel;
            }
        }
    </script>
</body>
</html>