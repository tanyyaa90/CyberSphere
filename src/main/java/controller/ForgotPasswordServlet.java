package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.util.UUID;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import util.RateLimiter;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {
    
    // Database connection info - UPDATE THESE WITH YOUR ACTUAL VALUES
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cybersphere?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root"; // Change to your MySQL password
    
    // Email configuration - UPDATE THESE WITH YOUR ACTUAL VALUES
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USERNAME = "cybersphere.contactus@gmail.com"; // Your Gmail
    private static final String SMTP_PASSWORD = "vfatphbhoczvxplk"; // App password
    
    // App URL - UPDATE THIS FOR YOUR DEPLOYMENT
    private static final String APP_URL = "http://localhost:8080/cybersphere";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String contact = request.getParameter("contact");
        String method = request.getParameter("method");
        
        System.out.println("📝 Forgot password request for: " + contact + " via " + method);
        
        if ("mobile".equals(method) && contact != null && !contact.isEmpty()) {
            // Remove any non-digits
            contact = contact.replaceAll("[^0-9]", "");
            
            // Ensure 10 digits
            if (contact.length() == 10) {
                contact = "+91" + contact;
            } else {
                request.setAttribute("error", "Please enter a valid 10-digit mobile number");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
        }
        
        // Rate limiting check
        if (!RateLimiter.isAllowed(contact)) {
            request.setAttribute("error", "Too many attempts. Please try again after 15 minutes.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        
        try {
            // Load MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded");
            
            // Connect to database
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ Connected to database");
            
            // Find user by email or phone
            User user = findUserByContact(conn, contact);
            
            if (user == null) {
                System.out.println("❌ No user found with: " + contact);
                request.setAttribute("error", "No account found with that email or phone number");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ User found: " + user.getEmail() + " (ID: " + user.getId() + ")");
            
            // Generate reset token
            String resetToken = UUID.randomUUID().toString();
            System.out.println("🔑 Generated token: " + resetToken);
            
            // Save reset token to database
            boolean tokenSaved = saveResetToken(conn, user.getId(), resetToken);
            
            if (!tokenSaved) {
                System.out.println("❌ Failed to save token to database");
                request.setAttribute("error", "Failed to generate reset token. Please try again.");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Token saved to database");
            
            // Send reset based on method
            if ("email".equals(method) || (method == null && user.getEmail() != null)) {
                System.out.println("📧 Attempting to send email to: " + user.getEmail());
                
                boolean emailSent = sendPasswordResetEmail(user.getEmail(), user.getFirstName(), resetToken);
                
                if (emailSent) {
                    request.setAttribute("message", "✅ Password reset link sent to " + maskEmail(user.getEmail()));
                    System.out.println("✅ Email sent successfully");
                } else {
                    System.out.println("❌ Email failed to send");
                    request.setAttribute("warning", "⚠️ Reset link generated but email delivery failed. Please try again or contact support.");
                }
                
            } else if ("sms".equals(method) && user.getPhone() != null) {
                System.out.println("📱 Attempting to send SMS to: " + user.getPhone());
                
                String resetCode = generateResetCode();
                boolean codeSaved = saveResetCode(conn, user.getId(), resetCode);
                
                if (codeSaved) {
                    sendPasswordResetSMS(user.getPhone(), resetCode, user.getFirstName());
                    request.setAttribute("message", "✅ Reset code sent to " + maskPhone(user.getPhone()));
                    System.out.println("✅ SMS would be sent with code: " + resetCode);
                } else {
                    System.out.println("❌ Failed to save reset code");
                    request.setAttribute("error", "Failed to generate reset code. Please try again.");
                }
            }
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database driver error. Please contact support.");
            
        } catch (SQLException e) {
            System.out.println("❌ SQL Error: " + e.getMessage());
            System.out.println("Error Code: " + e.getErrorCode());
            System.out.println("SQL State: " + e.getSQLState());
            e.printStackTrace();
            
            // User-friendly error messages
            if (e.getMessage().contains("Unknown database")) {
                request.setAttribute("error", "Database 'cybersphere' not found. Please create it first.");
            } else if (e.getMessage().contains("Access denied")) {
                request.setAttribute("error", "Database access denied. Check username/password.");
            } else if (e.getMessage().contains("Connection refused")) {
                request.setAttribute("error", "MySQL not running. Please start MySQL.");
            } else {
                request.setAttribute("error", "Database error: " + e.getMessage());
            }
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
            
        } finally {
            // Close database connection
            try { 
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                    System.out.println("✅ Database connection closed");
                }
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
        
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
    
    private User findUserByContact(Connection conn, String contact) throws SQLException {
        String sql = "SELECT id, first_name, last_name, username, email, phone FROM users WHERE email = ? OR phone = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, contact);
            stmt.setString(2, contact);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setFirstName(rs.getString("first_name"));
                    user.setLastName(rs.getString("last_name"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone"));
                    return user;
                }
            }
        }
        return null;
    }
    
    private boolean saveResetToken(Connection conn, int userId, String token) throws SQLException {
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = DATE_ADD(NOW(), INTERVAL 1 HOUR) WHERE id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            stmt.setInt(2, userId);
            
            int rowsUpdated = stmt.executeUpdate();
            System.out.println("📊 Token save - rows updated: " + rowsUpdated);
            
            return rowsUpdated > 0;
        }
    }
    
    private boolean saveResetCode(Connection conn, int userId, String code) throws SQLException {
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, code);
            stmt.setInt(2, userId);
            
            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        }
    }
    
    private String generateResetCode() {
        // Generate a 6-digit code
        return String.format("%06d", (int)(Math.random() * 999999));
    }
    
    private boolean sendPasswordResetEmail(String recipientEmail, String firstName, String token) {
        String resetLink = APP_URL + "/resetPassword.jsp?token=" + token;
        
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        // Create session with explicit credentials
        Session session = Session.getInstance(props, 
            new jakarta.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(
                        SMTP_USERNAME, 
                        SMTP_PASSWORD
                    );
                }
            });
        //session.setDebug(true); // Remove this line in production
        
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_USERNAME, "CyberSphere Security"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("🔐 CyberSphere - Password Reset Request");
            message.setSentDate(new java.util.Date());
            
            // Your beautiful HTML email template
            String htmlContent = String.format(
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<style>" +
                "body { font-family: 'Segoe UI', Arial, sans-serif; background: #0f172a; margin: 0; padding: 20px; }" +
                ".container { max-width: 500px; margin: 0 auto; background: #020617; padding: 30px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.6); }" +
                "h2 { color: #38bdf8; margin-bottom: 20px; font-size: 24px; }" +
                ".greeting { color: #e5e7eb; font-size: 16px; line-height: 1.5; }" +
                ".button { display: inline-block; padding: 14px 35px; background: #2563eb; color: white; " +
                "text-decoration: none; border-radius: 8px; margin: 25px 0; font-weight: 600; font-size: 16px; }" +
                ".button:hover { background: #1d4ed8; }" +
                ".footer { color: #94a3b8; font-size: 12px; margin-top: 30px; border-top: 1px solid #1e293b; padding-top: 20px; }" +
                ".warning { color: #f87171; font-size: 13px; background: #7f1d1d20; padding: 10px; border-radius: 6px; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<h2>🔐 Password Reset Request</h2>" +
                "<p class='greeting'>Hello %s,</p>" +
                "<p class='greeting'>We received a request to reset your CyberSphere account password. Click the button below to proceed:</p>" +
                "<div style='text-align: center;'>" +
                "<a href='%s' class='button'>Reset Password</a>" +
                "</div>" +
                "<p class='warning'>⚠️ This link will expire in 1 hour.</p>" +
                "<p class='greeting'>If you didn't request this password reset, please ignore this email or contact support if you have concerns.</p>" +
                "<div class='footer'>" +
                "<p>CyberSphere Security Team</p>" +
                "<p style='margin-top: 10px;'>© 2024 CyberSphere. All rights reserved.</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>", firstName, resetLink);
            
            message.setContent(htmlContent, "text/html; charset=utf-8");
            
            System.out.println("📤 Sending password reset email to: " + recipientEmail);
            Transport.send(message);
            System.out.println("✅ Password reset email sent successfully!");
            return true;
            
        } catch (Exception e) {
            System.out.println("❌ Email sending failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    private void sendPasswordResetSMS(String phoneNumber, String code, String firstName) {
        // This is a placeholder for SMS integration
        // You'll need Twilio or similar service
        System.out.println("📱 SMS would be sent to: " + phoneNumber);
        System.out.println("👤 User: " + firstName);
        System.out.println("🔑 Reset code: " + code);
    }
    
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        String[] parts = email.split("@");
        if (parts[0].length() <= 2) return email;
        String masked = parts[0].substring(0, 2) + "****" + parts[0].substring(parts[0].length() - 1);
        return masked + "@" + parts[1];
    }
    
    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 10) return phone;
        return phone.substring(0, 3) + "******" + phone.substring(phone.length() - 2);
    }
    
    // Inner User class
    private static class User {
        private int id;
        private String firstName;
        private String lastName;
        private String username;
        private String email;
        private String phone;
        
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
    }
}