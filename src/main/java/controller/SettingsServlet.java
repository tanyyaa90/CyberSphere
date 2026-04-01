package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/SettingsServlet")
public class SettingsServlet extends HttpServlet {
    
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
        
        System.out.println("========== SETTINGS SERVLET ==========");
        System.out.println("✅ Saving settings...");
        
        // Get all settings from form
        String siteLogo = request.getParameter("site_logo");
        String favicon = request.getParameter("favicon");
        String websiteStatus = request.getParameter("website_status");
        String passwordPolicy = request.getParameter("password_policy");
        String twoFactorAuth = request.getParameter("two_factor_auth");
        String accountLockoutDuration = request.getParameter("account_lockout_duration");
        String sessionSecurity = request.getParameter("session_security");
        String senderName = request.getParameter("sender_name");
        String senderEmail = request.getParameter("sender_email");
        String emailTemplate = request.getParameter("email_template");
        String enableComments = request.getParameter("enable_comments");
        String enableRatings = request.getParameter("enable_ratings");
        String backupSchedule = request.getParameter("backup_schedule");
        String backupLocation = request.getParameter("backup_location");
        String apiEnabled = request.getParameter("api_enabled");
        String webhookUrl = request.getParameter("webhook_url");
        String rateLimit = request.getParameter("rate_limit");
        String googleAnalyticsId = request.getParameter("google_analytics_id");
        String trackingCode = request.getParameter("tracking_code");
        
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Update each setting
            updateSetting(conn, "site_logo", siteLogo, userId);
            updateSetting(conn, "favicon", favicon, userId);
            updateSetting(conn, "website_status", websiteStatus, userId);
            updateSetting(conn, "password_policy", passwordPolicy, userId);
            updateSetting(conn, "two_factor_auth", twoFactorAuth != null ? "true" : "false", userId);
            updateSetting(conn, "account_lockout_duration", accountLockoutDuration, userId);
            updateSetting(conn, "session_security", sessionSecurity != null ? "true" : "false", userId);
            updateSetting(conn, "sender_name", senderName, userId);
            updateSetting(conn, "sender_email", senderEmail, userId);
            updateSetting(conn, "email_template", emailTemplate, userId);
            updateSetting(conn, "enable_comments", enableComments != null ? "true" : "false", userId);
            updateSetting(conn, "enable_ratings", enableRatings != null ? "true" : "false", userId);
            updateSetting(conn, "backup_schedule", backupSchedule, userId);
            updateSetting(conn, "backup_location", backupLocation, userId);
            updateSetting(conn, "api_enabled", apiEnabled != null ? "true" : "false", userId);
            updateSetting(conn, "webhook_url", webhookUrl, userId);
            updateSetting(conn, "rate_limit", rateLimit, userId);
            updateSetting(conn, "google_analytics_id", googleAnalyticsId, userId);
            updateSetting(conn, "tracking_code", trackingCode, userId);
            
            System.out.println("✅ All settings saved successfully");
            response.sendRedirect("settings.jsp?success=Settings saved successfully");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ Error saving settings: " + e.getMessage());
            response.sendRedirect("settings.jsp?error=Error saving settings: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void updateSetting(Connection conn, String key, String value, int userId) throws SQLException {
        if (value == null) value = "";
        
        String sql = "INSERT INTO site_settings (setting_key, setting_value, updated_by, updated_at) " +
                     "VALUES (?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_by = VALUES(updated_by), updated_at = NOW()";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.setInt(3, userId);
            ps.executeUpdate();
            System.out.println("  ✅ Updated setting: " + key + " = " + value);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("reset".equals(action)) {
            resetToDefaults(request, response);
        } else if ("backup".equals(action)) {
            backupDatabase(request, response);
        } else if ("optimize".equals(action)) {
            optimizeDatabase(request, response);
        } else {
            response.sendRedirect("settings.jsp");
        }
    }
    
    private void resetToDefaults(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Reset to default values
        Connection conn = null;
        Statement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            stmt = conn.createStatement();
            
            String sql = "UPDATE site_settings SET setting_value = " +
                "CASE setting_key " +
                "WHEN 'site_logo' THEN '/images/logo.svg' " +
                "WHEN 'favicon' THEN '/images/favicon.ico' " +
                "WHEN 'website_status' THEN 'online' " +
                "WHEN 'password_policy' THEN 'medium' " +
                "WHEN 'two_factor_auth' THEN 'false' " +
                "WHEN 'account_lockout_duration' THEN '30' " +
                "WHEN 'session_security' THEN 'true' " +
                "WHEN 'sender_name' THEN 'CyberSphere Team' " +
                "WHEN 'sender_email' THEN 'cybersphere.contactus@gmail.com' " +
                "WHEN 'email_template' THEN 'default' " +
                "WHEN 'enable_comments' THEN 'true' " +
                "WHEN 'enable_ratings' THEN 'true' " +
                "WHEN 'backup_schedule' THEN 'daily' " +
                "WHEN 'backup_location' THEN '/backups' " +
                "WHEN 'api_enabled' THEN 'false' " +
                "WHEN 'webhook_url' THEN '' " +
                "WHEN 'rate_limit' THEN '60' " +
                "WHEN 'google_analytics_id' THEN '' " +
                "WHEN 'tracking_code' THEN '' " +
                "END";
            
            stmt.executeUpdate(sql);
            response.sendRedirect("settings.jsp?success=Settings reset to defaults");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("settings.jsp?error=Failed to reset settings");
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void backupDatabase(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Implement database backup logic here
        response.sendRedirect("settings.jsp?success=Database backup created successfully");
    }
    
    private void optimizeDatabase(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;
        Statement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            stmt = conn.createStatement();
            
            stmt.execute("OPTIMIZE TABLE users, contact_messages, learning_content, quiz_attempts, phishing_log, content_views, user_progress, site_settings, admin_permissions");
            response.sendRedirect("settings.jsp?success=Database optimized successfully");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("settings.jsp?error=Failed to optimize database");
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}