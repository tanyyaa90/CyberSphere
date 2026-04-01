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
    
    String level = request.getParameter("level");
    String sublevel = request.getParameter("sublevel");
    
    if (level == null || sublevel == null) {
        response.sendRedirect("quizzes.jsp?error=Missing quiz information");
        return;
    }
    
    // Database connection
    String url = "jdbc:mysql://localhost:3306/cybersphere";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // Get all topics
    List<String> topics = new ArrayList<>();
    List<Map<String, Object>> questions = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        
        // Get topics
        rs = stmt.executeQuery("SELECT name FROM topics ORDER BY name");
        while (rs.next()) {
            topics.add(rs.getString("name"));
        }
        rs.close();
        
        // Get questions for this quiz
        ps = conn.prepareStatement("SELECT * FROM questions_new WHERE level = ? AND sub_level = ? ORDER BY question_id");
        ps.setString(1, level);
        ps.setString(2, sublevel);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> q = new HashMap<>();
            q.put("question_id", rs.getInt("question_id"));
            q.put("question_text", rs.getString("question_text"));
            q.put("option1", rs.getString("option1"));
            q.put("option2", rs.getString("option2"));
            q.put("option3", rs.getString("option3"));
            q.put("option4", rs.getString("option4"));
            q.put("correct_option", rs.getString("correct_option"));
            q.put("explanation", rs.getString("explanation"));
            q.put("topic", rs.getString("topic"));
            questions.add(q);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Quiz | CyberSphere Admin</title>
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
            max-width: 1000px;
            margin: 0 auto;
        }
        
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .quiz-badge {
            background: #1a2e1a;
            color: #86efac;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 14px;
            border: 1px solid #2a4a2a;
        }
        
        .quiz-info {
            background: #1a2e1a;
            border: 1px solid #2a4a2a;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
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
        
        .question-card {
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
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
            background: #0f1115;
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
        
        .options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin: 15px 0;
        }
        
        .option-card {
            background: #0f1115;
            border: 1px solid #2a2f3a;
            border-radius: 10px;
            padding: 15px;
        }
        
        .option-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        
        .option-number {
            background: #1a1e24;
            color: #9ca3af;
            width: 28px;
            height: 28px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            border: 1px solid #2a2f3a;
        }
        
        .option-number.correct {
            background: #1a2e1a;
            color: #86efac;
            border-color: #2a4a2a;
        }
        
        .correct-radio {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .correct-radio input[type="radio"] {
            width: 16px;
            height: 16px;
            cursor: pointer;
            accent-color: #44634d;
        }
        
        .correct-radio label {
            color: #9ca3af;
            font-size: 12px;
            margin-bottom: 0;
            cursor: pointer;
        }
        
        .option-text {
            width: 100%;
            padding: 10px 12px;
            background: #1a1e24;
            border: 1px solid #2a2f3a;
            border-radius: 6px;
            color: #ffffff;
            font-size: 13px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
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
            
            .options-grid {
                grid-template-columns: 1fr;
            }
            
            .form-row {
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
                <h1><i class="fas fa-edit"></i> Edit Quiz</h1>
            </div>
            <div class="admin-profile">
                <img src="<%= profileImage %>" alt="Admin">
                <span>Welcome, <%= firstName %></span>
            </div>
        </div>
        
        <div class="form-container">
            <div class="form-title">
                <span><i class="fas fa-layer-group"></i> Editing: <%= level %> Level - Quiz <%= sublevel %></span>
                <span class="quiz-badge"><%= questions.size() %> questions</span>
            </div>
            
            <div class="quiz-info">
                <i class="fas fa-info-circle"></i>
                <p>You are editing <strong><%= questions.size() %></strong> questions for <strong><%= level %> level, quiz #<%= sublevel %></strong></p>
            </div>
            
            <form action="UpdateQuizServlet" method="post">
                <input type="hidden" name="level" value="<%= level %>">
                <input type="hidden" name="sublevel" value="<%= sublevel %>">
                
                <div id="questions-container">
                    <% if (questions.isEmpty()) { %>
                        <div style="text-align: center; padding: 40px; color: #9ca3af;">
                            <i class="fas fa-info-circle"></i> No questions found for this quiz.
                        </div>
                    <% } else { %>
                        <% for (int i = 0; i < questions.size(); i++) { 
                            Map<String, Object> q = questions.get(i);
                            int qNum = i + 1;
                            String correctOption = (String) q.get("correct_option");
                        %>
                        <div class="question-card">
                            <div class="question-header">
                                <h3><i class="fas fa-question"></i> Question #<%= qNum %></h3>
                            </div>
                            
                            <input type="hidden" name="question_id_<%= qNum %>" value="<%= q.get("question_id") %>">
                            
                            <div class="form-group">
                                <label><i class="fas fa-question-circle"></i> Question Text</label>
                                <textarea class="form-control" name="question_<%= qNum %>" rows="3" required><%= q.get("question_text") %></textarea>
                            </div>
                            
                            <label><i class="fas fa-list"></i> Answer Options (Select the correct one)</label>
                            <div class="options-grid">
                                <!-- Option 1 -->
                                <div class="option-card">
                                    <div class="option-header">
                                        <div class="option-number <%= "1".equals(correctOption) ? "correct" : "" %>">1</div>
                                        <div class="correct-radio">
                                            <input type="radio" name="correct_<%= qNum %>" value="1" id="opt1_<%= qNum %>" <%= "1".equals(correctOption) ? "checked" : "" %> required>
                                            <label for="opt1_<%= qNum %>">Correct Answer</label>
                                        </div>
                                    </div>
                                    <input type="text" class="option-text" name="option1_<%= qNum %>" value="<%= q.get("option1") %>" placeholder="Option 1" required>
                                </div>
                                
                                <!-- Option 2 -->
                                <div class="option-card">
                                    <div class="option-header">
                                        <div class="option-number <%= "2".equals(correctOption) ? "correct" : "" %>">2</div>
                                        <div class="correct-radio">
                                            <input type="radio" name="correct_<%= qNum %>" value="2" id="opt2_<%= qNum %>" <%= "2".equals(correctOption) ? "checked" : "" %> required>
                                            <label for="opt2_<%= qNum %>">Correct Answer</label>
                                        </div>
                                    </div>
                                    <input type="text" class="option-text" name="option2_<%= qNum %>" value="<%= q.get("option2") %>" placeholder="Option 2" required>
                                </div>
                                
                                <!-- Option 3 -->
                                <div class="option-card">
                                    <div class="option-header">
                                        <div class="option-number <%= "3".equals(correctOption) ? "correct" : "" %>">3</div>
                                        <div class="correct-radio">
                                            <input type="radio" name="correct_<%= qNum %>" value="3" id="opt3_<%= qNum %>" <%= "3".equals(correctOption) ? "checked" : "" %> required>
                                            <label for="opt3_<%= qNum %>">Correct Answer</label>
                                        </div>
                                    </div>
                                    <input type="text" class="option-text" name="option3_<%= qNum %>" value="<%= q.get("option3") %>" placeholder="Option 3" required>
                                </div>
                                
                                <!-- Option 4 -->
                                <div class="option-card">
                                    <div class="option-header">
                                        <div class="option-number <%= "4".equals(correctOption) ? "correct" : "" %>">4</div>
                                        <div class="correct-radio">
                                            <input type="radio" name="correct_<%= qNum %>" value="4" id="opt4_<%= qNum %>" <%= "4".equals(correctOption) ? "checked" : "" %> required>
                                            <label for="opt4_<%= qNum %>">Correct Answer</label>
                                        </div>
                                    </div>
                                    <input type="text" class="option-text" name="option4_<%= qNum %>" value="<%= q.get("option4") %>" placeholder="Option 4" required>
                                </div>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label><i class="fas fa-info-circle"></i> Explanation</label>
                                    <textarea class="form-control" name="explanation_<%= qNum %>" rows="2" placeholder="Explain why this answer is correct"><%= q.get("explanation") != null ? q.get("explanation") : "" %></textarea>
                                </div>
                                
                                <div class="form-group">
                                    <label><i class="fas fa-tag"></i> Topic</label>
                                    <select class="form-control" name="topic_<%= qNum %>">
                                        <option value="">Select Topic</option>
                                        <% for (String topic : topics) { %>
                                            <option value="<%= topic %>" <%= topic.equals(q.get("topic")) ? "selected" : "" %>><%= topic %></option>
                                        <% } %>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
                
                <div class="action-buttons">
                    <a href="quizzes.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <% if (!questions.isEmpty()) { %>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    <% } %>
                </div>
            </form>
        </div>
    </div>
</body>
</html>