package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/AddQuizServlet")
public class AddQuizServlet extends HttpServlet {
    
	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        System.out.println("========== ADD QUIZ SERVLET ==========");
        
        // Get quiz level and sublevel
        String level = request.getParameter("level");
        String subLevelStr = request.getParameter("sub_level");
        
        if (level == null || subLevelStr == null) {
            response.sendRedirect("addQuiz.jsp?error=Missing quiz information");
            return;
        }
        
        int subLevel = Integer.parseInt(subLevelStr);
        
        // Count how many questions were added
        int questionCount = 0;
        List<String> errors = new ArrayList<>();
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Prepare the insert statement
            String sql = "INSERT INTO questions (level, sub_level, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, topic) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            
            // Loop through questions until we don't find any more
            int qNum = 1;
            while (true) {
                String question = request.getParameter("question_" + qNum);
                if (question == null) break;
                
                String optionA = request.getParameter("option_a_" + qNum);
                String optionB = request.getParameter("option_b_" + qNum);
                String optionC = request.getParameter("option_c_" + qNum);
                String optionD = request.getParameter("option_d_" + qNum);
                String correct = request.getParameter("correct_" + qNum);
                String explanation = request.getParameter("explanation_" + qNum);
                String topic = request.getParameter("topic_" + qNum);
                
                // Validate required fields
                if (question.trim().isEmpty() || optionA.trim().isEmpty() || 
                    optionB.trim().isEmpty() || optionC.trim().isEmpty() || 
                    optionD.trim().isEmpty() || correct == null) {
                    errors.add("Question " + qNum + " has missing fields");
                    qNum++;
                    continue;
                }
                
                // Set parameters
                ps.setString(1, level);
                ps.setInt(2, subLevel);
                ps.setString(3, question);
                ps.setString(4, optionA);
                ps.setString(5, optionB);
                ps.setString(6, optionC);
                ps.setString(7, optionD);
                ps.setString(8, correct);
                ps.setString(9, explanation != null && !explanation.isEmpty() ? explanation : null);
                ps.setString(10, topic != null && !topic.isEmpty() ? topic : null);
                
                ps.executeUpdate();
                questionCount++;
                qNum++;
            }
            
            System.out.println("✅ Added " + questionCount + " questions to " + level + " level quiz " + subLevel);
            
            if (!errors.isEmpty()) {
                // Some questions had errors but we still added some
                String errorMsg = String.join(", ", errors);
                response.sendRedirect("quizzes.jsp?warning=Added " + questionCount + " questions. Issues: " + errorMsg);
            } else {
                response.sendRedirect("quizzes.jsp?success=Quiz created successfully with " + questionCount + " questions");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("addQuiz.jsp?error=Invalid sublevel format");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("addQuiz.jsp?error=Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addQuiz.jsp?error=" + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}