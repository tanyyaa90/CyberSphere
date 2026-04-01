package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/UpdateQuestionServlet")
public class UpdateQuestionServlet extends HttpServlet {
    
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
        
        System.out.println("========== UPDATE QUESTION SERVLET ==========");
        
        // Get form parameters
        String questionIdStr = request.getParameter("question_id");
        String level = request.getParameter("level");
        String subLevel = request.getParameter("sub_level");
        String questionText = request.getParameter("question_text");
        String option1 = request.getParameter("option1");
        String option2 = request.getParameter("option2");
        String option3 = request.getParameter("option3");
        String option4 = request.getParameter("option4");
        String correctOption = request.getParameter("correct_option");
        String explanation = request.getParameter("explanation");
        String topic = request.getParameter("topic");
        
        // Validate required fields
        if (questionIdStr == null || questionText == null || option1 == null || 
            option2 == null || option3 == null || option4 == null || correctOption == null) {
            response.sendRedirect("quizzes.jsp?error=Missing required fields");
            return;
        }
        
        int questionId = Integer.parseInt(questionIdStr);
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String sql = "UPDATE questions_new SET question_text = ?, option1 = ?, option2 = ?, option3 = ?, option4 = ?, correct_option = ?, explanation = ?, topic = ? WHERE question_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, questionText);
            ps.setString(2, option1);
            ps.setString(3, option2);
            ps.setString(4, option3);
            ps.setString(5, option4);
            ps.setString(6, correctOption);
            ps.setString(7, explanation != null && !explanation.isEmpty() ? explanation : null);
            ps.setString(8, topic != null && !topic.isEmpty() ? topic : null);
            ps.setInt(9, questionId);
            
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
                System.out.println("✅ Updated question ID: " + questionId);
                response.sendRedirect("quizzes.jsp?success=Question updated successfully");
            } else {
                response.sendRedirect("quizzes.jsp?error=Question not found");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("quizzes.jsp?error=Invalid ID format");
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