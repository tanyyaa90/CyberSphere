package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = System.getenv("DB_URL");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASS = System.getenv("DB_PASS");
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form data
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneDigits = request.getParameter("phone");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");
        
        // Combine +91 with phone digits
        String fullPhone = "+91" + phoneDigits;
        
        // Create full name
        String fullName = firstName;
        if (lastName != null && !lastName.trim().isEmpty()) {
            fullName += " " + lastName;
        }
        
        // Save to database
        boolean saved = saveToDatabase(fullName, email, fullPhone, subject, message);
        
        if (saved) {
            // Success - redirect with success message
            response.sendRedirect("contact.jsp?success=" + 
                java.net.URLEncoder.encode("Thank you for contacting us! Your message has been sent successfully. We'll get back to you within 24 hours.", "UTF-8"));
        } else {
            // Error - redirect with error message
            response.sendRedirect("contact.jsp?error=" + 
                java.net.URLEncoder.encode("There was an error sending your message. Please try again.", "UTF-8"));
        }
    }
    
    private boolean saveToDatabase(String name, String email, String phone, String subject, String message) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            String sql = "INSERT INTO contact_messages (name, email, phone, subject, message, status, submitted_at) " +
                         "VALUES (?, ?, ?, ?, ?, 'unread', NOW())";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, subject);
            ps.setString(5, message);
            
            int rowsInserted = ps.executeUpdate();
            return rowsInserted > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("contact.jsp");
    }
}