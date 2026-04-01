package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/checkUsername")
public class CheckUsernameServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root"; // Change to your MySQL password
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String currentUserId = request.getParameter("currentUserId");
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        // Log for debugging
        System.out.println("🔍 Checking username: '" + username + "' for user ID: " + currentUserId);
        
        // Validate input
        if (username == null || username.trim().isEmpty()) {
            out.print("{\"available\": false, \"message\": \"Username cannot be empty\"}");
            return;
        }
        
        // Username validation
        if (username.length() < 3) {
            out.print("{\"available\": false, \"message\": \"Username must be at least 3 characters\"}");
            return;
        }
        
        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            out.print("{\"available\": false, \"message\": \"Username can only contain letters, numbers, and underscores\"}");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Load MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded");
            
            // Connect to database
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ Connected to database");
            
            String sql;
            if (currentUserId != null && !currentUserId.isEmpty() && !currentUserId.equals("null")) {
                // Check if username exists for OTHER users (not the current one)
                sql = "SELECT id FROM users WHERE username = ? AND id != ?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setInt(2, Integer.parseInt(currentUserId));
                System.out.println("🔍 Checking for other users with username: " + username);
            } else {
                // For signup - check if username exists at all
                sql = "SELECT id FROM users WHERE username = ?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                System.out.println("🔍 Checking if username exists: " + username);
            }
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                // Username found
                System.out.println("❌ Username '" + username + "' is already taken");
                out.print("{\"available\": false, \"message\": \"Username '" + username + "' is already taken\"}");
            } else {
                // Username available
                System.out.println("✅ Username '" + username + "' is available!");
                out.print("{\"available\": true, \"message\": \"Username '" + username + "' is available!\"}");
            }
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"Database driver error\"}");
            
        } catch (SQLException e) {
            System.out.println("❌ SQL Error: " + e.getMessage());
            System.out.println("Error Code: " + e.getErrorCode());
            System.out.println("SQL State: " + e.getSQLState());
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
            
        } catch (NumberFormatException e) {
            System.out.println("❌ Invalid user ID format: " + currentUserId);
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"Invalid user ID\"}");
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"available\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
            
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}