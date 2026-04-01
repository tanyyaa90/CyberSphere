package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/updateProfileImage")
public class UpdateProfileImageServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root"; // Change to your MySQL password
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String selectedImage = request.getParameter("selectedImage");
        
        // Log for debugging
        System.out.println("📝 Updating profile image for user ID: " + userId);
        System.out.println("Selected image: " + selectedImage);
        
        if (selectedImage == null || selectedImage.trim().isEmpty()) {
            response.sendRedirect("profile?error=No image selected");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Check if profile_image column exists, if not add it
            String checkColumnSql = "SHOW COLUMNS FROM users LIKE 'profile_image'";
            Statement checkStmt = conn.createStatement();
            ResultSet rs = checkStmt.executeQuery(checkColumnSql);
            
            if (!rs.next()) {
                // Add profile_image column if it doesn't exist
                String alterSql = "ALTER TABLE users ADD COLUMN profile_image VARCHAR(500) DEFAULT 'https://i.ibb.co/6RfWN4zJ/buddy-10158022.png'";
                Statement alterStmt = conn.createStatement();
                alterStmt.executeUpdate(alterSql);
                alterStmt.close();
                System.out.println("✅ Added profile_image column to users table");
            }
            rs.close();
            checkStmt.close();
            
            // Update user's profile image
            String sql = "UPDATE users SET profile_image = ? WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, selectedImage);
            stmt.setInt(2, userId);
            
            int rowsUpdated = stmt.executeUpdate();
            System.out.println("📊 Rows updated: " + rowsUpdated);
            
            if (rowsUpdated > 0) {
                // Update session
                session.setAttribute("profileImage", selectedImage);
                System.out.println("✅ Profile image updated successfully");
                response.sendRedirect("profile?success=Profile photo updated successfully");
            } else {
                System.out.println("❌ Failed to update profile image");
                response.sendRedirect("profile?error=Failed to update profile image");
            }
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("profile?error=Database driver error");
            
        } catch (SQLException e) {
            System.out.println("❌ SQL Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("profile?error=Database error: " + e.getMessage());
            
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}