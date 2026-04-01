package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/resetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {
    
	private static final String DB_URL = System.getenv("DB_URL");
	private static final String DB_USER = System.getenv("DB_USER");
	private static final String DB_PASS = System.getenv("DB_PASS");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate passwords match
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("resetPassword.jsp?token=" + token + "&error=Passwords do not match");
            return;
        }
        
        // Validate password strength (optional)
        if (password.length() < 6) {
            response.sendRedirect("resetPassword.jsp?token=" + token + "&error=Password must be at least 6 characters");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Hash the new password
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            
            // Update password and clear reset token
            String sql = "UPDATE users SET password = ?, reset_token = NULL, reset_token_expiry = NULL WHERE reset_token = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, hashedPassword);
            stmt.setString(2, token);
            
            int rowsUpdated = stmt.executeUpdate();
            
            if (rowsUpdated > 0) {
                response.sendRedirect("login.jsp?success=Password reset successful! Please login with your new password.");
            } else {
                response.sendRedirect("forgotPassword.jsp?error=Invalid or expired token. Please request a new one.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgotPassword.jsp?error=Database error occurred");
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}