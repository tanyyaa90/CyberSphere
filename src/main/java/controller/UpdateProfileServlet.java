package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    
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
        
        // Get all form parameters
        String username = request.getParameter("username");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // Log for debugging
        System.out.println("📝 Updating profile for user ID: " + userId);
        System.out.println("Username: " + username);
        System.out.println("First Name: " + firstName);
        System.out.println("Last Name: " + lastName);
        System.out.println("Email: " + email);
        System.out.println("Phone: " + phone);
        
        // Validate required fields
        if (username == null || username.trim().isEmpty() ||
            firstName == null || firstName.trim().isEmpty() ||
            email == null || email.trim().isEmpty()) {
            
            response.sendRedirect("profile?edit=true&error=Required fields cannot be empty");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Check if username is already taken by another user
            String checkSql = "SELECT id FROM users WHERE username = ? AND id != ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            checkStmt.setInt(2, userId);
            rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // Username taken by another user
                System.out.println("❌ Username '" + username + "' is already taken");
                response.sendRedirect("profile?edit=true&error=Username '" + username + "' is already taken");
                return;
            }
            
            // Check if email is already taken by another user
            String checkEmailSql = "SELECT id FROM users WHERE email = ? AND id != ?";
            PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql);
            checkEmailStmt.setString(1, email);
            checkEmailStmt.setInt(2, userId);
            ResultSet emailRs = checkEmailStmt.executeQuery();
            
            if (emailRs.next()) {
                // Email taken by another user
                System.out.println("❌ Email '" + email + "' is already taken");
                response.sendRedirect("profile?edit=true&error=Email '" + email + "' is already taken");
                return;
            }
            
            // Update profile - include ALL fields
            String sql = "UPDATE users SET username = ?, first_name = ?, last_name = ?, email = ?, phone = ? WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, firstName);
            stmt.setString(3, lastName != null ? lastName : ""); // Handle null last name
            stmt.setString(4, email);
            stmt.setString(5, phone != null ? phone : ""); // Handle null phone
            stmt.setInt(6, userId);
            
            int rowsUpdated = stmt.executeUpdate();
            System.out.println("📊 Rows updated: " + rowsUpdated);
            
            if (rowsUpdated > 0) {
                // Update ALL session attributes
                session.setAttribute("username", username);
                session.setAttribute("firstName", firstName);
                session.setAttribute("lastName", lastName);
                session.setAttribute("email", email);
                session.setAttribute("phone", phone);
                
                System.out.println("✅ Profile updated successfully for user: " + username);
                response.sendRedirect("profile?success=Profile updated successfully");
            } else {
                System.out.println("❌ Failed to update profile");
                response.sendRedirect("profile?edit=true&error=Failed to update profile");
            }
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("profile?edit=true&error=Database driver error");
            
        } catch (SQLException e) {
            System.out.println("❌ SQL Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("profile?edit=true&error=Database error: " + e.getMessage());
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("profile?edit=true&error=Unexpected error: " + e.getMessage());
            
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}