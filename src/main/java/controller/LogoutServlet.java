package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    
    // Database connection parameters
	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = null;
        
        if (session != null) {
            // Get user ID before invalidating session
            userId = (Integer) session.getAttribute("userId");
            
            // Update logout time in database
            if (userId != null) {
                updateLogoutTime(userId);
            }
            
            // Invalidate the session to log out
            session.invalidate();
            System.out.println("✅ User logged out successfully" + (userId != null ? " (ID: " + userId + ")" : ""));
        }
        
        // Prevent caching of the previous page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        // Redirect to login page
        response.sendRedirect("welcome.jsp");
    }
    
    // Also handle GET requests for direct access
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    // Method to update logout time in user_sessions table
    private void updateLogoutTime(int userId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String updateSessionSql = "UPDATE user_sessions SET logout_time = NOW() WHERE user_id = ? AND logout_time IS NULL ORDER BY login_time DESC LIMIT 1";
            ps = conn.prepareStatement(updateSessionSql);
            ps.setInt(1, userId);
            
            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("✅ Logout time recorded for user ID: " + userId);
            } else {
                System.out.println("⚠️ No active session found for user ID: " + userId);
            }
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("❌ Database error while updating logout time: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}