package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/UpdateQuizServlet")
public class UpdateQuizServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        System.out.println("========== UPDATE QUIZ SERVLET ==========");
        
        // Get quiz level and sublevel
        String level = request.getParameter("level");
        String subLevelStr = request.getParameter("sublevel");
        
        if (level == null || subLevelStr == null) {
            response.sendRedirect("quizzes.jsp?error=Missing quiz information");
            return;
        }
        
        int subLevel = Integer.parseInt(subLevelStr);
        
        Connection conn = null;
        PreparedStatement ps = null;
        int updatedCount = 0;
        List<String> errors = new ArrayList<>();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Loop through questions
            int qNum = 1;
            while (true) {
                String questionIdStr = request.getParameter("question_id_" + qNum);
                if (questionIdStr == null) break;
                
                int questionId = Integer.parseInt(questionIdStr);
                String question = request.getParameter("question_" + qNum);
                String optionA = request.getParameter("option_a_" + qNum);
                String optionB = request.getParameter("option_b_" + qNum);
                String optionC = request.getParameter("option_c_" + qNum);
                String optionD = request.getParameter("option_d_" + qNum);
                String correct = request.getParameter("correct_" + qNum);
                String explanation = request.getParameter("explanation_" + qNum);
                String topic = request.getParameter("topic_" + qNum);
                
                // Validate required fields
                if (question == null || optionA == null || optionB == null || 
                    optionC == null || optionD == null || correct == null) {
                    errors.add("Question ID " + questionId + " has missing fields");
                    qNum++;
                    continue;
                }
                
                // Update question
                String sql = "UPDATE questions SET question_text = ?, option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_answer = ?, explanation = ?, topic = ? WHERE id = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, question);
                ps.setString(2, optionA);
                ps.setString(3, optionB);
                ps.setString(4, optionC);
                ps.setString(5, optionD);
                ps.setString(6, correct);
                ps.setString(7, explanation != null && !explanation.isEmpty() ? explanation : null);
                ps.setString(8, topic != null && !topic.isEmpty() ? topic : null);
                ps.setInt(9, questionId);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    updatedCount++;
                }
                ps.close();
                
                qNum++;
            }
            
            System.out.println("✅ Updated " + updatedCount + " questions in " + level + " level quiz " + subLevel);
            
            if (!errors.isEmpty()) {
                String errorMsg = String.join(", ", errors);
                response.sendRedirect("quizzes.jsp?warning=Updated " + updatedCount + " questions. Issues: " + errorMsg);
            } else {
                response.sendRedirect("quizzes.jsp?success=Quiz updated successfully (" + updatedCount + " questions)");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("quizzes.jsp?error=Invalid number format");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("quizzes.jsp?error=Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("quizzes.jsp?error=" + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}